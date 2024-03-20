#---------------------------------------------------------------------
# This script tells you how to load experimental and observational data in a 
# consistent way, facilating the following comparison. We use the attributes of
# the experimental data to define the selectors of obs Start() call, so they 
# can have the same dimension structure.

# Spatial dimensions:
# The exp and obs data happen to have the same spatial resolution (256x512) and
# the grids are not shifted, so we don't need to regrid them. However, their latitude
# orders are opposite. exp has ascending order while obs has descending order. 
# To make them consistent, we need to use "_reorder" parameter. In fact, it is
# always recommended using "lat_reorder" and "lon_reorder" to ensure you get
# the expected latitude and longitude.

# Temporal dimensions:
# The exp and obs files have different date/time structure. exp has one file per year and 
# each file has 12 time steps. obs has one file per month and each file has 1 time step.
# To shape the obs array as exp, we need to use the time attribute of exp to define
# the date/time selector of obs. You can see how to use parameter '*_across', 'merge_across_dims',
# and 'split_multiselected_dims' to achieve the goal.

#---------------------------------------------------------------------
library(startR)
library(s2dv)
library(multiApply)

# exp
repos_exp <- paste0('/esarchive/exp/ecearth/a1tr/cmorfiles/CMIP/EC-Earth-Consortium/',
                    'EC-Earth3/historical/r24i1p1f1/Amon/$var$/gr/v20190312/',
                    '$var$_Amon_EC-Earth3_historical_r24i1p1f1_gr_$sdate$01-$sdate$12.nc')

exp <- Start(dat = repos_exp,
             var = 'tas',
             sdate = as.character(c(2005:2008)),
             time = indices(1:3),
             lat = 'all',
             lat_reorder = Sort(),
             lon = 'all',
             lon_reorder = CircularSort(0, 360),
             synonims = list(lat = c('lat', 'latitude'),
                             lon = c('lon', 'longitude')),
             return_vars = list(lon = NULL,
                                lat = NULL,
                                time = 'sdate'),
             retrieve = TRUE)

# Retrieve attributes for observational data retrieval.
## Because latitude order in experiment is [-90, 90] but in observation is [90, -90],
## latitude values need to be retrieved and used below.
lats <- attr(exp, 'Variables')$common$lat
lons <- attr(exp, 'Variables')$common$lon
## The 'time' attribute is a two-dim array
dates <- attr(exp, 'Variables')$common$time
dim(dates)
#sdate time 
#    4    3 
dates
# [1] "2005-01-16 12:00:00 UTC" "2006-01-16 12:00:00 UTC"
# [3] "2007-01-16 12:00:00 UTC" "2008-01-16 12:00:00 UTC"
# [5] "2005-02-15 00:00:00 UTC" "2006-02-15 00:00:00 UTC"
# [7] "2007-02-15 00:00:00 UTC" "2008-02-15 12:00:00 UTC"
# [9] "2005-03-16 12:00:00 UTC" "2006-03-16 12:00:00 UTC"
#[11] "2007-03-16 12:00:00 UTC" "2008-03-16 12:00:00 UTC"

#-------------------------------------------

# obs
# 1. For lat, use the experiment attribute or reversed indices. For lon, it is not necessary 
# because their lons are identical, but either way works.
# 2. For dimension 'date', it is a vector involving the 3 months (ftime) of the four years (sdate).
# 3. Dimension 'time' is assigned by the matrix, so we can split it into 'sdate' and 'time' 
# by 'split_multiselected_dims'.
# 4. Because 'time' is actually across all the files, so we need to specify 'time_across'. 
# Then, use 'merge_across_dims' to make dimension 'date' disappears. 
# At this moment, the dimension is 'time = 12'. 
# 5. However, we want to seperate year and month (which are 'sdate' and 'ftime' in 
# experimental data). So we use 'split_multiselected_dims' to split 'time' into the two dimensions.

repos_obs <- '/esarchive/recon/ecmwf/erainterim/monthly_mean/$var$_f6h/$var$_$date$.nc'

