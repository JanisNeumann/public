if(xg_nfold != FALSE) {
  
  colnames(xg_settings) = c("y_Transformation", "Learning_Rate", "Max_Tree_Depth",
                            "Subsampling_Cells", "Subsampling_Genes", "Gamma", "Min_Child_Weight", "Max_Iterations")
  xg_run_results = cbind.data.frame(#ID = 1:nrow(xg_settings),
    xg_settings,
    Iterations = NA,
    Train_RMSE = NA,
    CV_RMSE = NA)
  
  for (j in 1:nrow(xg_run_results)) {
    
    xg_tmp_model = readRDS(paste0(xg_out_2,"/",xg_run_name,"_",j,".Rds"))
    
    xg_run_results$Iterations[j] = xg_tmp_model$niter
    xg_run_results$Train_RMSE[j] = xg_tmp_model$evaluation_log$train_rmse_mean[xg_tmp_model$best_iteration]
    xg_run_results$CV_RMSE[j] = xg_tmp_model$evaluation_log$test_rmse_mean[xg_tmp_model$best_iteration]
    
    xg_tmp_toplot = data.frame(Iteration = rep(xg_tmp_model$evaluation_log$iter,2),
                               Type = c(rep("Train", length(xg_tmp_model$evaluation_log$iter)),
                                        rep("Val", length(xg_tmp_model$evaluation_log$iter))),
                               RMSE = c(xg_tmp_model$evaluation_log$train_rmse_mean,
                                        xg_tmp_model$evaluation_log$test_rmse_mean))
    
    xg_tmp_plot = ggplot(data = xg_tmp_toplot, aes(x = Iteration, y = RMSE, group = Type)) +
      geom_line(aes(color = Type), size = 2) +
      theme_classic() +
      theme(text = element_text(size=14))
    
    png(paste0(xg_out_2,"/",xg_run_name,"_",j,"_CV.png"), height = 500, width = 500)
    print(xg_tmp_plot)
    dev.off()
    
  }
  
  xg_run_results = xg_run_results[order(xg_run_results$CV_RMSE),]
  
  rmarkdown::render(xg_report, output_file = paste0(xg_out_2,"/",xg_run_name,".html"))
  
} else {
  
  colnames(xg_settings) = c("y_Transformation", "Learning_Rate", "Max_Tree_Depth",
                            "Subsampling_Cells", "Subsampling_Genes", "Gamma", "Min_Child_Weight", "Iterations")
  xg_run_results = cbind.data.frame(#ID = 1:nrow(xg_settings),
    xg_settings,
    Train_RMSE = NA,
    Val_RMSE = NA)
  
  for (j in 1:nrow(xg_run_results)) {
    xg_tmp_model = readRDS(paste0(xg_out_2,"/",xg_run_name,"_",j,".Rds"))
    
    if(xg_run_results$y_Transformation[j] == "log2") {
      xg_tmp_labels_val = log2(xg_labels_val)
    } else if(xg_run_results$y_Transformation[j] == "sqrt") {
      xg_tmp_labels_val = sqrt(xg_labels_val)
    } else {
      xg_tmp_labels_val = xg_labels_val
    }
    
    xg_run_results$Train_RMSE[j] = tail(xg_tmp_model$evaluation_log$train_rmse,1)
    
    xg_tmp_pred = predict(xg_tmp_model, xg_data_val)
    
    xg_run_results$Val_RMSE[j] = sqrt(mean((xg_tmp_pred - xg_tmp_labels_val)^2))
    
    xg_tmp_tRMSE = cbind.data.frame("RMSE" = xg_tmp_model$evaluation_log$train_rmse,
                                    "Iteration" = xg_tmp_model$evaluation_log$iter)
    
    xg_tmp_plot_tRMSE = ggplot(data = xg_tmp_tRMSE, aes(x = Iteration, y = RMSE)) +
      geom_area(fill = "darkolivegreen") + 
      theme_classic() +
      theme(text = element_text(size=9))
    
    png(paste0(xg_out_2,"/",xg_run_name,"_",j,"_trainingRMSE.png"), height = 500, width = 500)
    print(xg_tmp_plot_tRMSE)
    dev.off()
    
    xg_tmp_vp = cbind.data.frame("Predicted" = xg_tmp_pred,
                                 "Observed" = as.factor(round(xg_tmp_labels_val,2)))
    
    xg_tmp_plot_vp = ggplot() +
      geom_violin(data = xg_tmp_vp, aes(x = Observed, y = Predicted, fill = Observed)) +
      scale_fill_brewer(direction = -1) +
      geom_boxplot(data = xg_tmp_vp, aes(x = Observed, y = Predicted, fill = Observed), width=0.1, outlier.shape = NA, fill = "white") +
      theme_classic() +
      theme(text = element_text(size=9)) +
      ggtitle("Test Set Predictions") +
      geom_point(data = data.frame(x = as.factor(unique(round(xg_tmp_labels_val,2))), y = unique(xg_tmp_labels_val)),
                 aes(x = x, y = y),
                 color = "red",
                 size = 4)
    
    png(paste0(xg_out_2,"/",xg_run_name,"_",j,"_ViolinPlots.png"), height = 500, width = 800)
    print(xg_tmp_plot_vp)
    dev.off()
    
  }
  
  xg_run_results = xg_run_results[order(xg_run_results$Val_RMSE),]
  
  rmarkdown::render(xg_report, output_file = paste0(xg_out_2,"/",xg_run_name,".html"))
  
}
