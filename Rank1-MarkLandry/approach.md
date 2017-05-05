## Description

In short, features were created using data.table in R and the modeling was done with three H2O models: random forest and two GBMs.

The progression of the models is actually represented in the way the features are laid out. The initial submission scored 1.94 on the public leaderboard (which scored very close to private) and was quickly tuned to about 1.82. This spanned the first six target encodings, no IDs, only the three Article features directly. Over time, I kept adding more (including a pair that surprisingly reduced model quality) all the way to the end. Light experimentation on the modeling hyperparameters, which are likely underfit. Random forest wound up my strongest model, most likely due to lack of internal CV of the GBMs that led to me staying fairly careful.

I kept the User and Article IDs out of the modeling from the start. At one point I used the most frequent User_ID values, but this did not help - the models were already picking up enough of the user qualities. The main feature style is target encoding, so in the code you will see sets of three lines that calculate the sum of response, count of records, and then performs an average that removes the impact of the record to which it is applying the "average". You'll see the same style in my Xtreme ML Hack solution (I started from that code, in fact) and also Knocktober 2016.

The short duration and unlimited submissions for this competition kept me moving quickly, but at a disadvantage for model tuning. No doubt these parameters are not ideal, but that was just a choice I made to keep the leaderboard as my improvement focus and iterations extremely short, rather than internal validation. Had either the train/test split or public/private split not appeared random, I would have modeled things differently. But this was a fairly simple situation for getting away with such tactics.

A 550-tree default Random Forest was my best individual model. Here is the feature utilization :

![](https://ci6.googleusercontent.com/proxy/EccPYJu6X07VL245qWllWNxOhp_Ab1IcRmL0ql9MR4xQ-nKWfTzdK7y6vQpdo_hEO-yJu44o9TJEFZEDhAWZ8SlYPGpu0lchSKfhjRjs7eF8AFpuIvNXbqdPHkqYPJ28qhSWfzdCrW-BWk0eFAF6XIj9sqvqjrVb7k8=s0-d-e1-ft#https://cloud.githubusercontent.com/assets/2976822/25575196/a7f5e9c4-2e1a-11e7-95dc-8fc51c67dcd5.png)

I used a pair of GBMs with slightly different parameters. These features are for the model with 200 trees, a 0.025 learning rate, depth of 5, row sampling of 60% and column sampling of 60%: 

![](https://ci6.googleusercontent.com/proxy/cNivM-wHy8G3VO-5JKOMEd8XenSTKuhI58qBu32HK80XDJ082PS00NF5oi-NhKzCukGh6-V12a6WwQN4wU3hMWx14bfrd37F5Sml8qnOe1EEEtT93wqzI2fNLOW4zVjImnLtXw6SLuJ3IZYxzSGinNxkUXXcAYL6CMo=s0-d-e1-ft#https://cloud.githubusercontent.com/assets/2976822/25575206/bab3885a-2e1a-11e7-8da3-f6c627df4b39.png)