# When proximity is not enough. A sociodemographic analysis of 15-minute city lifestyles

This repository contains the **code** used for the supplementary analysis of the paper **When proximity is not enough. A sociodemographic analysis of 15-minute city lifestyles**, based on the *EMEF 2021* dataset.

> ⚠️ **Note**: This repository contains **only the code**. The datasets used in the analysis are not publicly available here due to confidentiality restrictions.

## Overview

The main script, `code.R`, performs the following:

- **Data filtering and preparation**:  
  - Includes only respondents residing in Barcelona.  
  - Excludes work/study trips and motorized users.  
  - Retains respondents with primarily active trips (walking or cycling).  
  - Filters trips that start or end at home.

- **Routing computations**:  
  - Uses the [`r5r`](https://github.com/ipeaGIT/r5r) package to compute detailed itineraries by mode of transport.  
  - Calculates travel time to a range of urban social functions (e.g. healthcare, education, retail).

- **Accessibility aggregation**:  
  - Computes average walking time (AWT) per urban function.  

- **Statistical modeling**:  
  - Linear and logistic regression models to examine the influence of accessibility and sociodemographic factors.

## Requirements

To run the code, you’ll need the following R packages:

```r
install.packages(c("foreign", "dplyr", "lubridate", "osmextract", "sf", "data.table", "mgcv"))
devtools::install_github("ipeaGIT/r5r")
