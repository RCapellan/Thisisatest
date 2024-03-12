#################################################################
#################################################################
#################### EXAMPLES BSC LIBRARIES #####################
#################################################################
#################################################################

library(CSTools)
library(CSIndicators)
library(s2dv)
library(dplyr)
library(ggplot2)

##################################################################
############# CSTools / CSIndicators - Brief Summary #############
##################################################################

# CSTOOLS:
# - Data storage and retrieval: you can see how to use one of the main data
#   loading functions, Load(), in this vignette, and also a bit about memory issues
#
# - CRAN -> https://cran.r-project.org/web/packages/CSTools/vignettes/Data_Considerations.html

# CSINDICATORS:
# - Set of generalised tools for the flexible computation of climate related 
#   indicators defined by the user.
#
# - CRAN -> https://cran.r-project.org/web/packages/CSIndicators/index.html

# Path to file locations using whitecards
path_ERA5_CDS <- list(path = '/esarchive/recon/ecmwf/era5land/$STORE_FREQ$_mean/$VAR_NAME$_f1h/$VAR_NAME$_$YEAR$$MONTH$.nc')

# Temporal extent and resolution:
# We will work with all months from 2010 to 2020
year_in <- 2010 # initial year
year_fi <- 2012 # last year
month_in <- 1 # first month
month_fi <- 12 # last month

sdates <- paste0(year_in:year_fi, '0101')

# Extract data
vars <- c('tas', 'tdps', 'prlr')

out <- NULL
for(var in vars) {
  out[[var]] <- CST_Load(var = var,
                         exp = NULL, # We only require observed data
                         obs = list(path_ERA5_CDS),
                         sdates = sdates,
                         lonmax = 5, lonmin = 350,
                         latmax = 45, latmin = 35,
                         storefreq = 'monthly',
                         leadtimemin = month_in, 
                         leadtimemax = month_fi,
                         output = "lonlat"
                    )  
}

dim(out$tas$data)
summary(out$tas$data)

# Sneak peek of a sample of the temperature data in Jan 2010
out$tas$data[1, 1, 1, 1, , ][15:20, 15:20]


for (var in c('tas', 'tdps')) {
  out[[var]]$data <- out[[var]]$data - 273.15
}

summary(out$tas$data)

# Create a new s2dv object with relative humidity
out$hurs <- s2dv_cube(data = 100 * (exp((17.625 * out$tdps$data) / (243.04 + out$tdps$data)) / 
                                  exp((17.625 * out$tas$data) / (243.04 + out$tas$data))),
                      lon = out$tas$lon,
                      lat = out$tas$lat,
                      Variable = list(varName = "rh", level = NULL),
                      Dates = out$tas$Dates,
                      Datasets = out$tas$Datasets,
                      when = Sys.time(),
                      source_files = "see source files of tas, tdps and pr")

attr(out$hurs$Variable, "units") <- "%"
attr(out$hurs$Variable, "longname") <- "near-surface relative humidity"

summary(out$hurs$data)
#  Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
#  19.4    55.7    68.5    65.4    77.1    95.0  862224 


# To compute the accumulated precipitation per month it is necessary to multiply by:
# - total number of seconds in one hour: 3600
# - total number of hours in a day: 24
# - average number of days in a month: 365.25/12=30.44
# - change factor from meter to mm: 1000
out$prlr$data <- out$prlr$data * 3600 * 24 * 30.44 * 1000

summary(out$prlr$data)

# Create a new s2dv object with malaria suitability
out$malariaSuit <- s2dv_cube(data = ifelse(out$tas$data >= 14.5 & 
                                    out$tas$data <= 33 & 
                                    out$hurs$data >= 60 & 
                                    out$prlr$data >= 80, 1, 0),
                             lon = out$tas$lon,
                             lat = out$tas$lat,
                             Variable = list(varName = "malar_suit", level = NULL),
                             Dates = out$tas$Dates,
                             Datasets = out$tas$Datasets,
                             when = Sys.time(),
                             source_files = "see source files of tas, tdps and pr")

attr(out$malariaSuit$Variable, "units") <- "none"
attr(out$malariaSuit$Variable, "longname") <- "suitability for malaria transmission"

# Compute number of number of months per year that are suitable
# (i.e. suitability = 1)
malariaInd <- CST_TotalTimeExceedingThreshold(out$malariaSuit,
                                              op = ">=",
                                              threshold = 1)

# Sneak peek of the data
malariaInd$data[1, 1, 1, , ][15:20, 15:20]
#      [,1] [,2] [,3] [,4] [,5] [,6]
# [1,]    0    0    0    0    0    1
# [2,]    0    0    0    0    0    0
# [3,]    0    0    0    0    0    0
# [4,]    0    0    0    0    0    0
# [5,]    1    0    0    0    0    0
# [6,]    1    1    1    1    1    0

summary(malariaInd$data)
#  Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
#  0.00    0.00    0.00    0.63    1.00    6.00   71852

#Plot the map result
PlotLayout(PlotEquiMap, c('lat', 'lon'),
           var = malariaInd$data[1, 1, c(1, dim(malariaInd$data)[[3]]) , , ],
           nrow = 1, ncol = 2,
           lon = malariaInd$lon,
           lat = malariaInd$lat,
           filled.continents = FALSE,
           brks = seq(0, 12, by = 1),
           toptitle = "Number of months per year suitable for malaria transmission in the Iberian Peninsula",
           titles = c(as.character(year_in), as.character(year_fi)),
           title_scale = 0.4,
           coast_width = 2,
           filled.oceans = TRUE,
           country.borders = TRUE,
           intylat = 1,
           intxlon = 1)

# Time Series

pt <- data.frame(year = seq(year_in, year_fi, by = 1),
           ind = c(MeanDims(malariaInd$data, c('lon', 'lat'), na.rm = TRUE))) %>% 
  ggplot(aes(x = year, y = ind)) +
  geom_line() +
  scale_x_continuous(breaks = seq(year_in, year_fi, by = 1)) +
  geom_smooth(method = 'lm', formula = y ~ x, alpha = 0.3, linetype = "dashed", size = 0.3, se = FALSE) +
  labs(x = "Year", y = "Mean number of months suitable \n for malaria transmission") +
  theme_bw()

first <- mean(malariaInd$data[1, 1, 1, , ], na.rm = TRUE)
last <- mean(malariaInd$data[1, 1, dim(malariaInd$data)[[3]] , , ], na.rm = TRUE)
change <- round((last-first) / first * 100, 0)
change
