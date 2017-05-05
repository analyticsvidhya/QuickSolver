rm(list = ls())
gc()



packages <- c("purrr","data.table","xgboost", "MLmetrics")
purrr::walk(packages, library, character.only = TRUE, warn.conflicts = FALSE)





source("./lib.R")


train <- read.csv("train.csv")
test <- read.csv("test.csv")
user <- read.csv("user.csv")
article <- read.csv("article.csv")

train <- data.table(train)
test <- data.table(test)
user <- data.table(user)
article <- data.table(article)


colnames(article) = c("Article_ID", "VintageMonths", "NumberOfArticlesBySameAuthor", "NumberOfArticlesinSameCategory")


setorder(train, "ID")
setorder(test, "ID")



# total count of ratings by users
uc <- rbind(train[,c("User_ID","Article_ID"), with = F], test[,c("User_ID","Article_ID"), with = F])
uc <- uc[, list(user_rating_count =.N), by = "User_ID"]
train <- merge(train, uc, by = "User_ID", all.x = T)
test <- merge(test, uc, by = "User_ID", all.x = T)




# total count of ratings for articles
ac <- rbind(train[,c("User_ID","Article_ID"), with = F], test[,c("User_ID","Article_ID"), with = F])
ac <- ac[, list(article_rating_count =.N), by = "Article_ID"]
train <- merge(train, ac, by = "Article_ID", all.x = T)
test <- merge(test, ac, by = "Article_ID", all.x = T)




# User Profile
user[, ":="(Var1 = as.character(Var1), Age = as.character(Age))]
user[Age == "", Age := NA]
train <- merge(train, user, by = "User_ID", all.x = T)
test <- merge(test, user, by = "User_ID", all.x = T)



# Article Profile
train <- merge(train, article, by = "Article_ID", all.x = T)
test <- merge(test, article, by = "Article_ID", all.x = T)



# average rating by user
set.seed(123)
kfold <- rep(1:5, nrow(train)/5 +1)
kfold <- kfold[1:nrow(train)]
kfold <- sample(kfold, length(kfold))
train_temp <- data.table()

for(k in 1:5){
  holdout <- train[kfold == k, ]
  train2 <- train[kfold != k, ]
  
  user_agg_perf <- create.agg.features.rating(copy(train2), "User_ID", thresh = 30, norm.field = NULL, thresh_n = 0)
  holdout <- merge(holdout, user_agg_perf[,1:6,with = F], by = "User_ID", all.x = T)

  
  train_temp <- rbind(train_temp, holdout)
}
train <- copy(train_temp)
setorder(train, "ID")
rm(train_temp); rm(holdout); rm(train2);
gc();

user_agg_perf <- create.agg.features.rating(copy(train), "User_ID", thresh = 30, norm.field = NULL, thresh_n = 0)
test <- merge(test, user_agg_perf[,1:6,with = F], by = "User_ID", all.x = T)




# average rating by article
set.seed(123)
kfold <- rep(1:5, nrow(train)/5 +1)
kfold <- kfold[1:nrow(train)]
kfold <- sample(kfold, length(kfold))
train_temp <- data.table()

for(k in 1:5){
  holdout <- train[kfold == k, ]
  train2 <- train[kfold != k, ]
  
  user_agg_perf <- create.agg.features.rating(copy(train2), "Article_ID", thresh = 30, norm.field = NULL, thresh_n = 0)
  holdout <- merge(holdout, user_agg_perf[,1:6,with = F], by = "Article_ID", all.x = T)
  
  
  train_temp <- rbind(train_temp, holdout)
}
train <- copy(train_temp)
setorder(train, "ID")
rm(train_temp); rm(holdout); rm(train2);
gc();

user_agg_perf <- create.agg.features.rating(copy(train), "Article_ID", thresh = 30, norm.field = NULL, thresh_n = 0)
test <- merge(test, user_agg_perf[,1:6,with = F], by = "Article_ID", all.x = T)



save(train, test, user, article, file = "train-Stage1.Rdata")
load("train-Stage1.Rdata")



# % low/medium/high rating by user
train[, rating_level := "low"]
train[Rating >=2 & Rating<=4, rating_level := "medium"]
train[Rating >=5, rating_level := "high"]

