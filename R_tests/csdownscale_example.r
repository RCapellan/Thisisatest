#################################################################
#################################################################
#################### EXAMPLES BSC LIBRARIES #####################
#################################################################
#################################################################


#########################################################
############## CSdownscale - Brief Summary ##############
#########################################################

#*************************************
#****** Libraries installation *******
#*************************************

# Create directories on R
options(warn=-1) #To supress warnings from now on
dir.create(paste0(getwd(),"/R_libs/"))
.libPaths(paste0(getwd(),"/R_libs/"))

# # Install packages necessaries for the CSdownscale
install.packages("devtools",destdir=(paste0(getwd(),"/R_libs/")), lib=(paste0(getwd(),"/R_libs/")), quiet=T)
library(devtools)

install.packages("startR", destdir=(paste0(getwd(),"/R_libs/")), lib=(paste0(getwd(),"/R_libs/")), quiet=T)
install.packages("multiApply", destdir=(paste0(getwd(),"/R_libs/")), lib=(paste0(getwd(),"/R_libs/")), quiet=T)
install.packages("CSTools", destdir=(paste0(getwd(),"/R_libs/")), lib=(paste0(getwd(),"/R_libs/")), quiet=T)
install.packages("ClimProjDiags", destdir=(paste0(getwd(),"/R_libs/")), lib=(paste0(getwd(),"/R_libs/")), quiet=T)
install.packages("s2dv", destdir=(paste0(getwd(),"/R_libs/")), lib=(paste0(getwd(),"/R_libs/")), quiet=T)
install.packages("easyVerification", destdir=(paste0(getwd(),"/R_libs/")), lib=(paste0(getwd(),"/R_libs/")), quiet=T)

install.packages("plyr", destdir=(paste0(getwd(),"/R_libs/")), lib=(paste0(getwd(),"/R_libs/")), quiet=T)
install.packages("nnet", destdir=(paste0(getwd(),"/R_libs/")), lib=(paste0(getwd(),"/R_libs/")), quiet=T)
install.packages("FNN", destdir=(paste0(getwd(),"/R_libs/")), lib=(paste0(getwd(),"/R_libs/")), quiet=T)

# # Load needed libraries
options(warn=-1) #To supress warnings from now on
.libPaths(paste0(getwd(),"/R_libs/")) #Define the path where the libraries are stored

suppressPackageStartupMessages(library(startR,quietly=TRUE, warn.conflicts=FALSE))
suppressPackageStartupMessages(library(s2dv,quietly=TRUE, warn.conflicts=FALSE))
suppressPackageStartupMessages(library(,quietly=TRUE, warn.conflicts=FALSE))
suppressPackageStartupMessages(library(multiApply,quietly=TRUE, warn.conflicts=FALSE))
suppressPackageStartupMessages(library(CSTools,quietly=TRUE, warn.conflicts=FALSE))
suppressPackageStartupMessages(library(ClimProjDiags,quietly=TRUE, warn.conflicts=FALSE))
suppressPackageStartupMessages(library(plyr,quietly=TRUE, warn.conflicts=FALSE))
suppressPackageStartupMessages(library(nnet,quietly=TRUE, warn.conflicts=FALSE))
suppressPackageStartupMessages(library(FNN,quietly=TRUE, warn.conflicts=FALSE))

print("*** THE LIBRARIES HAVE BEEN LOADED SUCCESSFULLY ***")


#*************************************
#********* Load CSdownscale **********
#*************************************

source("https://earth.bsc.es/gitlab/es/csdownscale/-/raw/master/R/Analogs.R")
source("https://earth.bsc.es/gitlab/es/csdownscale/-/raw/master/R/Interpolation.R")
source("https://earth.bsc.es/gitlab/es/csdownscale/-/raw/master/R/Intbc.R")
source("https://earth.bsc.es/gitlab/es/csdownscale/-/raw/master/R/Intlr.R")
source("https://earth.bsc.es/gitlab/es/csdownscale/-/raw/master/R/LogisticReg.R")
source("https://earth.bsc.es/gitlab/es/csdownscale/-/raw/master/R/Utils.R")

