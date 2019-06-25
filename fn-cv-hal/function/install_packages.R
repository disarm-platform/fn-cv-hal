install.packages(c('jsonlite',
                   'geojsonio',
                   'ranger',
                   'origami',
                   'devtools'))

library(devtools)
devtools::install_github("tlverse/hal9001", build_vignettes = FALSE)