
# Helpers for cv-hal

folds_list_to_df_list <- function(fold, df) {
  train = df[fold$training_set,]
  valid = df[fold$validation_set,]
  list(train = train, 
       valid = valid)
}


fit_hal_parallel <- function(folds_df_list_fold, 
                             X_var,
                             n_pos_var,
                             n_neg_var){
  
  X <- folds_df_list_fold$train[,X_var]
  Y <- cbind(folds_df_list_fold$train[,n_neg_var],
             folds_df_list_fold$train[,n_pos_var])
  pred_data <- folds_df_list_fold$valid[,X_var]
  
  hal_mod <- fit_hal(X, Y, family = "binomial", yolo = FALSE)
  predict(hal_mod, new_data = pred_data)
}