print("*** CSDOWNSCALE HAS BEEN LOADED SUCCESSFULLY ***")


#*****************************************
#********* Code for CSdownscale **********
#*****************************************

 #Select the name of the variable
var_name = 't2m' 

# Please select the reference period 
years <- c(1995:2015) 
#Please select the initialization month (from 1 to 12)
ini=11
#Obtaining the initialization dates array
sdate_forecast <- paste0(years,ini)

forecast_time <- indices(1:3) 

#Please, select the region boundaries
lons.min <- -40        
lons.max <- -32     
lats.min <- -11    
lats.max <- -3 

# '/esarchive/recon/ecmwf/era5land/monthly_mean/$VAR_NAME$_f1h/$VAR_NAME$_$YEAR$$MONTH$.nc')

exp_path <- paste0(getwd(),'/data/exp/ecmwf/system5c3s/monthly_mean/data_sample/$var$/$var$_$sdate$01.nc')
obs_path <- paste0(getwd(),'/data/reanalysis/ecmwf/era5land/monthly_mean/data_sample/$var$/$var$_$date$.nc')

# # Load the hindcast
options(warn=-1)
exp <- startR::Sta
                     # Select the path of the forecast
                     dat = exp_path,
                     # Variable of interest
                     var = var_name,
                     # Start dates, years that we are using to calibrate the hindcast with reanalysis
                     sdate = sdate_forecast,
                     # Select all ensemble members
                     ensemble = 'all',
                     # Forecast time
                    #  time = forecast_time,
                    #  latitude = values(list(lats.min, lats.max)),
                    #  latitude_reorder = Sort(decreasing = T),
                    #  longitude = values(list(lons.min, lons.max)),
                    #  # Reorder longitude points from [0,360] to [-180, 180]
                    #  longitude_reorder = CircularSort(-180,180),
                    #  synonims = list(latitude = c('lat', 'latitude'),
                    #                  longitude = c('lon', 'longitude'),
                    #                  ensemble=c('member','ensemble','number')),
                    #  return_vars = list(latitude = 'dat',
                    #                     longitude = 'dat',
                    #                     time = 'sdate'),
                     retrieve = TRUE)


# Here, the dates that will be used to retrieve the reanalysis are obtained.
# They will be the same as the hindcast times.
dates <- attr(exp, 'Variables')$common$time

#Giving dates format
dates_file <- format(dates, '%Y%m') 

#Specifying the dimensions
dim(dates_file) <- c(sdate = length(sdate_forecast),
                  time = length(forecast_time))


obs <- Start(# load observational (reanalysis) data
             dat = obs_path,
             # Variable of interest
             var = var_name,
             date = dates_file,
             # time = values(dates),
             latitude = values(list(lats.min,lats.max)),
             latitude_reorder = Sort(decreasing = T),
             longitude = values(list(lons.min, lons.max)),
             longitude_reorder = CircularSort(-180,180),
             synonims = list(longitude = c('lon', 'longitude'),
                             latitude = c('lat', 'latitude')),
             split_multiselected_dims = TRUE,
             return_vars = list(time = 'date',
                                latitude = 'dat',
                                longitude = 'dat'),
             retrieve = TRUE)

exp_lats <- attr(exp, "Variables")$dat1$latitude
exp_lons <- attr(exp, "Variables")$dat1$longitude
obs_lats <- attr(obs, "Variables")$dat1$latitude
obs_lons <- attr(obs, "Variables")$dat1$longitude


exp <- MeanDims(exp, dims = 'time', na.rm = TRUE, drop = FALSE)
obs <- MeanDims(obs, dims = 'time', na.rm = TRUE, drop = FALSE)


clim_exp <- MeanDims(exp, dims = c('sdate', 'ensemble'), na.rm = TRUE)
clim_obs <- MeanDims(obs, dims = c('sdate'), na.rm = TRUE)
exp_anom <- Ano(data = exp, clim = clim_exp)
obs_anom <- Ano(data = obs, clim = clim_obs)


# It´s not finished yet, it does not work for the input files are not well defined