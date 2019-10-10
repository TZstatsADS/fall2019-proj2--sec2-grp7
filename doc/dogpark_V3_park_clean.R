library(geojsonio)
library(geojsonR)
library(leaflet)
library(jsonlite)
library(plyr)
library(proj4)
library(revgeo)


data_file_1 = 'dog_park_clean.csv'
park_df  = read.csv(data_file_1)
data_file_2 = 'UHF_42_DOHMH_2009_cleaned.json'
neigh_df = fromJSON(data_file_2)


# basemap 
i = integer()
l = list()    
for (i in 1:42) {
  # ignore the first since the neighbourhood associated with is NA 
  MyArray = neigh_df$features$geometry$coordinates[i+1][[1]]
  xy  = as.data.frame( alply(MyArray,1) ) 
  # Transformed data
  proj4string <- "+proj=lcc +lat_1=40.66666666666666 +lat_2=41.03333333333333 +lat_0=40.16666666666666 +lon_0=-74 +x_0=300000 +y_0=0 +datum=NAD83 +units=us-ft +no_defs"
  pj <- project(xy, proj4string, inverse=TRUE)
  lonlat <- data.frame(long=pj$x, lat=pj$y)
  l[[neigh_df$features$properties$UHF_NEIGH[i+1]]] = lonlat
}

basemap <- leaflet() %>% addTiles()
for (i in 1:42){ 
  basemap <- addPolygons(basemap, data = as.matrix(l[[i]]),fill=NA)
} 
basemap 


# parkmap
# add paw icon
pawIcons <- iconList( pawprint = makeIcon("paw.png", 18, 18))
parkmap = basemap 
for (i in 1:87){
  parkmap = parkmap %>% addMarkers(icon = pawIcons,
                                   lng = park_df$park_long[i],
                                   lat= park_df$park_lat[i], 
                                   popup =park_df$park_name[i] ) 
} 
parkmap 







