if(xg_nfold != FALSE) {
  for (i in 1:nrow(xg_settings)) {
    
    xg_tmp_strat = xg_settings[i,]
    
    if(xg_tmp_strat$yTrf == "log2") {
      xg_tmp_labels_train = log2(xg_labels_train)
    } else if(xg_tmp_strat$yTrf == "sqrt") {
      xg_tmp_labels_train = sqrt(xg_labels_train)
    } else {
      xg_tmp_labels_train = xg_labels_train
    }
    
    xg_tmp_model = xgb.cv(data = xg_data_train,
                          label = xg_tmp_labels_train,
                          nrounds = xg_tmp_strat$Rounds,
                          params = list(objective = "reg:squarederror",
                                        eta = xg_tmp_strat$Eta,
                                        max_depth = xg_tmp_strat$Depth,
                                        subsample = xg_tmp_strat$Rowsample,
                                        colsample_bytree = xg_tmp_strat$Colsample,
                                        gamma = xg_tmp_strat$Gamma,
                                        min_child_weight = xg_tmp_strat$MCW,
                                        nthread = xg_threads),
                          nfold = xg_nfold,
                          early_stopping_rounds = xg_stop)
    
    saveRDS(xg_tmp_model, paste0(xg_out_2,"/",xg_run_name,"_",i,".Rds"))
    
    rm(xg_tmp_strat, xg_tmp_labels_train, xg_tmp_model)
    gc(verbose = FALSE)
    
  }
} else {
  for (i in 1:nrow(xg_settings)) {
    
    xg_tmp_strat = xg_settings[i,]
    
    if(xg_tmp_strat$yTrf == "log2") {
      xg_tmp_labels_train = log2(xg_labels_train)
    } else if(xg_tmp_strat$yTrf == "sqrt") {
      xg_tmp_labels_train = sqrt(xg_labels_train)
    } else {
      xg_tmp_labels_train = xg_labels_train
    }
    
    xg_tmp_model = xgboost(data = xg_data_train,
                           label = xg_tmp_labels_train,
                           nrounds = xg_tmp_strat$Rounds,
                           objective = "reg:squarederror",
                           eta = xg_tmp_strat$Eta,
                           max_depth = xg_tmp_strat$Depth,
                           subsample = xg_tmp_strat$Rowsample,
                           colsample_bytree = xg_tmp_strat$Colsample,
                           gamma = xg_tmp_strat$Gamma,
                           min_child_weight = xg_tmp_strat$MCW,
                           nthread = xg_threads)
    
    saveRDS(xg_tmp_model, paste0(xg_out_2,"/",xg_run_name,"_",i,".Rds"))
    
    rm(xg_tmp_strat, xg_tmp_labels_train, xg_tmp_model)
    gc(verbose = FALSE)
    
  }
}
gc()
