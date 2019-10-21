# Project 2: Shiny App Development Version 2.0

### [Project Description](doc/project2_desc.md)

![](doc/figs/background.jpg)

In this second project of GR5243 Applied Data Science, we develop a version 2.0 of an *Exploratory Data Analysis and Visualization* shiny app on a topic of your choice using [NYC Open Data](https://opendata.cityofnewyork.us/) or U.S. government open data released on the [data.gov](https://data.gov/) website. See [Project 2 Description](doc/project2_desc.md) for more details.  

The **learning goals** for this project is:

- business intelligence for data science
- study legacy codes and further development
- data cleaning
- data visualization
- systems development/design life cycle
- shiny app/shiny server


## Project Title: DogPark
Term: Fall 2019

+ Team # 7
+ **Projec title**: DogPark
+ **Projec Link**: [DogPark Shiny App](https://yw3211.shinyapps.io/DogPark/)
 + Team members
	+ Qiqi Wu [qw2273@columbia.edu](qw2273@columbia.edu)
	+ Yakun Wang [yw3211@columbia.edu](yw3211@columbia.edu)
	+ Sen Dai [sd3227@columbia.edu](sd3227@columbia.edu)
	+ Yuhan Gong [yg2622@columbia.edu](yg2622@columbia.edu)
	+ Sam Unger [sku2105@columbia.edu](sku2105@columbia.edu)

+ **Project summary**: The DogPark ShinyApp helps you visualize dog and dog park data for all of New York City! In particular, we wanted to give NYC dog lovers and dog owners a user-friendly way to find an apartment location that best combines their neighborhood interests with easy access to fun parks for their canine pals. Enjoy!

+ **The app includes**:
  + Introduction
    + This tab describes the goal of the app and details its individual tabs
  + Overview
    + The 1. Popular Dog Names tab displays wordclouds of male and female dog names in NYC
    + The 2. Popular Dog Breeds tab has a bar chart of the number of dogs of each breed in NYC
    + The 3. Age & Gender Distribution tab shows stats on dog age and gender – hover for details!
    + The 4. Distribution of Dogs and Parks details how dog parks are spread throughout the city
  + Map
    + This is an interactive map of NYC with dog parks clearly marked across the city
    + Click for anywhere on the map for additional location info
  + Dog Dating Plan
    + By entering your dog's basic information, we can pick the best neighbrhood for your dog to live
  + Data 
    + This tab provides more info on the datasets used for this app
  + Contact Us
    + The Contact Us page provides more info on us, the app creators, and how to get in touch


+ **Contribution statement**: 
    + **Sam Unger**: Topic idea, Dataset collection, Introduction tab, Data tab, and Contact Us tab
    + **Qiqi Wu**: Data cleaning, Map tab (plot, neighborhood border, map click, output window), DogMate tab, App Publication, GitHub management, Presentation 
    + **Yakun Wang**: Data cleaning, ui Design, Overview tab (tab1-3), Map tab (output window), DogMate tab, GitHub management
    + **Yuhan Gong**: Neiborhood dataset, Overview tab (tab4), Map tab (decoration)
    + **Sen Dai**: css style, shinyapp decoration (font, backgroud). 

Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── app/
├── lib/
├── data/
├── doc/
└── output/
```

Please see each subfolder for a README file.

