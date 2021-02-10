if(xg_nfold != FALSE) {
  for (i in 1:nrow(xg_settings)) {
    
    xg_tmp_strat = xg_settings[i,]
    
    xg_tmp_model = xgb.cv(data = xg_data_train,
                          label = xg_labels_train,
                          nrounds = xg_tmp_strat$Rounds,
                          params = list(objective = "multi:softprob",
                                        num_class = length(unique(xg_labels_train)),
                                        eta = xg_tmp_strat$Eta,
                                        max_depth = xg_tmp_strat$Depth,
                                        subsample = xg_tmp_strat$Rowsample,
                                        colsample_bytree = xg_tmp_strat$Colsample,
                                        gamma = xg_tmp_strat$Gamma,
                                        min_child_weight = xg_tmp_strat$MCW,
                                        nthread = xg_threads,
                                        eval_metric = "merror"),
                          nfold = xg_nfold,
                          early_stopping_rounds = xg_stop)
    
    saveRDS(xg_tmp_model, paste0(xg_out_2,"/",xg_run_name,"_",i,".Rds"))
    
    rm(xg_tmp_strat, xg_tmp_model)
    gc(verbose = FALSE)
    
  }
} else {
  for (i in 1:nrow(xg_settings)) {
    
    xg_tmp_strat = xg_settings[i,]
    
    xg_tmp_model = xgboost(data = xg_data_train,
                           label = xg_labels_train,
                           nrounds = xg_tmp_strat$Rounds,
                           objective = "multi:softprob",
                           eval_metric = "merror",
                           num_class = length(unique(xg_labels_train)),
                           eta = xg_tmp_strat$Eta,
                           max_depth = xg_tmp_strat$Depth,
                           subsample = xg_tmp_strat$Rowsample,
                           colsample_bytree = xg_tmp_strat$Colsample,
                           gamma = xg_tmp_strat$Gamma,
                           min_child_weight = xg_tmp_strat$MCW,
                           nthread = xg_threads)
    
    saveRDS(xg_tmp_model, paste0(xg_out_2,"/",xg_run_name,"_",i,".Rds"))
    
    rm(xg_tmp_strat, xg_tmp_model)
    gc(verbose = FALSE)
    
  }
}
gc()