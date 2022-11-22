library(raster)
library(ncdf4)
library(ggplot2)
library(tidyverse)
library(lubridate)

rm(list=ls())

#read ncdf file
nc_file <-  list.files(recursive = TRUE, pattern = "\\.nc$", full.names = TRUE) # get the file 

#list 
ncs <- list()

for(n in 1:length(nc_file)){

nc <- nc_open(nc_file[n]) # read it in 
vars <- names(nc$var) # states the variables in the netcdf
vardir <- paste0("./output/",vars)
dir.create(vardir,showWarnings = FALSE)
print(nc) # check the structure of the netcdf

#get x and y
lons <- ncvar_get(nc = nc, varid =  "longitude")
lats <- ncvar_get(nc = nc, varid =  "latitude")

#get times
times <- ncvar_get(nc = nc, varid =  "time")
times <- as.POSIXct(times, origin = "1970-01-01", tz = "UTC") #hours elapsed since the date - needs converting to seconds so hence the *3600
times.l <- length(times)


# create monthly raster 
for(i in 1:length(times)){
  
  r <- raster(x = nc_file[n], #transpose the matrix to get the correct x = lon and y = lat (other way around for some reason)
              level = 1,
              band = i,
              xmn = min(lons), 
              xmx = max(lons), 
              ymn = min(lats), 
              ymx= max(lats), 
              crs = "+proj=longlat +ellps=WGS84", 
              transpose = TRUE)
  
  filename <- paste0(vardir,"/",vars,"-monthly-",as.Date(times[i]))
  writeRaster(r, filename = filename, overwrite = TRUE, format = "GTiff")
  plot(r) 
  
  }


### 
# EXAMPLE OF HOW TO OVERLAY POINTS (RECIEVERS) AND EXTRACT ENVIRONMENTAL DATA FROM THE RASTER BRICK

#brick of all the depths
#b <- brick(x = nc_file[n], #transpose the matrix to get the correct x = lon and y = lat (other way around for some reason)
#           level = 1,
#           xmn = min(lons), 
#           xmx = max(lons), 
#           ymn = min(lats), 
#           ymx= max(lats), 
#           crs = "+proj=longlat +ellps=WGS84", 
#           transpose = TRUE)


# point locations 
#lats <- seq(from = 48.5, by = 0.2, length.out = 12)
#lons <- seq(from = -10, by = 1, length.out = 12)
#pts <- SpatialPoints(coords = cbind(lons,lats)) 

# CHECK WHERE YOUR POINTS ARE
#plot(r)
#points(pts)

# create the dataframe  
#df <- raster::extract(x=b,y=pts,df = TRUE) %>% 
#              mutate(lat = lats) %>% mutate(lon = lons) %>% select(!ID) %>% 
#              pivot_longer(.,cols = c(1:all_of(times.l)), names_to = "date", values_to = vars) %>% 
#              mutate_at(vars(date), as.POSIXct, format = "X%Y.%m.%d") %>% mutate(year = lubridate::year(date))   


#save to object
#ncs[[n]] <- df

# id
print(nc_file[n])

} 

# WRITE YOUR DATA FROM THE OVERLAY
#bind together
#ncs <- plyr::rbind.fill(ncs)

# write csv
#write.csv(ncs, file = "FILENAME", row.names = FALSE)

