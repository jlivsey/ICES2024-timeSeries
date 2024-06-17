# ICES 2024 short course

# tools for seasonal adjustment of High Frequency data

# Packages repository: https://github.com/rjdverse
#                        
# Dependencies: {RProtoBuf}, {rJava}, {checkmate}, {rjd3toolkit}, Java 17 (or higher)

# Data: French daily births (Metropolitan France only)
# Source: https://www.insee.fr/fr/statistiques/6524900?sommaire=6524912

# -------------------------------------------------------------------------------------------------
# Data input & point-wise Canova-Hansen statistics
# -------------------------------------------------------------------------------------------------
library(ggplot2)
library(dplyr)
library(rjd3toolkit)
library(rjd3highfreq)
library(rjd3x11plus)


df_daily = readRDS("data/Births.RDS")
# This dataframe contains the following variables:
# date       = from 01/01/1968 to 12/31/2000
# births     = daily number of French Births
# log_births = daily number of French Births in log
# day        = indicates the day of the week, D1=Monday...D7=Sunday
# month      = indicates the day of the month, M01=January...M12=December
View(df_daily)
ch.sp = 2:367 # Seasonal periodicities to be tested for

df_ch = data.frame(
  "sp" = ch.sp,
  "ch.raw" = rjd3toolkit::seasonality_canovahansen(df_daily$births,
                                              p0 = min(ch.sp), p1 = max(ch.sp),
                                              np = max(ch.sp) - min(ch.sp) + 1, original = TRUE),
  "ch.log" = rjd3toolkit::seasonality_canovahansen(df_daily$log_births,
                                              p0 = min(ch.sp), p1 = max(ch.sp),
                                              np = max(ch.sp) - min(ch.sp) + 1, original = TRUE),
  "ch.dlg" = rjd3toolkit::seasonality_canovahansen(diff(df_daily$log_births, lag = 1, differences = 1),
                                              p0 = min(ch.sp), p1 = max(ch.sp),
                                              np = max(ch.sp) - min(ch.sp) + 1, original = TRUE))

# # Significant periodicities (Harvey, 2001, Table I(b))
# 
which(df_ch$ch.raw > .211) + 1 # 10% level of significance
which(df_ch$ch.raw > .247) + 1 #  5% level of significance
which(df_ch$ch.raw > .329) + 1 #  1% level of significance

# Barplot

ggplot(df_ch) +
  geom_col(aes(sp, ch.raw), size = .25) +
  labs(x = "Periodicity (in days)", y = "") +
  ggthemes::theme_hc()

# -------------------------------------------------------------------------------------------------
# Pre adjustement with frctionnal airline model 
# -------------------------------------------------------------------------------------------------



# Creation of log variables to multiplicative model
df_daily$log_births <- log(df_daily$births)

#  Specifying time index (for results display)
df_daily$date <- as.Date(df_daily$date)

# French calendar
frenchCalendar <- rjd3toolkit::national_calendar(days = list(
  rjd3toolkit::fixed_day(7, 14), # Bastille Day
  rjd3toolkit::fixed_day(5, 8, validity = list(start = "1982-05-08")), # End of 2nd WW
  rjd3toolkit::special_day('NEWYEAR'),
  rjd3toolkit::special_day('MAYDAY'), # 1st may
  rjd3toolkit::special_day('EASTERMONDAY'),
  rjd3toolkit::special_day('ASCENSION'),
  rjd3toolkit::special_day('WHITMONDAY'),
  rjd3toolkit::special_day('ASSUMPTION'),
  rjd3toolkit::special_day('ALLSAINTSDAY'), # Toussaint
  rjd3toolkit::special_day('ARMISTICE'), # End of 1st WW
  rjd3toolkit::special_day('CHRISTMAS'))
)
  
# Calendar regressor matrix
cal_reg <- rjd3toolkit::holidays(
  calendar = frenchCalendar,
  start = "1968-01-01", length = nrow(df_daily),
  type = "All", nonworking = 7L)

colnames(cal_reg) <- c("14th_july", "8th_may", "1st_jan", "1st_may",
                       "east_mon", "asc", "pen_mon",
                       "15th_aug", "1st_nov", "11th_nov", "Xmas")

# ------------------------------------------------------------------------------------------
# Pre-adjustment with extended fractional Airline Model
# ------------------------------------------------------------------------------------------

pre_pro <- fractionalAirlineEstimation(
  y = df_daily$births,
  x = cal_reg,
  periods = c(7,365.25), # weekly + yearly frequencies 
  outliers = c("ao", "wo"), log = TRUE, y_time = df_daily$date)

#pre_pro$model$linearized

print(pre_pro)

plot(pre_pro, main = "French births")


plot(x = pre_pro,
     from = as.Date("2000-01-01"), to = as.Date("2000-12-31"),
     main = "French births in 2000")

# ------------------------------------------------------------------------------------------
# AMB Decomposition
# ------------------------------------------------------------------------------------------


# Decomposition with weekly pattern
amb.dow <- rjd3highfreq::fractionalAirlineDecomposition(
  y = pre_pro$model$linearized, # linearized series from preprocessing
  period = 7,
  log = TRUE, y_time = df_daily$date)

# Extract day-of-year pattern from day-of-week-adjusted linearised data
amb.doy <- rjd3highfreq::fractionalAirlineDecomposition(
  y = amb.dow$decomposition$sa, # DOW-adjusted linearized data
  period = 365.2425, # day of year pattern
  log = TRUE, y_time = df_daily$date)

plot(amb.dow, main = "Weekly pattern")

plot(amb.dow, main = "Weekly pattern - January 2018",
     from = as.Date("2018-01-01"),
     to = as.Date("2018-01-31"))

plot(amb.doy, main = "Yearly pattern")

amb.multi <- rjd3highfreq::multiAirlineDecomposition(
  y = pre_pro$model$linearized, # input time series
  periods = c(7, 365.2425), # 2 frequency
  log = TRUE, y_time = df_daily$date)


plot(amb.multi, main = "2012",
     from = as.Date("2012-01-01"),
     to = as.Date("2012-12-31"))


# ------------------------------------------------------------------------------------------
# X11 Decomposition
# ------------------------------------------------------------------------------------------

x11.dow <- rjd3x11plus::x11plus(
  y = exp(pre_pro$model$linearized),
  # result from preadjustment part
  period = 7,                 # DOW pattern
  mul = TRUE,
  trend.horizon = 9,  # 1/2 Filter length : not too long vs p
  trend.degree = 3,                         # Polynomial degree
  trend.kernel = "Henderson",               # Kernel function
  trend.asymmetric = "CutAndNormalize",     # Truncation method
  seas.s0 = "S3X9", seas.s1 = "S3X9",       # Seasonal filters
  extreme.lsig = 1.5, extreme.usig = 2.5    # Sigma-limits
)

#step 2: p = 365.25
x11.doy <- rjd3x11plus::x11plus(x11.dow$decomposition$sa,  # previous sa
                            period = 365.2425,         # DOY pattern
                            mul = TRUE) 
