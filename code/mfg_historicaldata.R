
x = read.csv("data/mfg_historicaldata.csv")

View(x)
head(x)

newOrders = x |>
  dplyr::select(date, nsa_mfg_new_orders_c) |>
  dplyr::rename(time = date) |>
  dplyr::rename(value = nsa_mfg_new_orders_c) |>
  dplyr::mutate(time = lubridate::mdy(time)) |>
  tsbox::ts_ts()

ts_tsibble(newOrders)

head(newOrders)
str(newOrders)

ts_plot(newOrders)

# Is this a seasonal time series?

acf(newOrders)

op = par(mfrow = c(1, 2))
monthplot(AirPassengers - ts_trend(AirPassengers))
monthplot(newOrders - ts_trend(newOrders))
par(op)

# QS test for seasonality
# indicates mild seasonality
m = seas(newOrders, x11 = "")
qs(m)

# seasonal regressor F-test
m2 = seas(
  newOrders,
  x11 = "",
  arima.model = "(0 1 1)",
  regression.variables = "seasonal"
)

Ftest = udg(m2, "ftest$Seasonal") |> round(5)
colnames(Ftest) = c("Seasonal F-test")
rownames(Ftest) = c("df1", "df2", "test_stat", "p_value")
knitr::kable(Ftest)
# indicates there is seasonality

# M7 test for ids
udg(m, "f3.m07")
udg(m, "f2.idseasonal")
# indicates seasonality present 

# Seems to indicate we should 
m = seas(newOrders, x11 = "")
summary(m)

newOrders_pos = newOrders + 100
plot(newOrders_pos)

m3 = seas(newOrders_pos, x11 = "", 
          transform.function = "none", 
          regression.aictest = NULL,
          regression.variables = "tdnolpyear")
summary(m3)
out(m3)

out(m3)

acf(final(m))


view(m3)

final_m <- 
  seas(
    x = newOrders_pos,
    transform.function = "none",
    regression.aictest = NULL,
    outlier = NULL,
    x11 = "",
    regression.variables = c("tdnolpyear", "ls2002.Jan", "ls2009.May", "ao2020.Apr", "ao2020.May", "ao2021.Sep"),
    arima.model = "(0 1 1)(0 1 1)", 
    slidingspans = "", 
    history = ""
  )

out(final_m)

















