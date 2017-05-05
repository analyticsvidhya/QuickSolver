library(data.table) ## data.table 1.10.0
library(h2o)  ## I used version 3.11.0.3784, which is quite old
library(bit64)

### Read files, merge together, create a single data set with train, test, article, and user
article<-fread("input/article.csv")
setnames(article,c("Article_ID","VintageMonths","NumberOfArticlesBySameAuthor","NumberOfArticlesinSameCategory"))
test<-fread("input/test.csv")
sampleSub<-fread("input/SampleSubmission_N8jkJEu.csv")
train<-fread("input/train.csv")
user<-fread("input/user.csv")

user[,userKey:=.I]
user[,userKey:=paste0("id",userKey)] ## just want a string smaller than the user ID

test[,Rating:=NA]
train[,set:="train"]
test[,set:="test"]
full<-rbind(train,test)
full<-merge(full,article,by="Article_ID",all.x=TRUE)
full<-merge(full,user,by="User_ID",all.x=TRUE)

### TARGET ENCODINGS!
### The pattern is to sum up all the ratings per [feature(s)], and then count how many
###  then when creating the real feature we want, ensure that the record we are applying
###  the average (total ratings / total records) to has been removed from the value.
### There are more complex ways of doing this that also blend other values (e.g. overall mean)
###  but I just did the straightforward way. The downside of that is that it leaves you with
###  NAs when there is only one record (so that you don't overfit the actual record itself).
### For a more complex version of this, see fellow h2o.ai Branden Murray's catNWayAvgCV function 
###  in his "It is Lit" Kernel from Kaggle's recent 2-sigma Renthop problem (line 18)
###  https://www.kaggle.com/brandenkmurray/two-sigma-connect-rental-listing-inquiries/it-is-lit
### This was my first way of approaching the problem, with a few simple ones, then I kept adding
###  them deeper and deeper to keep improving my score

full[,nUser:=sum(Rating,na.rm=T),.(User_ID)]
full[,dUser:=sum(set=="train",na.rm=T),.(User_ID)]
full[,tgtUser:=ifelse(set=="train",(nUser-Rating)/(dUser-1),nUser/dUser)]

full[,nArticle:=sum(Rating,na.rm=T),.(Article_ID)]
full[,dArticle:=sum(set=="train",na.rm=T),.(Article_ID)]
full[,tgtArticle:=ifelse(set=="train",(nArticle-Rating)/(dArticle-1),nArticle/dArticle)]

full[,nCat:=sum(Rating,na.rm=T),.(NumberOfArticlesinSameCategory)]
full[,dCat:=sum(set=="train",na.rm=T),.(NumberOfArticlesinSameCategory)]
full[,tgtCat:=ifelse(set=="train",(nCat-Rating)/(dCat-1),nCat/dCat)]

full[,nUserCat:=sum(Rating,na.rm=T),.(User_ID,NumberOfArticlesinSameCategory)]
full[,dUserCat:=sum(set=="train",na.rm=T),.(User_ID,NumberOfArticlesinSameCategory)]
full[,tgtUserCat:=ifelse(set=="train",(nUserCat-Rating)/(dUserCat-1),nUserCat/dUserCat)]

full[,nAuthnumber:=sum(Rating,na.rm=T),.(NumberOfArticlesBySameAuthor)]
full[,dAuthnumber:=sum(set=="train",na.rm=T),.(NumberOfArticlesBySameAuthor)]
full[,tgtAuthnumber:=ifelse(set=="train",(nAuthnumber-Rating)/(dAuthnumber-1),nAuthnumber/dAuthnumber)]

full[,nUserAuth:=sum(Rating,na.rm=T),.(User_ID,NumberOfArticlesBySameAuthor)]
full[,dUserAuth:=sum(set=="train",na.rm=T),.(User_ID,NumberOfArticlesBySameAuthor)]
full[,tgtUserAuth:=ifelse(set=="train",(nUserAuth-Rating)/(dUserAuth-1),nUserAuth/dUserAuth)]

