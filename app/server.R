library(shiny)
library(wordcloud2)
library(tidyverse)
library(ggplot2)
library(plotly)
library(leaflet)
library(jsonlite)
library(mapview)
library(leafem)
library(revgeo)
library(ggmap)
library(zipcode)
library(geosphere)
library(data.table)
library(sp)
library(rgdal)
library(maptools)
library(KernSmooth)
library(raster)
library(dplyr)

## Load Data

dog2018 <- read.csv("DogLicensing_clean.csv")
dog2018$AnimalName  =  as.character(dog2018$AnimalName)
dog2018$BreedName = as.character(dog2018$BreedName)
dog2018$AnimalGender = factor(
  dog2018$AnimalGender,
  levels = c("F", "M", ""),
  labels = c("Female", "Male", "Unknown")
)

data_file_1 = "dog_park_clean.csv"
park_df  = read.csv(data_file_1)

data_file_2 = "UHF_42_DOHMH_2009_transfromed.json"
neigh_coord = fromJSON(data_file_2)
data("zipcode")
nbhd_zip <- read.csv("nbhd_zip_clean.csv")


shinyServer(function(input, output) {
  # Male Wordcloud
  output$Mwc <- renderWordcloud2({
    dog2018[dog2018$AnimalGender == "Male", ] %>%
      group_by(AnimalName) %>%
      tally() %>%
      arrange(desc(n)) %>%
      filter(AnimalName != "UNKNOWN" &
               AnimalName != "NAME NOT PROVIDED") %>%
      slice(1:input$Mnames) %>%
      wordcloud2(
        size = 0.6,
        rotateRatio = 0.2,
        backgroundColor = "#ffffff"
      )
    
  })
  
  # Female Wordcloud
  output$Fwc <- renderWordcloud2({
    dog2018[dog2018$AnimalGender == "Female", ] %>%
      group_by(AnimalName) %>%
      tally() %>%
      arrange(desc(n)) %>%
      filter(AnimalName != "UNKNOWN" &
               AnimalName != "NAME NOT PROVIDED") %>%
      slice(1:input$Fnames) %>%
      wordcloud2(
        size = 0.6,
        rotateRatio = 0.2,
        backgroundColor = "#ffffff"
      )
  })
  
  # Breed type
  output$Breed <- renderPlot({
    dog2018 %>%
      group_by(BreedName) %>%
      tally() %>%
      arrange(desc(n)) %>%
      filter(BreedName != "Unknown") %>%
      slice(1:15) %>%
      ggplot(aes(x = reorder(BreedName, n), y = n, fill = -n )) +
      geom_bar(stat = "identity" ) + 
      theme_classic() + 
      theme(legend.position="none") + 
      xlab("Breed Names") +
      ylab("Numbers") +
      coord_flip() +
      scale_y_continuous(expand = c(0, 0), breaks=seq(0, 7000, 1000)) 
  })
  
  # Age
  output$Age <- renderPlotly({
    dog2018 %>%
      group_by(Age) %>%
      tally() %>%
      arrange(desc(n)) %>%
      slice(1:18) %>%
      plot_ly(
        .,
        x =  ~ Age,
        y =  ~ n,
        type = "bar",
        text = ~ paste('Age: ', Age,
                       '</br> Count: ', n)
      ) %>%
      layout(
        title = "Age Distribution",
        xaxis = list(title = "Age",showgrid = F, showline = T),
        yaxis = list(title = "Count",showgrid = F, showline = T)

      )
  })
  
  # Gender
  output$gender <- renderPlotly({
    dog2018[dog2018$AnimalGender != "", ] %>%
      group_by(AnimalGender) %>%
      tally() %>%
      plot_ly(labels = ~ AnimalGender, values = ~ n) %>%
      add_pie(hole = 0.6) %>%
      layout(
        title = "Gender Distribution",
        showlegend = F,
        xaxis = list(
          showgrid = FALSE,
          zeroline = FALSE,
          showticklabels = FALSE
        ),
        yaxis = list(
          showgrid = FALSE,
          zeroline = FALSE,
          showticklabels = FALSE
        )
      )
  })
  
  
  # park density
  
  output$park_density <- renderLeaflet({kde <- bkde2D(park_df[ , c('park_long', 'park_lat')],
                                                      bandwidth=c(.0045, .0068), gridsize = c(200,200))
  KernelDensityRaster <- raster(list(x=kde$x1 ,y=kde$x2 ,z = kde$fhat))
  
  KernelDensityRaster@data@values[which(KernelDensityRaster@data@values < 1)] <- NA
  
  palRaster <- colorNumeric(c("#e5f5e0","#a1d99b","#31a354"), domain = KernelDensityRaster@data@values, na.color = "transparent")

  
  
  leaflet() %>%  addProviderTiles("Stamen.TonerLite") %>% 
    addRasterImage(KernelDensityRaster, 
                   colors = palRaster, 
                   opacity = .8) %>%
    addLegend(pal = palRaster, 
              values = KernelDensityRaster@data@values, 
              title = "Density of Parks")})
  
  
  # dog density 
  output$dog_density <- renderLeaflet({kde2 <- bkde2D(dog2018[ , c('longitude', 'latitude')],
                                                      bandwidth=c(.0045, .0068), gridsize = c(200,200))
  
  KernelDensityRaster2 <- raster(list(x=kde2$x1 ,y=kde2$x2 ,z = kde2$fhat))
  
  KernelDensityRaster2@data@values[which(KernelDensityRaster2@data@values < 1)] <- NA
  
  palRaster2 <- colorNumeric(c("#fee0d2","#fc9272","#de2d26"), domain = KernelDensityRaster2@data@values, na.color = "transparent")
 
  leaflet() %>% addProviderTiles("Stamen.TonerLite") %>% 
    addRasterImage(KernelDensityRaster2, 
                   colors = palRaster2, 
                   opacity = .8) %>%
    addLegend(pal = palRaster2, 
              values = KernelDensityRaster2@data@values, 
              title = "Density of Dogs")
  })
  

  
  #output$dog_density_map  = renderLeaflet({ 
    # dog number by neighbourhood 
    #num_by_neigh = dog2018 %>%  group_by(Neighborhood) %>% tally()%>% ungroup()
    #neigh_name_json = cbind( neigh_coord$features$properties$UHF_NEIGH[2:43], neigh_coord$features$geometry$coordinates[2:43])
    #colnames(neigh_name_json) = c("Neighborhood", "Cord")
    
  #map <- leaflet() %>%  addProviderTiles("Stamen.TonerLite") %>% setView(-73.983, 40.7639, zoom = 13) # default map, base layer
  #for (i in 2:43) {
    #map =  map %>% addPolygons(
    #  lng = neigh_coord$features$geometry$coordinates[[i]]$long,
    #  lat = neigh_coord$features$geometry$coordinates[[i]]$lat,
      #weight = 5,
    #  color = "black", fill = NA)
 #  }
  # })
  
  
  
  ###### Dog Walker MAP #######
   marker_opt <- markerOptions(opacity = 0.8, riseOnHover = T)

  output$map <- renderLeaflet({
    map <- leaflet() %>%  addProviderTiles("Stamen.TonerLite") %>% setView(-73.983, 40.7639, zoom = 13) # default map, base layer
    for (i in 2:43) {
      map =  map %>% addPolygons(
        lng = neigh_coord$features$geometry$coordinates[[i]]$long,
        lat = neigh_coord$features$geometry$coordinates[[i]]$lat,
        weight = 5,
        color = "black",
        fill = NA)
    }
    
    for (i in 1:87) {
      map = map %>% addMarkers(
        icon = makeIcon(
          iconUrl = "www/paw.png",
          iconWidth = 25,
          iconHeight = 25),
        lng = park_df$park_long[i],
        lat = park_df$park_lat[i],
        popup = park_df$park_name[i])
    }
    map
  })
  
  
  ## Observe mouse clicks
  observeEvent(input$map_click, {
    click <- input$map_click
    input_long = click$lng
    input_lat = click$lat
    input_zip_code = revgeo(longitude = input_long,
                            latitude = input_lat,
                            output = "hash")$zip
    input_zip_code = substr(input_zip_code, 1, 5)
    
    distance  = vector()
    nearest_park = character()
    indx = integer()
    
    for (i in 1:87) {
      # find the nearest dog park by distance
      distance[i] =  distm(c(input_long, input_lat),
                           c(park_df$park_long[i], park_df$park_lat[i]),
                           fun = distHaversine)
    }
    indx = which.min(distance)
    nearest_park = as.character(park_df[indx, "park_name"])
    distance_to_park = min(distance)
    
    # calculate the time to nearest park 
    # according to wikipedia: avg people walking speed:  1.4 meters per second
    walk_min =  distance_to_park/(1.4*60)
    
    leafletProxy("map")  %>% clearGroup("circles")  %>%  addCircles(lng=input_long, lat=input_lat, group='circles', color = 'red',  weight= 20 )
    
    # Output panal(click) summarize zipcode info 
    output$click_coord <-
      renderText(paste("Lat:", round(input_lat, 4), ", Long:", round(input_long, 4)))
    output$nearest_park <- renderText(nearest_park)
    output$distance_to_park <- renderText(paste(round( distance_to_park) , " m"))
    output$walk_min <- renderText(paste(round(walk_min) , " min"))
    output$dog_num <-
      renderText(paste(sum(dog2018$ZipCode == input_zip_code)))
    output$dog_age <-renderText(paste(round(mean(dog2018[dog2018$ZipCode == input_zip_code &
                                      dog2018$Age <= 18,]$Age), 0),"years old"))
    

     df_breed  = dog2018 %>% filter(dog2018$ZipCode==input_zip_code ) %>% group_by(BreedName) %>%  tally() %>% 
                arrange(desc(n)) %>%   filter(BreedName != "Unknown") %>%  top_n(3 ) %>% 
       dplyr::select(BreedName) %>% mutate_if(is.factor, as.character) 
    
     output$dog_breeds <- renderText({ HTML( paste(df_breed$BreedName[1], "</br>", df_breed$BreedName[2],"</br>", df_breed$BreedName[3])) }) 
    
    
  
    output$male_female_pie <-
      renderPlotly(
        dog2018[dog2018$AnimalGender != "" & 
                  dog2018$ZipCode == input_zip_code, ] %>%
          group_by(AnimalGender) %>%
          tally() %>%
          plot_ly(labels = ~ AnimalGender, values = ~ n, type = 'pie',
                  marker = list(colors = c('lightgreen', 'lightgrey'))) 
      )
    
  })
  
  # Tab 4  
  observeEvent(list(input$Dgender, input$Dbreed, input$Dage), {
    df_nbhd <-
      dog2018[dog2018$AnimalGender != input$Dgender &
                dog2018$BreedName == input$Dbreed &
                dog2018$Age >= as.numeric(input$Dage) - 2 &
                dog2018$Age <= as.numeric(input$Dage) + 2,] %>%
      group_by(Neighborhood) %>%
      tally() %>%
      arrange(desc(n)) %>% top_n(1) %>%
      dplyr::select(Neighborhood) %>% mutate_if(is.factor, as.character)
    best <- df_nbhd$Neighborhood[1]
    
    # Best Nbhd
    output$Bnbhd <- renderText({
      HTML( paste(best) ) 
    })
    
    # parks within the neighborhood
    output$Nparks <- renderText ({ 
      park <- park_df[park_df$park_neighb == best, ] %>% dplyr::select(park_name) %>%
        dplyr::select(park_name) %>% mutate_if(is.factor, as.character)
      i = integer()
      v = vector()
      for (i in 1:nrow(park)) {
        v[i] <- (park$park_name[i])
      }
      HTML( paste( v,  "</br>")) 
    })
    
    # Same Breed
    output$Ndogs <- renderText({ 
      sum(dog2018[dog2018$BreedName == input$Dbreed, ]$Neighborhood ==
            best) })
    
    # opposite gender
    output$Noppo <- renderText({
      sum(dog2018[dog2018$BreedName == input$Dbreed &
                    dog2018$AnimalGender != input$Dgender, ]$Neighborhood == best) })
    
    # same gender
    output$Nsame <- renderText({ 
      sum(dog2018[dog2018$BreedName == input$Dbreed &
                    dog2018$AnimalGender == input$Dgender, ]$Neighborhood == best)
    })
    
  })
  
  
  # Tab5 Data
  output$table1 <- DT::renderDataTable({
    DT::datatable(dog2018)
  })
  
  output$table2 <- DT::renderDataTable({
    DT::datatable(park_df)
  })
  
})
