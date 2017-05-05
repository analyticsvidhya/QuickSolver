## loading libraries
library(data.table)
library(xgboost)


## loading data
user <- fread("../input/user.csv", colClasses = "character")

article <- fread("../input/article.csv", colClasses = "character")
setnames(article, c("NumberOfArticlesBySameAuthor\r", "NumberOfArticlesinSameCategory\r"),
         c("NumberOfArticlesBySameAuthor", "NumberOfArticlesinSameCategory"))

train <- fread("../input/train.csv", colClasses = "character")
test <- fread("../input/test.csv", colClasses = "character")

## feature engineering
X_panel <- rbind(train, test, use.names = T, fill = T)

X_panel <- merge(X_panel, user, all.x = T, by = "User_ID")
X_panel <- merge(X_panel, article, all.x = T, by = "Article_ID")

#X_panel <- merge(X_panel, X_old_user, all.x = T, by = "User_ID")

X_panel[, ":="(User_ID = as.numeric(as.factor(User_ID)),
               Article_ID = as.numeric(as.factor(Article_ID)),
               Var1 = as.numeric(as.factor(Var1)),
               Age = as.numeric(as.factor(Age)),
               VintageMonths = as.numeric(VintageMonths),
               NumberOfArticlesBySameAuthor = as.numeric(NumberOfArticlesBySameAuthor),
               NumberOfArticlesinSameCategory = as.numeric(NumberOfArticlesinSameCategory),
               #VintageMonths = NULL,
               #NumberOfArticlesBySameAuthor = NULL,
               #NumberOfArticlesinSameCategory = NULL,
               Rating = as.numeric(Rating))]

X_user <- X_panel[, .(count_user = .N), .(User_ID)]
X_panel <- merge(X_panel, X_user, by = "User_ID")

X_article <- X_panel[, .(count_article = .N), .(Article_ID)]
X_panel <- merge(X_panel, X_article, by = "Article_ID")

X_var1 <- X_panel[, .(count_var1 = .N), .(Var1)]
X_panel <- merge(X_panel, X_var1, by = "Var1")

X_age <- X_panel[, .(count_age = .N), .(Age)]
X_panel <- merge(X_panel, X_age, by = "Age")

X_train <- X_panel[!is.na(Rating)]
X_test <- X_panel[is.na(Rating)]

setorder(X_train, User_ID)

X_build <- X_train[seq(1,nrow(X_train)) %% 2 == 0]
X_train <- X_train[seq(1,nrow(X_train)) %% 2 != 0]

X_user_build <- X_build[, .(count_build_user = .N, mean_build_user = mean(Rating)), .(User_ID)]
X_train <- merge(X_train, X_user_build, all.x = T, by = "User_ID")
X_test <- merge(X_test, X_user_build, all.x = T, by = "User_ID")

X_article_build <- X_build[, .(count_build_article = .N, mean_build_article = mean(Rating)), .(Article_ID)]
X_train <- merge(X_train, X_article_build, all.x = T, by = "Article_ID")
X_test <- merge(X_test, X_article_build, all.x = T, by = "Article_ID")

X_train <- X_train[User_ID %in% X_test$User_ID]
#X_train <- X_train[Article_ID %in% X_test$Article_ID]

X_train_ids <- X_train$ID
X_test_ids <- X_test$ID
X_target <- X_train$Rating

X_train[, ":="(ID = NULL, Rating= NULL)]
X_test[, ":="(ID = NULL, Rating= NULL)]

xgtrain <- xgb.DMatrix(data = as.matrix(X_train), label = X_target, missing = NA)
xgtest <- xgb.DMatrix(data = as.matrix(X_test), missing = NA)


## xgboost
params <- list()
params$objective <- "reg:linear"
params$eta <- 0.1
params$max_depth <- 9
params$subsample <- 0.9
params$colsample_bytree <- 0.9
params$min_child_weight <- 23
params$eval_metric <- "rmse"

#model_xgb_cv <- xgb.cv(params = params, xgtrain, nfold = 9, nrounds = 9999, nthread = 4)

model_xgb <- xgb.train(params = params, xgtrain, nrounds = 273, nthread = -1)

#vimp <- xgb.importance(model = model_xgb, feature_names = names(X_train))
#View(vimp)

# prediction
pred <- predict(model_xgb, xgtest)

submit <- data.table(ID = X_test_ids, Rating = pred)

common_ids <- submit$ID[submit$ID %in% train$ID]
leak <- train[ID %in% common_ids, c("ID", "Rating"), with = F]

submit <- rbind(submit[!ID %in% common_ids], leak)

fwrite(submit, "submit14.csv")

