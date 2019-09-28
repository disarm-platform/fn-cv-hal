library(hal9001)
library(origami)
library(parallel)

source("function/helpers.R")

function(params) {
  # run function and catch result
  points <- params[['points']]
  layer_names <- params[['layer_names']]
  model_type <- "randomforest"

  points_df <- as.data.frame(points)
  points_df$n_negative <- points_df$n_trials - points_df$n_positive
  
  # Filter out training data
  points_df$row_id <- 1:nrow(points_df)
  with_data <- which(!(is.na(points_df$n_negative)))
  points_df_train <- points_df[with_data,]
  
  # Create folds
  set.seed(1981)
  folds_list <- origami::make_folds(points_df_train)
  folds_df_list <- lapply(folds_list, folds_list_to_df_list, df = points_df_train)
  
  # Save validation indeces for later
  valid_indeces <- unlist(sapply(folds_list, function(x){x$validation_set}))
  
  if(model_type == "hal"){
  # Now apply HAL to each fold in parallel 
  cv_predictions <- parallel::mclapply(folds_df_list, FUN = fit_hal_parallel,
                             mc.cores = detectCores() - 1,
                             X_var = layer_names,
                             n_pos_var = "n_positive",
                             n_neg_var = "n_negative")
  
  # Add cv predictions back onto data.frame
  points_df_train$cv_preds[valid_indeces] <- unlist(cv_predictions)
  
  # Now fit HAL to full dataset and create fitted predictions
  hal_fit <- fit_hal(X = points_df_train[,layer_names], 
                     Y = cbind(points_df_train$n_negative,
                               points_df_train$n_positive), 
                     family = "binomial", yolo = FALSE)
  points$fitted_predictions <- predict(hal_fit, new_data = points_df[,layer_names])
  points$cv_predictions <- NA
  points$cv_predictions[points_df_train$row_id[valid_indeces]] <- unlist(cv_predictions)
  }
  
  
  if(model_type == "randomforest"){
    
    cv_predictions <- parallel::mclapply(folds_df_list, FUN = fit_rf_parallel,
                                         mc.cores = detectCores() - 1,
                                         X_var = layer_names,
                                         n_pos_var = "n_positive",
                                         n_neg_var = "n_negative")
    
    # Add cv predictions back onto data.frame
    points_df_train$cv_preds[valid_indeces] <- unlist(cv_predictions)
    
    # Now fit RF to full dataset and create fitted predictions
    Y <- factor(c(rep(0, nrow(points_df_train)),
                  rep(1, nrow(points_df_train))))
    
    X <- points_df_train[,layer_names]
    X <- rbind(X, X)
    rf_formula <- as.formula(paste("Y", "~", paste(layer_names, collapse = "+")))
    rf_fit <- ranger(rf_formula,
                     data = points_df_train,
                     probability = TRUE,
                     importance = 'impurity',
                     case.weights = c(points_df_train$n_negative,
                                      points_df_train$n_positive))
    
    fitted_predictions <- predict(rf_fit, points_df[,layer_names])
    points$fitted_predictions <- fitted_predictions$predictions[,2]
    points$cv_predictions <- NA
    points$cv_predictions[points_df_train$row_id[valid_indeces]] <- unlist(cv_predictions)
  }
  return(list(points = geojson_list(points),
              importance = data.frame(rf_fit$variable.importance)))
}
