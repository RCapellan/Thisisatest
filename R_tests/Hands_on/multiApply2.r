library(startR)
library(s2dv)
library(multiApply)

subtractTwoArrays <- function(x, y) {
  return (x - y)
}


# Array with dimensions 'time', 'lat', and 'lon'
arr1 <- array(data = 1:(2*3*4), dim = c(2, 3, 4),
              dimnames <- list(
                time = c("time1", "time2"),
                lat = c("lat1", "lat2", "lat3"),
                lon = c("lon1", "lon2", "lon3", "lon4")
            ))

# Array with dimensions 'lat' and 'lon'
arr2 <- array(data = 1:(3*4), dim = c(3, 4),
              dimnames = list(
                lat = c("lat1", "lat2", "lat3"),
                lon = c("lon1", "lon2", "lon3", "lon4")
            ))

# Array with dimensions 'time' and 'lat'
arr3 <- array(data = 1:(2*3), dim = c(2, 3),
              dimnames = list(
                time = c("time1", "time2"),
                lat = c("lat1", "lat2", "lat3")
            ))

# a) Take the second array and subtract it to each time step in the first array.

# subtract_data <- Apply( data = list(arr1, arr2), 
#                         target_dims = list( c(1: length(dim(arr2))), c(1: length(dim(arr2))) ),
#                         fun = subtractTwoArrays,
#                         guess_dim_names = FALSE)$output1




############################################################################
############################################################################
############################################################################
# process_arrays <- function(x, y) {
#   return (x + y)
# }

# A <- array(1:20, c(5, 2, 2))
# B <- array(1:20, c(5, 2, 2))

# D <- Apply(data = list(A, B), 
#            target_dims = list(c(1: length(dim(A))), c(1: length(dim(B)))),
#            fun = process_arrays)$output1





time <- 1:10
lat <- 1:20
lon <- 1:30

# Create an array with named dimensions
multi_index_array <- array(0, dim = c(length(time), length(lat), length(lon)),
                           dimnames = list(time = as.character(time),
                                           lat = as.character(lat),
                                           lon = as.character(lon)))
