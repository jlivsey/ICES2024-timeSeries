---
output:
  html_document: default
  pdf_document: default
---
# Welcome to the Time Series and Seasonal Adjustment Short Course

We are excited to have the opportunity to teach you about time series and seasonal adjustment (SA) in this 4-hour short course. All course materials will be available on GitHub at [https://github.com/jlivsey/ICES2024-timeSeries](https://github.com/jlivsey/ICES2024-timeSeries).

## Preparation Instructions

As you prepare for the course, please ensure you have the following ready:

### 1. Install R and RStudio

- Download and install R from [CRAN](https://cran.r-project.org/). R version >=4.1 is required.
- Download and install RStudio from [RStudio's website](https://www.rstudio.com/products/rstudio/download/).

### 2. Install R Packages we will be using

After installing R and RStudio, open RStudio and install the following packages by running the code below in the RStudio console:
```R
install.packages(c("tidyverse", "lubridate", "tsbox", "seasonal"))
```

### 3. Set Up JDemetra+ in R

Packages giving access to JDemetra+ version 3.2.2 (the one we will be using to work with high-frequency data) are not on CRAN yet. 
They are available from [this page](https://github.com/rjdverse).

Please note the Java 17 or higher is required to run them. How to get such a version of Java and link it to R is explained on, [this page of JDemetra+ documentation](https://jdemetra-new-documentation.netlify.app/#r-packages)

Once java is set in your R, install the packages listed below following the instructions in the corresponding readme file.
- rdj3toolkit
- rjd3x13
- rjd3tramoseats
- rjd3stl
- rjd3x11plus
- rjd3highfreq

### 4. Optional Preparation Material

If you wish to do some preparatory work, consider reviewing the following references:

- [Chapter 14 of this textbook](https://rc2e.com)
- [Seasonal Adjustment by X-13ARIMA-SEATS in R](https://cran.r-project.org/web/packages/seasonal/vignettes/seas.pdf)
- [Towards seasonal adjustment of infra-monthly time series with JDemetra+](https://www.bundesbank.de/resource/blob/915460/e0c29d7a79c28c3b48cdc0b07f1e3a64/mL/2023-09-04-dkp-24-data.pdf)

## Contact Information

If you have any questions before the course starts, please feel free to reach out to us at:

- james.a.livsey@census.gov
- anna.smyk@insee.fr

We look forward to seeing you in the course!