set.seed(123)
kfold <- rep(1:5, nrow(train)/5 +1)
kfold <- kfold[1:nrow(train)]
kfold <- sample(kfold, length(kfold))
train_temp <- data.table()

for(k in 1:5){
  holdout <- train[kfold == k, ]
  train2 <- train[kfold != k, ]
  
  user_agg_perf <- create.agg.features.rating2(copy(train2), "User_ID", thresh = 30, norm.field = NULL, thresh_n = 0)
  holdout <- merge(holdout, user_agg_perf[,1:4,with = F], by = "User_ID", all.x = T)
  
  
  train_temp <- rbind(train_temp, holdout)
}
train <- copy(train_temp)
setorder(train, "ID")
rm(train_temp); rm(holdout); rm(train2);
gc();

user_agg_perf <- create.agg.features.rating2(copy(train), "User_ID", thresh = 30, norm.field = NULL, thresh_n = 0)
test <- merge(test, user_agg_perf[,1:4,with = F], by = "User_ID", all.x = T)



# preferences in % low/medium/high rating by user
set.seed(123)
kfold <- rep(1:5, nrow(train)/5 +1)
kfold <- kfold[1:nrow(train)]
kfold <- sample(kfold, length(kfold))
train_temp <- data.table()

for(k in 1:5){
  holdout <- train[kfold == k, ]
  train2 <- train[kfold != k, ]
  
  user_agg_perf <- create.agg.features.rating3(copy(train2), "User_ID", var = "VintageMonths")
  holdout <- merge(holdout, user_agg_perf[,1:10,with = F], by = "User_ID", all.x = T)
  
  user_agg_perf <- create.agg.features.rating3(copy(train2), "User_ID", var = "NumberOfArticlesBySameAuthor")
  holdout <- merge(holdout, user_agg_perf[,1:10,with = F], by = "User_ID", all.x = T)
  
  train_temp <- rbind(train_temp, holdout)
}
train <- copy(train_temp)
setorder(train, "ID")
rm(train_temp); rm(holdout); rm(train2);
gc();

user_agg_perf <- create.agg.features.rating3(copy(train), "User_ID", var = "VintageMonths")
test <- merge(test, user_agg_perf[,1:10,with = F], by = "User_ID", all.x = T)
user_agg_perf <- create.agg.features.rating3(copy(train), "User_ID", var = "NumberOfArticlesBySameAuthor")
test <- merge(test, user_agg_perf[,1:10,with = F], by = "User_ID", all.x = T)



# save Stage 2
save(train, test, user, article, file = "train-Stage2.Rdata")
load("train-Stage2.Rdata")



# Choose the dependent  & first set of independent variables
setorder(train, "ID")
setorder(test, "ID")
cols.select <- c("user_rating_count", "article_rating_count", 
                 "Var1", "Age", 
                 "VintageMonths", "NumberOfArticlesBySameAuthor", "NumberOfArticlesinSameCategory",
                 "User_ID_mean_rating", "User_ID_median_rating", 
                 "User_ID_min_rating", "User_ID_max_rating", "User_ID_sum_rating",
                 "Article_ID_mean_rating", "Article_ID_median_rating",     
                 "Article_ID_min_rating", "Article_ID_max_rating", "Article_ID_sum_rating",
                 "User_ID_low", "User_ID_medium", "User_ID_high",
                 "User_ID_low_VintageMonths", "User_ID_medium_VintageMonths", "User_ID_high_VintageMonths",
                 "User_ID_low_min_VintageMonths", "User_ID_medium_min_VintageMonths", "User_ID_high_min_VintageMonths",
                 "User_ID_low_max_VintageMonths", "User_ID_medium_max_VintageMonths", "User_ID_high_max_VintageMonths",
                 "User_ID_low_NumberOfArticlesBySameAuthor", "User_ID_medium_NumberOfArticlesBySameAuthor", "User_ID_high_NumberOfArticlesBySameAuthor",
                 "User_ID_low_min_NumberOfArticlesBySameAuthor", "User_ID_medium_min_NumberOfArticlesBySameAuthor", "User_ID_high_min_NumberOfArticlesBySameAuthor",
                 "User_ID_low_max_NumberOfArticlesBySameAuthor", "User_ID_medium_max_NumberOfArticlesBySameAuthor", "User_ID_high_max_NumberOfArticlesBySameAuthor")
