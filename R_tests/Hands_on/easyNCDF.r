library(easyNCDF)
library(abind)

# Path for monthly mean pressure
path = "/esarchive/recon/ecmwf/era5/monthly_mean/psl_f1h"

arr_files <- list.files(path = path, pattern = "2019.*\\.nc$", full.names = TRUE, recursive = TRUE)
arr_files <- sort(arr_files)

m_result <- NaN
for (var in arr_files){
    # Test some methods
    dims <- easyNCDF::NcReadDims(var) # Dimensions of the Nc file
    vars <- easyNCDF::NcReadVarNames(var)

    # Open the file
    nc_data <- easyNCDF::NcToArray(var, vars_to_read = vars)

    # Open the different variables (arrays)
    latitudes <- attr(nc_data, "variables")$lat$dim[[1]]$vals
    longitudes <- attr(nc_data, "variables")$lon$dim[[1]]$vals
    time <- array(attr(nc_data, "variables")$time$units)

    # Alguna forma de acceder a las variables por el nombre
    psl <- nc_data[2, 1, , , ]

    # Join the different matrix into one
    if (is.nan(m_result)) {
        m_result <- psl
        # browser()
    } else {
        # browser()
        m_result <- abind(m_result, psl, along=3)
    }
}

# Save the array into an Nc file
ArrayToNc(arrays = list(psl = m_result), file_path = 'test.nc')
