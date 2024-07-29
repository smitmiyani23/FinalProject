#Loading rhw file

diabetes <- read_csv("diabetes_binary_health_indicators_BRFSS2015.csv")

#Colnames based on Variable classes
base_cols <- c("Age", "Sex", "BMI", "GenHlth")
cond_cols <- c("HighBP", "HighChol", "Stroke", "HeartDiseaseorAttack", "DiffWalk")
habit_cols <- c("Smoker", "HvyAlcoholConsump", "PhysActivity", "Fruits", "Veggies")
econ_cols <- c("AnyHealthcare", "NoDocbcCost", "Education", "Income")

#Selecting the variables for best fit
training <- diabetes |>
  select(all_of(base_cols), all_of(cond_cols),Diabetes_binary) |>
  mutate(across(everything(),as.factor)) |>
  mutate(BMI = as.numeric(BMI))

#Relabeling response
training$Diabetes_binary <- make.names(as.factor(training$Diabetes_binary))

#Defining CrossVal criteria
trctrl_lr <- trainControl(
  method = "repeatedcv",
  number = 5,
  repeats = 3,
  summaryFunction = mnLogLoss,
  classProbs = TRUE)

#Retraining Best Model type on full set
logreg_fit <- train(Diabetes_binary ~., 
                     data = training, 
                     method = "glm",
                     trControl=trctrl_lr,
                     preProcess = c("center", "scale"),
                     family = "binomial",
                     metric = "logLoss",
                     tuneLength = 10
)
#Example prediction
testing <- as.tibble(train[3,])

predict(logreg_fit,testing,type = "prob")
  