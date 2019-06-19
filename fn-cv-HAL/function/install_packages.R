install.packages(c('jsonlite',
                   'geojsonio',
                 'origami',
                 'parallel',
                 'devtools'))

library(devtools)
devtools::install_github("tlverse/hal9001", build_vignettes = FALSE)