full[,nMonths:=sum(Rating,na.rm=T),.(VintageMonths)]
full[,dMonths:=sum(set=="train",na.rm=T),.(VintageMonths)]
full[,tgtMonths:=ifelse(set=="train",(nMonths-Rating)/(dMonths-1),nMonths/dMonths)]

full[,nUserMonths:=sum(Rating,na.rm=T),.(User_ID,VintageMonths)]
full[,dUserMonths:=sum(set=="train",na.rm=T),.(User_ID,VintageMonths)]
full[,tgtUserMonths:=ifelse(set=="train",(nUserMonths-Rating)/(dUserMonths-1),nUserMonths/dUserMonths)]

full[,nUserAuthCat:=sum(Rating,na.rm=T),.(User_ID,NumberOfArticlesinSameCategory,NumberOfArticlesBySameAuthor)]
full[,dUserAuthCat:=sum(set=="train",na.rm=T),.(User_ID,NumberOfArticlesinSameCategory,NumberOfArticlesBySameAuthor)]
full[,tgtUserAuthCat:=ifelse(set=="train",(nUserAuthCat-Rating)/(dUserAuthCat-1)
                                ,nUserAuthCat/dUserAuthCat)]

full[,nUserAuthMonths:=sum(Rating,na.rm=T),.(User_ID,NumberOfArticlesBySameAuthor,VintageMonths)]
full[,dUserAuthMonths:=sum(set=="train",na.rm=T),.(User_ID,NumberOfArticlesBySameAuthor,VintageMonths)]
full[,tgtUserAuthMonths:=ifelse(set=="train",(nUserAuthMonths-Rating)/(dUserAuthMonths-1)
                                ,nUserAuthMonths/dUserAuthMonths)]

full[,nUserAuthCatMonths:=sum(Rating,na.rm=T),.(User_ID,NumberOfArticlesBySameAuthor,VintageMonths,NumberOfArticlesinSameCategory)]
full[,dUserAuthCatMonths:=sum(set=="train",na.rm=T),.(User_ID,NumberOfArticlesBySameAuthor,VintageMonths,NumberOfArticlesinSameCategory)]
full[,tgtUserAuthCatMonths:=ifelse(set=="train",(nUserAuthCatMonths-Rating)/(dUserAuthCatMonths-1)
                                ,nUserAuthCatMonths/dUserAuthCatMonths)]

full[,nVar1:=sum(Rating,na.rm=T),.(Var1)]
full[,dVar1:=sum(set=="train",na.rm=T),.(Var1)]
full[,tgtVar1:=ifelse(set=="train",(nVar1-Rating)/(dVar1-1),nVar1/dVar1)]

full[,nAge:=sum(Rating,na.rm=T),.(Age)]
full[,dAge:=sum(set=="train",na.rm=T),.(Age)]
full[,tgtAge:=ifelse(set=="train",(nAge-Rating)/(dAge-1),nAge/dAge)]

### allow the model to see some of the users; I thought this would be more helpful
###  than it was, but later saw that we have quite a lot of data on most users
###  so the model was already able to fit them fairly closely with the target encodings
full[,topUsers:=ifelse(nUser>100,userKey,"")]

### parallel export; I could use as.h2o(), but that would effectively do the same thing, 
###  and I like the way data.table uses strings, when working on features, and then 
###  H2O parses more like I want for modeling
fwrite(full[set %in% c("train","valid")],"train_export.csv")
fwrite(full[set=="test"],"test_export.csv")

############################################################
## Model fitting via H2O
############################################################

### create an H2O cloud - a Java service remote-controlled through R
h2o.init(nthreads = -1,max_mem_size = "6G")

trainHex<-h2o.importFile("train_export.csv",destination_frame = "train.hex")
testHex<-h2o.importFile("test_export.csv",destination_frame = "test.hex")

### manage list of columns to remove; all intermediate calculations, columns
###  without meaning, the original categoricals, and--through trial and error--some
###  categoricals I assumed would be useful to the problem, but yielded poorer models
###  ("tgtVar1","tgtAge")
intermediaryCalculations<-colnames(full)[substr(colnames(full),1,1) %in% c("n","d")]
excludes<-c("Article_ID","ID","User_ID","Rating","set","Age","Var1","userKey"
            ,"tgtVar1","tgtAge"
            ,intermediaryCalculations)