x_train <- subset(train, select = cols.select)
x_test <- subset(test, select = cols.select)
y_train <- train[, Rating]



# Numeric encoding for the factor variables
cols.fac <- c("Var1","Age")
for(c in cols.fac){
  tbl = table(x_train[,get(c)])
  levels.fac <- names(tbl)[tbl>=15]
  if(length(levels.fac)<length(names(tbl))){
    x_train[!(get(c) %in% levels.fac), (c) := "Others"]
    x_test[!(get(c) %in% levels.fac), (c) := "Others"]
    levels.fac <- c(levels.fac,"Others")
  }
  
  levels.fac = sort(levels.fac)
  x_train[, (c) := as.integer(factor(get(c), levels = levels.fac))]
  x_test[, (c) := as.integer(factor(get(c), levels = levels.fac))]
}




# Prepare data for xgboost
x_train[is.na(x_train)] = 111222333
x_test[is.na(x_test)] = 111222333
train.xg <- xgb.DMatrix(as.matrix((x_train)), label=y_train, missing=111222333)
test.xg <- xgb.DMatrix(as.matrix((x_test)), missing=111222333)
gc()



# Choose parameters
param <- list(max_depth = 8, 
              eta = 0.01, 
              silent = 1,
              objective="reg:linear",
              eval_metric="rmse",
              subsample = 0.8,
              min_child_weight = 5,
              colsample_bytree = 0.7)



# Build Model
Sys.time()
set.seed(123)
model_xgb <- xgb.train(data=train.xg, nrounds = 1500,
                       params = param, verbose = 1, missing = 111222333, 
                       #early.stop.round = 200, 
                       maximize = F, print.every.n = 100
                       #watchlist = watchlist
)
Sys.time()



# Create Predictions
Sys.time()
pred_test = predict(model_xgb, test.xg, ntreelimit=model_xgb$bestInd, missing=111222333)
Sys.time()

pred_test[pred_test<0] = 0
pred_test[pred_test>6] = 6



test[, Rating := pred_test]



# Write submission
submission <- subset(test, select = c("ID", "Rating"))
write.csv(submission, file = "submission_V5.csv", row.names = F)



# Choose parameters
param <- list(max_depth = 8, 
              eta = 0.01, 
              silent = 1,
              objective="reg:linear",
              eval_metric="rmse",
              subsample = 0.8,
              min_child_weight = 2,
              colsample_bytree = 0.7)



# Build Model
Sys.time()
set.seed(123)
model_xgb <- xgb.train(data=train.xg, nrounds = 1500,
                       params = param, verbose = 1, missing = 111222333, 
                       #early.stop.round = 200, 
                       maximize = F, print.every.n = 100
                       #watchlist = watchlist
)
Sys.time()



# Create Predictions
Sys.time()
pred_test = predict(model_xgb, test.xg, ntreelimit=model_xgb$bestInd, missing=111222333)
Sys.time()

pred_test[pred_test<0] = 0
pred_test[pred_test>6] = 6



test[, Rating := pred_test]



# Write submission
submission <- subset(test, select = c("ID", "Rating"))
write.csv(submission, file = "submission_V6.csv", row.names = F)


#................................................ Ensembling starts
p1 = read.csv("submission_V5.csv")
p1 = data.table(p1)
p1[Rating<0, Rating:=0]
p1[Rating>6, Rating := 6]



p2 = read.csv("submission_V6.csv")
p2 = data.table(p2)
p1[Rating<0, Rating:=0]
p1[Rating>6, Rating := 6]
setnames(p2, "Rating","Rating_2")

p1 <- merge(p1, p2, by = "ID", all.x = T)


w1 = 0.5; w2 = 0.5;
p1[, Rating := (w1*Rating + w2*Rating_2)]


submission2 = subset(p1, select = c("ID","Rating"))

write.csv(submission2, file = "submission_V5-6_ens.csv", row.names = F)






