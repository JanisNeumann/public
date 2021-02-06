if(xg_nfold != FALSE) {
  
  colnames(xg_settings) = c("y_Transformation", "Learning_Rate", "Max_Tree_Depth", "Subsampling_Cells",
                            "Subsampling_Genes", "Gamma", "Min_Child_Weight", "Max_Iterations")
  xg_run_results = cbind.data.frame(#ID = 1:nrow(xg_settings),
    xg_settings[,-1],
    Iterations = NA,
    Train_Error = NA,
    CV_Error = NA)
  
  for (j in 1:nrow(xg_run_results)) {
    
    xg_tmp_model = readRDS(paste0(xg_out_2,"/",xg_run_name,"_",j,".Rds"))
    
    xg_run_results$Iterations[j] = xg_tmp_model$niter
    xg_run_results$Train_Error[j] = xg_tmp_model$evaluation_log$train_merror_mean[xg_tmp_model$best_iteration]
    xg_run_results$CV_Error[j] = xg_tmp_model$evaluation_log$test_merror_mean[xg_tmp_model$best_iteration]
    
    xg_tmp_toplot = data.frame(Iteration = rep(xg_tmp_model$evaluation_log$iter,2),
                               Type = c(rep("Train", length(xg_tmp_model$evaluation_log$iter)),
                                        rep("Val", length(xg_tmp_model$evaluation_log$iter))),
                               Error = c(xg_tmp_model$evaluation_log$train_merror_mean,
                                         xg_tmp_model$evaluation_log$test_merror_mean))
    
    xg_tmp_plot = ggplot(data = xg_tmp_toplot, aes(x = Iteration, y = Error, group = Type)) +
      geom_line(aes(color = Type), size = 2) +
      theme_classic() +
      theme(text = element_text(size=14))
    
    png(paste0(xg_out_2,"/",xg_run_name,"_",j,"_CV.png"), height = 500, width = 500)
    print(xg_tmp_plot)
    dev.off()
    
  }
  
  xg_run_results = xg_run_results[order(xg_run_results$CV_Error),]
  
  rmarkdown::render(xg_report, output_file = paste0(xg_out_2,"/",xg_run_name,".html"))
  
} else {
  
  colnames(xg_settings) = c("y_Transformation", "Learning_Rate", "Max_Tree_Depth", "Subsampling_Cells",
                            "Subsampling_Genes", "Gamma", "Min_Child_Weight", "Iterations")
  
  xg_run_results = cbind.data.frame(#ID = 1:nrow(xg_settings),
    xg_settings[,-1],
    Train_Error = NA,
    Val_Error = NA)
  
  for (j in 1:nrow(xg_run_results)) {
    xg_tmp_model = readRDS(paste0(xg_out_2,"/",xg_run_name,"_",j,".Rds"))
    
    xg_run_results$Train_Error[j] = tail(xg_tmp_model$evaluation_log$train_merror,1)
    
    xg_tmp_pred = predict(xg_tmp_model, xg_data_val, reshape = T)
    
    xg_tmp_pred_vote = as.integer(apply(xg_tmp_pred,1,function(x)order(x, decreasing = T)[1])-1)
    
    xg_run_results$Val_Error[j] = 1-length(which(xg_tmp_pred_vote == xg_labels_val))/length(xg_tmp_pred_vote)
    
    xg_tmp_tError = cbind.data.frame("Error" = xg_tmp_model$evaluation_log$train_merror,
                                    "Iteration" = xg_tmp_model$evaluation_log$iter)
    
    xg_tmp_plot_tError = ggplot(data = xg_tmp_tError, aes(x = Iteration, y = Error)) +
      geom_area(fill = "darkslategray") + 
      theme_classic() +
      theme(text = element_text(size=9))
    
    png(paste0(xg_out_2,"/",xg_run_name,"_",j,"_trainingError.png"), height = 500, width = 500)
    print(xg_tmp_plot_tError)
    dev.off()
    
    xg_tmp_vp = cbind.data.frame("Category" = rep(as.factor(xg_labels_val), length(unique(xg_labels_val))),
                                 "Probability" = c(xg_tmp_pred),
                                 "Prediction" = as.factor(c(sapply(sort(unique(xg_labels_val)),
                                                                   function(x) rep(x,length(xg_labels_val))))))
    
    xg_tmp_plot_vp = ggplot(xg_tmp_vp, aes(x = Category, y = Probability)) +
      geom_violin(aes(fill = Prediction), position = position_dodge(width = 0.5)) +
      ylim(0,1) +
      scale_fill_viridis(discrete = T) +
      geom_hline(yintercept = 1/length(unique(xg_labels_train))) +
      theme_classic() +
      theme(text = element_text(size=14)) +
      ggtitle("Validation Set Predictions","Probabilities per Category")
    
    png(paste0(xg_out_2,"/",xg_run_name,"_",j,"_ProbabilityPlots.png"), height = 500, width = 800)
    print(xg_tmp_plot_vp)
    dev.off()
    
    xg_tmp_cm = as.data.frame(table(xg_tmp_pred_vote, xg_labels_val))
    
    xg_tmp_cm = cbind.data.frame(xg_tmp_cm,
                                 Prop = xg_tmp_cm$Freq/c(sapply(colSums(table(xg_tmp_pred_vote,
                                                                              xg_labels_val)),
                                                                function(x){rep(x, length(unique(xg_labels_val)))})))
    
    xg_tmp_plot_cm = ggplot(data = xg_tmp_cm, aes(x = xg_labels_val, y = xg_tmp_pred_vote)) +
      geom_tile(aes(fill = Prop)) +
      theme_classic() +
      geom_text(aes(label = sprintf("%1.0f", Freq)), vjust = 1, size = 10) +
      theme(legend.position = "none") +
      scale_fill_viridis(alpha = 0.4, option = "cividis", direction = -1) +
      ylab("Predicted") + xlab("Observed")+
      theme(text = element_text(size = 13))
    
    png(paste0(xg_out_2,"/",xg_run_name,"_",j,"_ConfusionMatrix.png"), height = 400, width = 400)
    print(xg_tmp_plot_cm)
    dev.off()
    
  }
  
  xg_run_results = xg_run_results[order(xg_run_results$Val_Error),]
  
  rmarkdown::render(xg_report, output_file = paste0(xg_out_2,"/",xg_run_name,".html"))
  
}