### use all remaining values; this helps ensure new fields are added automatically
predictors<-colnames(trainHex)[!colnames(trainHex) %in% excludes]

### In the modeling, I must confess that I used the leaderboard to check model progress
###  Using actual cross validation would have required a bit more work to ensure the 
###  target encodings were done in a way similar to the train/test split, and I started 
###  off not doing that, and resisted putting in the time to do it later. The downside
###  is that I couldn't tune the models without making a submission. So, these models can
###  probably be improved--especially by dropping the learning rate and training for longer
###  which I never really wanted to do.

### first GBM
g1<-h2o.gbm(x=predictors,y="Rating",training_frame = trainHex,ntrees = 150
              ,score_tree_interval = 50 #,nfolds = 4,stopping_rounds = 4,stopping_tolerance = 0
              ,learn_rate = 0.03,max_depth = 5,sample_rate = 0.7,col_sample_rate = 0.7
              ,model_id = "g1")

pTest<-data.table(as.data.frame(h2o.cbind(
  testHex$ID,h2o.predict(object = g1,newdata=testHex[,predictors])$predict
)))
setnames(pTest,c("ID","Rating"))
theTime<-gsub("[[:punct:]]", "", as.character(Sys.time()))
fileName1<-paste("submission_",gsub(" ","_",theTime),".csv",sep='')
fwrite(pTest[,.(ID,Rating=pmin(6,pmax(0,Rating)))][order(ID)],fileName1)

### second GBM
g2<-h2o.gbm(x=predictors,y="Rating",training_frame = trainHex,ntrees = 200
              ,score_tree_interval = 50 #,nfolds = 4,stopping_rounds = 4,stopping_tolerance = 0
              ,learn_rate = 0.025,max_depth = 5,sample_rate = 0.6,col_sample_rate = 0.6
              ,model_id = "g2")

pTest<-data.table(as.data.frame(h2o.cbind(
  testHex$ID,h2o.predict(object = g2,newdata=testHex[,predictors])$predict
  )))
setnames(pTest,c("ID","Rating"))
theTime<-gsub("[[:punct:]]", "", as.character(Sys.time()))
fileName2<-paste("submission_",gsub(" ","_",theTime),".csv",sep='')
fwrite(pTest[,.(ID,Rating=pmin(6,pmax(0,Rating)))][order(ID)],fileName2)
fileName2

### Distributed Random Forest
### I was surprised this outperformed my GBMs. Which is likely a hint that my GBMs are 
###  underfit (see modeling note above). In this situation, random forest is quite helpful
###  since it requires virtually no tuning at all. I submitted this model independently
###  with just 5 or 10 minutes left, so I was out of time to try and explore mimicking in a GBM
###  whichever part of the RF was working well.
rf<-h2o.randomForest(x=predictors,y="Rating",training_frame = trainHex,ntrees = 550
              ,score_tree_interval = 50 
              ,model_id = "rf")

pTest<-data.table(as.data.frame(h2o.cbind(
  testHex$ID,h2o.predict(object = h2o.getModel("rf"),newdata=testHex[,predictors])$predict
)))
setnames(pTest,c("ID","Rating"))
theTime<-gsub("[[:punct:]]", "", as.character(Sys.time()))
fileName3<-paste("submission_",gsub(" ","_",theTime),".csv",sep='')
fwrite(pTest[,.(ID,Rating=pmin(6,pmax(0,Rating)))][order(ID)],fileName3)
fileName3

### the three models above were run and submitted independently, and throughout
###  the competition I would create simple blends of my best submissions
blend1<-fread(fileName1)[order(ID)]  ## gbm1
blend2<-fread(fileName2)[order(ID)]  ## gbm2
blend3<-fread(fileName3)[order(ID)]  ## rf

test<-fread("input/test.csv")[order(ID)]  ## reloaded just to ensure vector order
fwrite(blend1[,.(ID,Rating=
                   (blend1$Rating*0.2
                    +blend2$Rating*0.2
                    +blend3$Rating*0.6
                   ))],"blend5.csv")
