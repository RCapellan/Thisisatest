#################################################################
#################################################################
#################### EXAMPLES BSC LIBRARIES #####################
#################################################################
#################################################################

library(abind)
library(s2dv)
library(parallel)
library(ClimProjDiags)

#########################################################
############# ClimProjDiags - Brief Summary #############
#########################################################

var <- 'tasmax'

start_climatology <- '1971'
end_climatology <- '2000'

start_projection <- '2006'
end_projection <- '2100'

lat <- seq(25, 60, 5)
lon <- seq(-35, 20 ,5)

# A synthetic sample of data for the reference period is built by adding random 
# perturbations to a sinusoidal function. The latitudinal behavior of the 
# temperature is considered by randomly subtracting a value proportional to 
# the latitude. Furthermore, attributes of time and dimensions are added
###################################################################################
tmax_historical <- NULL
grid1 <- 293 - 10 * cos(2 * pi / 365 * (1 : 10958)) + rnorm(10958)
gridlon <- NULL
for (i in 1 : 12) {
  gridlon <- cbind(gridlon, grid1 + rnorm(10958, sd = 5) * 
                                    cos(2 * pi / 365 * (1 : 10958)))
}
for (j in 1 : 8) {
  gridnew <- apply(gridlon, 2, function(x) {x - rnorm(10958, mean = j * 0.5, sd = 3)})
  tmax_historical <- abind(tmax_historical, gridnew, along = 3)
}
names(dim(tmax_historical)) <- c("time", "lon", "lat")
tmax_historical <- InsertDim(InsertDim(tmax_historical, posdim = 1, 
                             lendim = 1, name = "var"),
                             posdim = 1, lendim = 1, name = "model")
time <- seq(ISOdate(1971, 1, 1), ISOdate(2000, 12, 31), "day")
metadata <- list(time = list(standard_name = 'time', long_name = 'time', 
                             calendar = 'proleptic_gregorian',
                             units = 'days since 1970-01-01 00:00:00', prec = 'double', 
                             dim = list(list(name = 'time', unlim = FALSE))))
attr(time, "variables") <- metadata
attr(tmax_historical, 'Variables')$dat1$time <- time

####################################################################################

# A similar procedure is considered to build the synthetic data for the future 
# projections. However, a small trend is added.
tmax_projection <- NULL
grid1 <- 298 - 10 * cos(2 * pi / 365 * (1 : 34698)) + 
         rnorm(34698) + (1 : 34698) * rnorm(1, mean = 4) / 34698
gridlon <- NULL
for (i in 1 : 12) {
  gridlon <- cbind(gridlon, grid1 + rnorm(34698, sd = 5) * 
                                    cos(2 * pi / 365 * (1 : 34698)))
}
for (j in 1 : 8) {
  gridnew <- apply(gridlon, 2, function(x) {x - rnorm(34698, mean = j * 0.5, 
                                                      sd = 3)})
  tmax_projection <- abind(tmax_projection, gridnew, along = 3)
}
names(dim(tmax_projection)) <- c("time", "lon", "lat")
tmax_projection <- InsertDim(InsertDim(tmax_projection, posdim = 1, 
                                       lendim = 1, name = "var"), 
                             posdim = 1, lendim = 1, name = "model")
time <- seq(ISOdate(2006, 1, 1), ISOdate(2100, 12, 31), "day")
metadata <- list(time = list(standard_name = 'time', long_name = 'time', 
                             calendar = 'proleptic_gregorian',
                             units = 'days since 1970-01-01 00:00:00', prec = 'double', 
                             dim = list(list(name = 'time', unlim = FALSE))))
attr(time, "variables") <- metadata
attr(tmax_projection, 'Variables')$dat1$time <- time


########################################################
###################### HEATWAVES #######################
########################################################

summer_tmax_historical <- SeasonSelect(tmax_historical, season = 'JJA')

quantile <- 0.9
thresholds <- Threshold(data = summer_tmax_historical$data, 
                        dates = summer_tmax_historical$dates, 
                        calendar ="proleptic_gregorian", 
                        qtiles = quantile, ncores = detectCores() -1)


summer_tmax_projection <- SeasonSelect(tmax_projection, season = 'JJA')

duration <- WaveDuration(data = summer_tmax_projection$data, 
                         threshold = thresholds, op = ">", spell.length = 5, 
                         dates = summer_tmax_projection$dates, 
                         calendar = "proleptic_gregorian")
breaks <- seq(0,92,4)

PlotEquiMap(apply(duration$result, c(2, 3), max), lon = lon, lat = lat, 
            brks = breaks, filled.continents = FALSE, title_scale = 0.8,
            toptitle = "Heat wave duration", 
            cols = heat.colors(length(breaks)-1)[(length(breaks)-1):1],
            fileout = "SpatialHeatwave.png")