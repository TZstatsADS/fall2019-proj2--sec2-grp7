library(tidyverse)
library(proj4)
library(revgeo)
library(geojsonio)
library(geojsonR)

data_file = "NYC Parks Dog Runs.geojson" 
park_js = FROM_GeoJson(url_file_string = data_file)

i = integer()
dog_park_name = vector() 
dog_park_zip  = list()
dog_park_long = vector() 
dog_park_lat = vector() 

for (i in 1:87){
  dog_park_name[i]  = as.character( park_js$features[[i]]$properties$name)
  dog_park_zip[i] = park_js$features[[i]]$properties$zipcode
  dog_park_long[i] = colMeans(park_js$features[[i]]$geometry$coordinates[[1]])[1]
  dog_park_lat[i] = colMeans(park_js$features[[i]]$geometry$coordinates[[1]])[2]
} 

# replace  Null zip code in orignal park geojson file 
# by converted coordinateds to zip code using revgeo 

dog_park_coord_to_zip = vector()
dog_park_zip_final = vector()

for (i in 1:87){
  if (is.null(dog_park_zip[[i]][1]) ){
  dog_park_coord_to_zip[i]= revgeo(longitude =dog_park_long[i], 
                                   latitude =dog_park_lat[i], 
                                   output='hash', item = 'zip')$zip
   dog_park_zip_final[i] = dog_park_coord_to_zip[i]
  }else if ( dog_park_zip[[i]][1] == "Null" ){
      dog_park_coord_to_zip[i]= revgeo(longitude =dog_park_long[i], 
                                       latitude =dog_park_lat[i], 
                                       output='hash', item = 'zip')$zip
      dog_park_zip_final[i] = dog_park_coord_to_zip[i]
    }else{
    dog_park_zip_final[i] = dog_park_zip[i]
  }
}

# import zip code dataset 
nyc_neigh_zip <- read.csv('nyc_zipcode.csv')
nyc_neigh_zip = nyc_neigh_zip %>%
  mutate(zipcode = strsplit(gsub("[][\"]", "", nyc_neigh_zip$ZIP.Codes), ", ")) %>%
  unnest(zipcode)

# check to see if all dog parks' zip code are in the our zip code list 
all( dog_park_zip_final %in% nyc_neigh_zip$zipcode)

# find which neighbourhood the dog park belongs to by its zip code 
dog_park_neigh_final = vector()
for (i in 1:87){
  dog_park_neigh_final[i]=  nyc_neigh_zip %>% filter(zipcode == dog_park_zip_final[[i]] ) %>% select(Neighborhood)  
  dog_park_neigh_final[i] = as.character(dog_park_neigh_final[[i]])
}

dog_park_new  =   tibble (park_name = dog_park_name,
                          park_long = dog_park_long, 
                          park_lat =  dog_park_lat, 
                          park_neighb = as.character(dog_park_neigh_final), 
                          park_zipcode  = as.character(dog_park_zip_final))


write.csv(dog_park_new, file = "dog_park_clean.csv",row.names=FALSE) 

#   read_csv("dog_park_clean.csv")
