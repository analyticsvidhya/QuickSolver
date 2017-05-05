The model was built around 4 sets of features primarily

1. Meta data on User : Age buckets and variable V1
2. Meta data on Article : Time since article was published, Number of articles by the same author & Number of articles in the same category
3. User Preferences:
  * How does he/she rate in general : Since it involves the target variable, it was calculated using a 5 fold approach for train data and then using the entire train data for the test data
    * Mean, Median, Min, Max rating of the user
    * % ratings in low (0 to 1), medium (2 to 4) and high (5 to 6) buckets
  * Article Characteristics when he/she rates low/medium/high
    * Mean, Min & Max of 'VintageMonths' when the user rates low/medium/high
    * Mean, Min & Max of 'Number of Articles by same author' when the user rates low/medium/high
    * Was planning to expand on this but could not because of limited time
4. Article Preferences:
  * How is the article rated in general: Since it involves the target variable, it was calculated using a 5 fold approach for train data and then using the entire train data for the test data
    * Mean, Median, Min, Max rating of the article
    * was thinking of creating % ratings in low , medium and high buckets but could not do so owing to time constraint
  * User characteristics when the article is rated ow/medium/high
    * Again, could not implement this owing to time constraint
    
5. Choice of model was Xgboost. Tried an ensemble between 2 xgb models but it gave little boost (from 1.7899 to 1.7895)