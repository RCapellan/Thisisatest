library(startR)
library(s2dv)
library(multiApply)

subtractTwoArrays <- function(x, y) {

  for (i in 1:dim(x)[1]) {
    x[i, , ] <- x[i, , ] - y
  }

  return (x)
}

multiplyTwoArrays <- function(x, y) {

  for (i in 1:dim(x)[1]) {
    for (j in 1:dim(x)[2]){
      x[i, j, ] <- x[i, j, ] * y[j, ]
    }
  }

  return (x)
}

averageTwoArrays <- function(x) {
  
  return ( rowMeans(x) )

}


# Create three arrays with multiple dimenssions
repos_exp <- paste0('/esarchive/exp/ecearth/a1tr/cmorfiles/CMIP/EC-Earth-Consortium/',
                    'EC-Earth3/historical/r24i1p1f1/Amon/$var$/gr/v20190312/',
                    '$var$_Amon_EC-Earth3_historical_r24i1p1f1_gr_$sdate$01-$sdate$12.nc')

arr <- Start(dat = repos_exp,
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

arr1 <- MeanDims(arr, dims = c('dat', 'var', 'sdate'),         na.rm = TRUE, drop = TRUE)
arr2 <- MeanDims(arr, dims = c('dat', 'var', 'sdate' ,'time'), na.rm = TRUE, drop = TRUE)
arr3 <- MeanDims(arr, dims = c('dat', 'var', 'sdate', 'lon'),  na.rm = TRUE, drop = TRUE)


# a) Take the second array and subtract it to each time step in the first 
# array.

subtract_data <- Apply( data = list(arr1, arr2), 
                        target_dims = list( c('time', 'lat', 'lon'), c('lat', 'lon') ),
                        fun = subtractTwoArrays,
                        guess_dim_names = FALSE
                      )$output1


# b) For each time step in the first array, all values along the 'lon'
# dimension for each 'lat' should be multiplied by the corresponding 
# value in the third array.

multiply_data <- Apply( data = list(arr1, arr2), 
                        target_dims = list( c('time', 'lat', 'lon'), c('lat', 'lon') ),
                        fun = multiplyTwoArrays,
                        guess_dim_names = FALSE
                      )$output1


# c) For each time step, the area average is computed (using the mean() 
# function, to which the additional parameters in '...' are forwarded).

average_data <- Apply( data = list(arr1, arr2), 
                        target_dims = list( c('time', 'lat', 'lon'), c('lat', 'lon') ),
                        fun = averageTwoArrays,
                        guess_dim_names = FALSE
                      )$output1

# d) If revert_order == TRUE, b) should be performed before a).

average_data <- Apply( data = list(arr1, arr2), 
                        target_dims = list( c('time', 'lat', 'lon'), c('lat', 'lon') ),
                        fun = averageTwoArrays,
                        guess_dim_names = FALSE
                      )$output1