obs <- Start(dat = repos_obs,
             var = 'tas',
             date = unique(format(dates, '%Y%m')),
             time = values(dates),  #dim: [sdate = 4, time = 3]
             lat = 'all',
             lat_reorder = Sort(),
             lon = 'all',
             lon_reorder = CircularSort(0, 360),
             time_across = 'date',
             merge_across_dims = TRUE,
             split_multiselected_dims = TRUE,
             synonims = list(lat = c('lat', 'latitude'),
                             lon = c('lon', 'longitude')),
             return_vars = list(lon = NULL,
                                lat = NULL,
                                time = 'date'),
             retrieve = TRUE)

#====================================================
# Check the attributes. They should be all identical.
#====================================================
dates_adjust <- dates + 86400*15
dates_adjust

obs2 <- Start(dat = repos_obs,
             var = 'tas',
             date = unique(format(dates, '%Y%m')),
             time = values(dates_adjust),  # use the adjust ones
             lat = 'all',
             lat_reorder = Sort(),
             lon = 'all',
             lon_reorder = CircularSort(0, 360),
             time_across = 'date',
             merge_across_dims = TRUE,
             split_multiselected_dims = TRUE,
             synonims = list(lat = c('lat', 'latitude'),
                             lon = c('lon', 'longitude')),
             return_vars = list(lon = NULL,
                                lat = NULL,
                                time = 'date'),
             retrieve = TRUE)


# obs3 <- Start(dat = repos_obs,
#              var = 'tas',
#              date = unique(format(dates, '%Y%m')),
#              time = values(dates),
#              lat = 'all',
#              lat_reorder = Sort(),
#              lon = 'all',
#              lon_reorder = CircularSort(0, 360),
#              time_across = 'date',
#              time_tolerance = as.difftime(15, units = 'days'), 
#              merge_across_dims = TRUE,
#              split_multiselected_dims = TRUE,
#              synonims = list(lat = c('lat', 'latitude'),
#                              lon = c('lon', 'longitude')),
#              return_vars = list(lon = NULL,
#                                 lat = NULL,
#                                 time = 'date'),
#              retrieve = TRUE)



latitudes <-  attr(obs, "Variables")$common$tas$dim[[1]]$vals
longitudes <- attr(obs, "Variables")$common$tas$dim[[2]]$vals

print('####################################################')
print('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@')
print('####################################################')

data <- list(
            obs,
            obs2
        )

mean_function <- function(x, y) {
    result <- (x + y) / 2

    return (result[,,,])
}

# - Calculate spatial mean of the two arrays using apply(). 
# - Check the output dimensions and class.
t1 <- Sys.time()

mean_data <- multiApply::Apply(data = list(obs[,,,,,], obs[,,,,,]),
                               target_dims = list(c(1: length(dim(obs))), c(1: length(dim(obs)))),
                               output_dims = NULL,
                               fun = mean_function)$output1

t2 <- Sys.time()

print('-> 1º Execution time')
print(t2 - t1)

# - Reshape the two arrays: (1) Remove the dimensions that have length = 1 by function drop(). 
# (2) Combine the 'sdate' and 'time' dimensions; 
# the dimension should become [time = 12, lat = 256, lon = 512]. 
# - Name the two new objects as 'exp2' and 'obs2'.

obs_new  <- MeanDims(obs, dims = c('dat', 'var'), na.rm = TRUE, drop = TRUE)
obs2_new <- MeanDims(obs, dims = c('dat', 'var'), na.rm = TRUE, drop = TRUE)

new_dims <- c(dim(obs_new)[2] * dim(obs_new)[1], dim(obs_new)[3], dim(obs_new)[4])
obs_new <- array(apply(obs_new, c(1, 2), sum), dim = new_dims)

# - Use multiApply::Apply to do the same calculation to exp2 and obs2. 
# Check the dimensions and the class of the outputs.
# This is what is done in the upper part


# - Calculate time average of exp2 and obs2 using Apply(). 
# - Use the timer below to measure the consuming time. 
# - Assign parameter "ncores = 8" in Apply() and see the difference.

t1 <- Sys.time()

mean_data <- multiApply::Apply(data = list(obs[,,,,,], obs[,,,,,]),
                               target_dims = list(c(1: length(dim(obs))), c(1: length(dim(obs)))),
                               output_dims = NULL,
                               fun = mean_function,
                               ncores = 8)$output1

t2 <- Sys.time()
print('-> 2º Execution time')
print(t2 - t1)
