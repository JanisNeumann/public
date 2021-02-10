########## 1. Config Path ##########

xg_report = paste0(xg_script_dir,"/jn_xgboost_report.Rmd")
xg_run_regse = paste0(xg_script_dir,"/jn_xgboost_run_regse.R")
xg_run_softprob = paste0(xg_script_dir,"/jn_xgboost_run_softprob.R")
xg_eval_regse = paste0(xg_script_dir,"/jn_xgboost_eval_regse.R")
xg_eval_softprob = paste0(xg_script_dir,"/jn_xgboost_eval_softprob.R")

########## 2. Packages ##########

library(Matrix)
library(xgboost)
library(rmarkdown)
library(ggplot2)
library(ggpubr)
library(gridExtra)
library(dplyr)
library(viridis)

########## 3. Run Initialization ##########

xg_start = Sys.time()

# Create list of models to train:
xg_settings = expand.grid(list(yTrf = xg_y_trf,
                               Eta = xg_eta,
                               Depth = xg_depth,
                               Rowsample = xg_subsample,
                               Colsample = xg_colsample,
                               Gamma = xg_gamma,
                               MCW = xg_mcw,
                               Rounds = xg_rounds))

# Create run-specific output folder:
xg_out_2 = paste0(xg_out,"/",xg_run_name)

if (!dir.exists(xg_out_2)) {
  dir.create(xg_out_2, recursive = TRUE)
}

# Load and shape training data:
xg_data_train = Matrix::t(readRDS(paste0(xg_data_dir,"/",xg_train_x)))
xg_labels_train = readRDS(paste0(xg_data_dir,"/",xg_train_y))
xg_data_val = Matrix::t(readRDS(paste0(xg_data_dir,"/",xg_val_x)))
xg_labels_val = readRDS(paste0(xg_data_dir,"/",xg_val_y))


gc()



########## 4. Train Models ##########

if(xg_objective == "multi:softprob") {
  source(xg_run_softprob)
} else if(xg_objective == "reg:squarederror") {
  source(xg_run_regse)
}
gc()

########## 5. Run Evaluation ##########

xg_stop = Sys.time()

xg_tmp_title = cbind.data.frame(xg_run_name, Sys.Date())
colnames(xg_tmp_title) = NULL
xg_tmp_title_theme = ttheme_minimal(core=list(fg_params=list(hjust=1, x=0.9)),
                                    rowhead=list(fg_params=list(hjust=1, x=0.95)),
                                    base_size = 8)

xg_tmp_settings = data.frame(c("Objective" = xg_objective,
                               "Training data" = xg_train_x,
                               "Training labels" = xg_train_y,
                               "Validation data" = xg_val_x,
                               "Validation labels" = xg_val_y,
                               "Output directory" = xg_out_2,
                               "Threads" = xg_threads,
                               "Run started" = as.character(xg_start),
                               "Run ended" = as.character(xg_stop)))
colnames(xg_tmp_settings) = NULL
xg_tmp_settings_theme = ttheme_minimal(core=list(fg_params=list(hjust=1, x=0.9)),
                                       rowhead=list(fg_params=list(hjust=1, x=0.95)),
                                       base_size = 6)

if(xg_objective == "multi:softprob") {
  source(xg_eval_softprob)
} else if(xg_objective == "reg:squarederror") {
  source(xg_eval_regse)
}
rm(list = ls())
gc()
