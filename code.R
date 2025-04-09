# --- Required Libraries ---
library(foreign)
library(dplyr)
library(lubridate)
library(osmextract)
library(sf)
library(data.table)
library(r5r)
library(mgcv)

# --- Data Import & Cleaning ---

# Load survey data and filter for Barcelona respondents
data <- read.spss("EMEF_2021_DESP.sav", to.data.frame = TRUE, add.undeclared.levels = "no") %>%
  filter(municipality == "Barcelona")

# Load urban functions dataset
urban_function <- read.csv('urban_functions.csv')

# Remove work/study trips and motorized users
data <- data %>%
  mutate(work_trip = trip_purpose %in% c("commute", "work_related", "study") |
           (lag(id) == id & lag(trip_purpose) %in% c("commute", "work_related", "study") & trip_purpose == "home")) %>%
  filter(!work_trip) %>%
  group_by(id) %>%
  filter(!any(transport_mode %in% c("car_driver", "car_passenger", "mopped_driver",
                                    "mopped_passenger", "van", "taxi"))) %>%
  ungroup()

# Keep only users with ≥65% active travel (walking/bike)
active_ids <- data %>%
  count(id, transport_mode) %>%
  group_by(id) %>%
  mutate(freq = n / sum(n)) %>%
  filter(transport_mode %in% c("walk", "bike")) %>%
  summarise(active_share = sum(freq)) %>%
  filter(active_share >= 0.65) %>%
  pull(id)

data <- data %>% filter(id %in% active_ids)

# Keep only trips starting or ending at home
data <- data %>%
  mutate(home_trip = (order == 1 & first_origin == "home") |
           (lag(id) == id & lag(trip_purpose) == "home") |
           trip_purpose == "home") %>%
  filter(home_trip)

# --- Routing Setup ---

options(java.parameters = "-Xmx8G")
r5r_core <- setup_r5(data_path = "C:/your_path", verbose = FALSE)

# Function to compute routes and export shapefiles
compute_routes <- function(data, mode, suffix, include_time = TRUE, engine = r5r_core) {
  for (i in seq_len(nrow(data))) {
    origin <- data[i, c("id", "origin_x", "origin_y")]
    destination <- data[i, c("id", "destination_x", "destination_y")]
    colnames(origin) <- colnames(destination) <- c("id", "lon", "lat")
    
    route <- detailed_itineraries(
      r5r_core = engine,
      origins = origin,
      destinations = destination,
      mode = mode,
      departure_datetime = if (include_time) as.POSIXct(data$V03D_R1o[i]) else NULL,
      shortest_path = TRUE,
      max_walk_time = 30,
      verbose = FALSE
    )
    
    if (nrow(route) > 0) {
      route$route_id <- paste(data$id[i], data$order[i], sep = "_")
      st_write(route, paste0(route$route_id[1], suffix, ".shp"), delete_dsn = TRUE)
    }
  }
}

# Split dataset by transport mode
modes <- list(
  "_bike"  = list(mode = "BICYCLE", data = grep("bike", data$transport_mode, value = FALSE)),
  "_walk"  = list(mode = "WALK", data = grep("walk", data$transport_mode, value = FALSE)),
  "_bus"   = list(mode = c("BUS", "WALK"), data = grep("bus", data$transport_mode, value = FALSE)),
  "_metro" = list(mode = c("TRANSIT", "WALK"), data = grep("subway", data$transport_mode, value = FALSE)),
  "_fgc"   = list(mode = c("RAIL", "WALK"), data = grep("railway", data$transport_mode, value = FALSE))
)

# Compute and save routes
for (sfx in names(modes)) {
  mode_info <- modes[[sfx]]
  compute_routes(data[mode_info$data, ], mode_info$mode, sfx)
}

# Merge Routes
shp_files <- list.files("C:/path", pattern = ".shp", full.names = TRUE)
data_model <- do.call(rbind, lapply(shp_files, read_sf))

# --- Urban Function Accessibility ---

# Compute accessibility to urban functions
compute_routes(urban_functions, "WALK", "_urban_functions", engine = r5r_core)

stop_r5(r5r_core)
rJava::.jgc(R.gc = TRUE)

# Reshape and aggregate accessibility by category
urban_function_means <- urban_function %>%
  group_by(id) %>%
  summarise(across(ends_with("time"), ~ unique(.x), .names = "{.col}_dest")) %>%
  mutate(
    AWT_care         = rowMeans(select(., starts_with("Day_centre"), starts_with("Health_centre"), starts_with("Social_centre")), na.rm = TRUE),
    AWT_education    = rowMeans(select(., starts_with("Nursery"), starts_with("School"), starts_with("High_school")), na.rm = TRUE),
    AWT_entertainment = rowMeans(select(., starts_with("Community_centre"), starts_with("Library"), starts_with("Theatre"),
                                        starts_with("Playground"), starts_with("Sport_facility"), starts_with("Gym"),
                                        starts_with("Pocket_park"), starts_with("Park")), na.rm = TRUE),
    AWT_PT           = rowMeans(select(., starts_with("Daytime_bus_stop"), starts_with("Night_bus_stop"),
                                       starts_with("Railway_station"), starts_with("Bike_share_station"),
                                       starts_with("Cycling_infrastructure")), na.rm = TRUE),
    AWT_retail       = rowMeans(select(., starts_with("Supermarket"), starts_with("Market"),
                                       starts_with("Fresh_food_store"), starts_with("Convenience_store"),
                                       starts_with("Catering_facility"), starts_with("Other_supplies")), na.rm = TRUE),
    AWT = rowMeans(select(., ends_with("time_dest")), na.rm = TRUE)
  ) %>%
  select(id, starts_with("AWT_"))

# Merge with trip data
data_model <- left_join(data_model, urban_function_means, by = "id")

# --- Analysis ---

# Flag users with all trips under 15 and 30 minutes
data_model <- data_model %>%
  group_by(id) %>%
  mutate(
    min15user = all(time <= 15),
    min30user = all(time <= 30)
  ) %>%
  ungroup()

# Normalize numeric variables
data_model <- data_model %>%
  mutate(across(c(household_n, income, subjective_offer_transit,
                  AWT_care, AWT_education, AWT_retail,
                  AWT_entertainment, AWT_PT), scale))

# --- Models ---

# Linear regression: Predicting average walking time
mod0 <- lm(AWT ~ gender + age + education + nationality + household_n + minors +
             elderly + income, weights = weight_sample, data = data_model)

# Logistic regression: All trips under 15 minutes
gam_model15 <- gam(min15user ~ gender + age + education + nationality + household_n + minors +
                     elderly + income + subjective_offer_PT + AWT_care + AWT_education +
                     AWT_entertainment + AWT_PT + AWT_retail +
                     s(GEO_O_X.y, GEO_O_Y.y, bs = "tp"),
                   family = binomial(link = "logit"), data = data_model)

# Logistic regression: All trips under 30 minutes
gam_model30 <- gam(min30user ~ gender + age + education + nationality + household_n + minors +
                     elderly + income + subjective_offer_PT + AWT_care + AWT_education +
                     AWT_entertainment + AWT_PT + AWT_retail +
                     s(GEO_O_X.y, GEO_O_Y.y, bs = "tp"),
                   family = binomial(link = "logit"), data = data_model)
