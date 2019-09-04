# fn-cv-ml

Provided a GeoJSON of points with numbers examined and numbers positive, as well as a GeoJSON of prediction points, this function fits a highly adaptive lasso using 10-fold cross validation

## Parameters

A nested JSON object containing:
- `points` - {GeoJSON FeatureCollection} Required. Features with following properties:
  - `n_trials` - {integer} Required. Number of individuals examined/tested at each location (‘null’ for points without observations)
  - `n_positive` - {integer} Required. Number of individuals positive at each location (‘null’ for points without observations)
  - `id` - {string} Optional id for each point. Must be unique. If not provided, 1:n (where n is the number of Features in the FeatureCollection) will be used.
  - Additional covariate values as obtained using [this](https://github.com/disarm-platform/fn-covariate-extractor/blob/master/SPECS.md) function.

- `layer_names` - {array of strings} Optional. Default is to run with only latitude and longitude. Names relating to the covariate to use to model and predict. Corresponding layer must be present in `points`. See [here](https://github.com/disarm-platform/fn-covariate-extractor/blob/master/SPECS.md) for options.

- `importance` - {boolean}. Should random forest importance (gini) be returned? Defaults to `TRUE`.

## Constraints

- maximum number of points/features
- maximum number of layers is XX
- can only include points within a single country

## Response

A JSON containing

- `points` {GeoJSON FeatureCollection} with the following additional fields: 
	- `fitted_prediction` - predicted probability (equivalent of fitted values at observation points and predictions at points without observations)
	- `cv_predictions` - cross-validated predicted probability (only available at observation points)
	
- `importance` {array}. Gini impurity values for each covariate. Only returned if `importance` == `TRUE`