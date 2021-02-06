########## 1. Data Paths ##########

#### 1.1 Input ####

xg_script_dir = "?/jn_xgboost"
# Path of jn_xgboost_hub.R and other scripts.

xg_data_dir = paste0(xg_script_dir,"/jn_xgboost_demo_data")
# Data parent directory.

xg_train_x = "jn_xgboost_x_train.rds"
xg_train_y = "jn_xgboost_y_train.rds"
xg_val_x = "jn_xgboost_x_val.rds"
xg_val_y = "jn_xgboost_y_val.rds"
# Specifies the files to use.
# All need to be .RDS files.
# x is assumed to be/contain a dgCMatrix or matrix with rows = predictors and columns = samples.
# (Actually transposed later but I assume this is how most people keep their data.)
# y is assumed to be/contain a vector. Will automatically be converted to numeric or factor as needed.

#### 1.2 Output ####

xg_out = paste0(xg_script_dir,"/jn_xgboost_results")
# Folder to store results in.
# Will automatically be created if not present.

xg_run_name = "jn_xgboost_demo_run"
# Used both for folder name and report.
# A folder with the same name as xg_run_name will be created
# under the path specified by xg_out and used to store all results.


########## 2. Parameters ##########

#### 2.1 XGBoost Hyperparameters ####

xg_objective = "multi:softprob"
# What XGBoost does. Options that are most useful to us are:
# reg:squarederror - regression with squared loss, the default
# multi:softprob - categorization
# Script is currently only set up for these two.

xg_nfold = F
# Cross-validation parameter.
# Can be set to FALSE which drastically reduces the time needed to learn the model.
# Can only take one value. Meaning unlike most other hyperparameters,
# the script will only use one cross validation strategy instead of testing multiple ones.

xg_stop = 30
# Early stopping. Training stops when performance doesn't improve for n steps.
# Only used with cross-validation.

xg_depth = 3:6
# Maximum tree depth.
# xgboost package default is 6.
# Generally the first parameter to optimize.
# Best practice is to start low (some recommendations go as low as 3) and
# increase depth until no more performance is gained.

xg_eta = 0.01
# Learning rate.
# xgboost package defaults to 0.3, which is a high value.

xg_subsample = 0.6
# Share of data to be used for each boosting iteration to reduce overfitting.
# Subsamples rows, which in this case means observations.
# Requires more iterations.

xg_colsample = 0.6
# Same as xg_subsample but for columns (= predictors).
# Authors/developers of XGBoost claim that this is generally the more effective subsampling method.
# Of course, both can be used, but probably best to start with this one.

xg_rounds = 300
# Number of boosting iterations.
# Too many iterations lead to overfitting but we can use callbacks to recover earlier/not overfit models.
# (Callbacks are not used by the framework but the models are all saved and accessible.)

xg_gamma = 0
# Minimum loss reduction required to add a leaf to a tree. Effectively penalizes tree size.
# Can take any non-negative number, but what values make sense depends on
# observed loss reduction/is highly dependant on specific data and model.
# Mostly makes sense to use with shallower trees. If trees are already deep,
# reducing depth would be a more logical tuning step.
# Either way, gamma should generally start at 0 and only be used to combat overfitting
# for selected useful parameter combinations.

xg_mcw = 1
# Minimum child weight, generally speaking the minimum number of examples in a node
# required for that node to be split further.
# Default is 1, which effectively makes this hyperparameter meaningless.
# Higher values prevent overfitting.
# Should start at default value and be altered to improve performance of promising combinations.

#### 2.2 Other Parameters ####

xg_y_trf = "log2"
# How to transform values of dependent variable.
# Used options are "log2" and "sqrt"
# If this variable is anything else it isn't used.
# Ignored for categorization.

xg_threads = 6
# Available threads to use.


#### 3. Sourcing the hub script. ####

source(paste0(xg_script_dir,"/jn_xgboost_hub.R"))