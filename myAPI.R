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


#Calculate most abundant values for Categorical Var using.a custom mode function
calculate_mode <- function(x) {
  uniq_x <- unique(x)
  uniq_x[which.max(tabulate(match(x, uniq_x)))]
}

#Yield the mode for each categorical variables
training |>
  select(-c(Diabetes_binary,BMI)) |>
  mutate(across(everything(),as.character)) |>
  mutate(across(everything(),as.numeric)) |>
  map(.f = calculate_mode)

#Yield the mean for continuous variable
training |>
  select(BMI) |>
  map(.f = mean)

#Find multiple of two numbers
#* @param Age Age Group 
#* @param Sex Sex 
#* @param BMI BMI
#* @param GenHlth General Health
#* @param HighBP High BP
#* @param HighChol High Cholesterol
#* @param Stroke Stroke
#* @param HeartDiseaseorAttack Heart Disease or Heart Attack
#* @param DiffWalk Difficulty Walking
#* @get /pred
function(Age= 9, Sex=0, BMI= 17.38218, GenHlth=2, HighBP=0, HighChol=0, Stroke=0, HeartDiseaseorAttack=0, DiffWalk=0 ){
  
  #Creating a data frame for each user input to use in prediction
  predictor_input <- data.frame(Age= as.factor(Age), Sex=as.factor(Sex), BMI= as.numeric(BMI), GenHlth=as.factor(GenHlth), HighBP=as.factor(HighBP), HighChol=as.factor(HighChol), Stroke=as.factor(Stroke), HeartDiseaseorAttack=as.factor(HeartDiseaseorAttack), DiffWalk=as.factor(DiffWalk))
  
  #prediction
  class_pred <- predict(logreg_fit,predictor_input)
  if(class_pred == "X0"){
    prob_pred <- predict(logreg_fit,predictor_input,type = "prob")$X0
  } else {
    prob_pred <- predict(logreg_fit,predictor_input,type = "prob")$X1
  }
  
  
  return(list(
    prediction = paste("The prediction is ", class_pred, "with predicted probability of ",prob_pred),
    example_url = list("http://127.0.0.1:8080/pred?Age=9&Sex=1&BMI=17.3822&GenHlth=5&HighBP=1&HighChol=1&Stroke=1&HeartDiseaseorAttack=1&DiffWalk=1",
                       "http://127.0.0.1:8080/pred?Age=13&Sex=0&BMI=37.3822&GenHlth=3&HighBP=0&HighChol=1&Stroke=1&HeartDiseaseorAttack=1&DiffWalk=1")))
}

#Send a message
#* @get /info
function(){
  list(name = "Smit Miyani", github_page_url = "https://github.com/smitmiyani23/FinalProject/tree/main")
}