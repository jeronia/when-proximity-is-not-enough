# When proximity is not enough. A sociodemographic analysis of 15-minute city lifestyles

This repository contains the **code** used for the analysis of the paper **When proximity is not enough. A sociodemographic analysis of 15-minute city lifestyles**, based on the [*EMEF 2021*](https://www.institutmetropoli.cat/es/encuestas/encuestas-de-movilidad/#1447843451840-2-0) dataset.

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
  - Computes average walking time (AWT) per urban function.  

- **Statistical modeling**:  
  - Linear and logistic regression models to examine the influence of accessibility and sociodemographic factors.
 
## Data Access

Data of *urban social functions* in Barcelona are publicly available from the following sources:
- **Care**
  - [List of social services equipments](https://opendata-ajuntament.barcelona.cat/data/dataset/ff8b356e-efe8-42dc-96c9-503c4ce24fdc/resource/0b5187e2-5868-4edf-a432-a10bce935c5e/download)
  - [List of health equipments](https://opendata-ajuntament.barcelona.cat/data/dataset/9c3035c3-2a5f-4fc0-8162-c20563ae5375/resource/2bf62aa3-63c8-4177-b57a-e32a8c7eb275/download) 
- **Education**
  - [List of education equipments](https://opendata-ajuntament.barcelona.cat/data/dataset/f36b60f2-9541-4d08-b0f9-b0a9313fab3d/resource/29d9ff10-6892-4f16-9012-d5c4997857e7/download)
- **Entertainment and culture**
  - [List of culture and leisure spaces and facilities](https://opendata-ajuntament.barcelona.cat/data/dataset/58e3a2f5-53fb-42b4-9836-d6bc43e66a98/resource/f3721b17-bf9e-4bdd-853c-cb6200e1b442/download)
  - [List of sport equipments](https://opendata-ajuntament.barcelona.cat/data/dataset/13cbdd2a-fbb8-406f-a0f1-8e7f3d52103b/resource/6409e71a-6c79-4d21-9c14-373dbd01f26d/download)
  - [Parks and gardens](https://opendata-ajuntament.barcelona.cat/data/dataset/5d43ed16-f93a-442f-8853-4bf2191b2d39/resource/b64d32a8-aea5-47a8-9826-479b211f5d46/download)
- **Public and active transport**
  - [List of transportation equipments and related services](https://opendata-ajuntament.barcelona.cat/data/dataset/d55f001a-d105-4095-84db-fa69514b84ba/resource/dd70f3f8-7abf-4f0a-934c-e2570e53e9cb/download)
- **Retail**
  - [List of markets and shopping centers](https://opendata-ajuntament.barcelona.cat/data/dataset/3dc277bf-ff89-4b49-8f29-48a1122bb813/resource/2e123ea9-1819-46cf-a545-be61151fa97d/download)
  - [List of restaurants](https://opendata-ajuntament.barcelona.cat/data/dataset/b4d2cc2f-67dc-481a-a7cb-1999fd0d5740/resource/bce0486e-370e-4a72-903f-024ba8902ae1/download)
  - [Census of premises on the ground floor intended for economic activity](https://opendata-ajuntament.barcelona.cat/data/dataset/fe177673-0f83-42e7-b35a-ddea901be8bc/resource/99764d55-b1be-4281-b822-4277442cc721/download/220930_censcomercialbcn_opendata_2022_v10_mod.csv)

## Requirements

To run the code, you’ll need the following R packages:

```r
install.packages(c("foreign", "dplyr", "lubridate", "osmextract", "sf", "data.table", "mgcv"))
devtools::install_github("ipeaGIT/r5r")
```

## Citation
If you use this code or build upon it, please cite our paper (details to be added upon publication).

## References
- R Core Team (2024). foreign: Read Data Stored by 'Minitab', 'S', 'SAS', 'SPSS', 'Stata', 'Systat', 'Weka', 'dBase', ...' R package version 0.8-86. Available at: [https://CRAN.R-project.org/package=foreign](https://CRAN.R-project.org/package=foreign)
- Wickham H, François R, Henry L, Müller K, Vaughan D (2023). dplyr: A Grammar of Data Manipulation. R package version 1.1.4. Available at: [https://CRAN.R-project.org/package=dplyr](https://CRAN.R-project.org/package=dplyr)
- Spinu V, Grolemund G, Wickham H (2023). lubridate: Make Dealing with Dates a Little Easier. R package version 1.9.3. Available at: [https://CRAN.R-project.org/package=lubridate](https://CRAN.R-project.org/package=lubridate)
- Gilardi G, Lovelace R, Padgham M (2023). osmextract: Download and Import OpenStreetMap Data Extracts. R package version 0.4.0. Available at: [https://CRAN.R-project.org/package=osmextract](https://CRAN.R-project.org/package=osmextract)
- Pebesma E (2018). Simple Features for R: Standardized Support for Spatial Vector Data. The R Journal, 10(1), 439–446. Available at: [https://CRAN.R-project.org/package=sf](https://CRAN.R-project.org/package=sf)
- Dowle M, Srinivasan A (2023). data.table: Extension of data.frame. R package version 1.15.2. Available at: [https://CRAN.R-project.org/package=data.table](https://CRAN.R-project.org/package=data.table)
- Wood SN (2017). Generalized Additive Models: An Introduction with R (2nd ed). CRC Press. Associated R package: mgcv, version 1.9-1. Available at: [https://CRAN.R-project.org/package=mgcv](https://CRAN.R-project.org/package=mgcv)
- Pereira RHM, Saraiva M, Braga CKV, Herszenhut D, Wessel N, Nakamura SV, and Andrade PR (2021). r5r: Rapid Realistic Routing with R5. R package available at: [https://github.com/ipeaGIT/r5r](https://github.com/ipeaGIT/r5r)
