1. Since I didn't have much time to explore the data, I stuck to some old-school basics of quick feature engineering and stable ensembling.

2. Used raw features + count features initially with XGBoost.

3. On plotting feature importance, I found the user-id to be the most important variable. So, split the train data into two halves, and used the average rating of users from one half of the data as a feature in the second half, and built my model on only the second half of the training data. This gave a major boost and the score reached 1.80

4. I ensembled few XGBoosts with different seeds and to finally get below 1.79

5. Some final tweaks like directly populating the common IDs between train and test and clipping the predictions between 0 and 6, gave minor improvements as well.

#### What did not work

Tuning parameters and using linear models didn't really work. I even tried building a multi-class classification model, but that performed much worse than regression, which is natural considering the metric is RMSE