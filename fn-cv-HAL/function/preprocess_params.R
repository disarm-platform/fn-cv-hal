library(sf)

function(params) {
  # Load points into memory
  params$points <- st_read(as.json(params[['points']]), quiet = TRUE)
  
  # Check the layer names are present in points
  layer_names <- params[['layer_names']]
  
  if(!(sum(layer_names %in% names(params$points)) == length(layer_names))){
    stop('Not all layer_names present in points')
  }
  
  return(params)
}