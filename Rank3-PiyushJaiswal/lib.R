create.agg.features.rating <- function(df, by.field, thresh, norm.field, thresh_n){
  
  df[, id := 1]
  df_perc_interest <- df[ ,  list(mean_rating = as.numeric(mean(Rating)),
                                  median_rating = as.numeric(median(Rating)),
                                  min_rating = min(Rating),
                                  max_rating = max(Rating),
                                  sum_rating = sum(Rating),
                                  count = .N,
                                  id = 1), by = by.field]
  
  # overall <- df[ , list(o_mean_rating = as.numeric(mean(rating)),
  #                       o_median_rating = as.numeric(median(rating)),
  #                       id = 1)]
  # 
  # 
  # df_perc_interest <- merge(df_perc_interest, overall, by = "id", all.x = T)
  # 
  # df_perc_interest[count <thresh,
  #                  ":="(mean_rating = (mean_rating*count/thresh)+(o_mean_rating*(thresh - count)/thresh),
  #                       median_rating = (median_rating*count/thresh)+(o_median_rating*(thresh - count)/thresh))]
  
  
  
  df_perc_interest[, count := NULL]
  df_perc_interest[, id := NULL]
  
  if(length(by.field)>1){
    colnames(df_perc_interest)[3:7] = paste0(by.field[1],"_",by.field[2], "_", colnames(df_perc_interest)[3:7])
  }else{
    colnames(df_perc_interest)[2:6] = paste0(by.field, "_", colnames(df_perc_interest)[2:6])
  }
  
  
  return(df_perc_interest)
}



create.agg.features.rating2 <- function(df, by.field, thresh, norm.field, thresh_n){
  
  df[, id := 1]
  df_perc_interest <- df[, list(low = length(which(rating_level == "low"))/.N,
                                medium = length(which(rating_level == "medium"))/.N,
                                high = length(which(rating_level == "high"))/.N,
                                count = .N,
                                id = 1), by = by.field]
  
  # overall <- df[, list(o_low = length(which(rating_level == "low"))/.N, 
  #                      o_medium = length(which(rating_level == "medium"))/.N, 
  #                      o_high = length(which(rating_level == "high"))/.N,
  #                      id = 1)]
  # 
  # 
  # df_perc_interest <- merge(df_perc_interest, overall, by = "id", all.x = T)
  # 
  # df_perc_interest[count <thresh, 
  #                  ":="(low = (low*count/thresh)+(o_low*(thresh - count)/thresh), 
  #                       medium = (medium*count/thresh)+(o_medium*(thresh - count)/thresh), 
  #                       high = (high*count/thresh)+(o_high*(thresh - count)/thresh))]
  # 
  
  
  df_perc_interest[, count := NULL]
  df_perc_interest[, id := NULL]
  
  if(length(by.field)>1){
    colnames(df_perc_interest)[3:5] = paste0(by.field[1],"_",by.field[2], "_", colnames(df_perc_interest)[3:5])
  }else{
    colnames(df_perc_interest)[2:4] = paste0(by.field, "_", colnames(df_perc_interest)[2:4])
  }
  
  
  return(df_perc_interest)
}



create.agg.features.rating3 <- function(df, by.field, thresh = 0, norm.field = NULL, thresh_n=0, var){
  
  df[, id := 1]
  df_perc_interest <- df[ ,list(low = as.numeric(median(get(var)[rating_level == "low"])),
                                medium =  as.numeric(median(get(var)[rating_level == "medium"])),
                                high = as.numeric(median(get(var)[rating_level == "high"])),
                                low_min = as.numeric(min(get(var)[rating_level == "low"])),
                                medium_min =  as.numeric(min(get(var)[rating_level == "medium"])),
                                high_min = as.numeric(min(get(var)[rating_level == "high"])),
                                low_max = as.numeric(max(get(var)[rating_level == "low"])),
                                medium_max =  as.numeric(max(get(var)[rating_level == "medium"])),
                                high_max = as.numeric(max(get(var)[rating_level == "high"])),
                                count = .N,
                                id = 1), by = by.field]
  
  setnames(df_perc_interest, "low",paste0("low","_",var))
  setnames(df_perc_interest, "medium",paste0("medium","_",var))
  setnames(df_perc_interest, "high",paste0("high","_",var))
  setnames(df_perc_interest, "low_min",paste0("low_min","_",var))
  setnames(df_perc_interest, "medium_min",paste0("medium_min","_",var))
  setnames(df_perc_interest, "high_min",paste0("high_min","_",var))
  setnames(df_perc_interest, "low_max",paste0("low_max","_",var))
  setnames(df_perc_interest, "medium_max",paste0("medium_max","_",var))
  setnames(df_perc_interest, "high_max",paste0("high_max","_",var))
  
  
  df_perc_interest[, count := NULL]
  df_perc_interest[, id := NULL]
  
  if(length(by.field)>1){
    colnames(df_perc_interest)[3:11] = paste0(by.field[1],"_",by.field[2], "_", colnames(df_perc_interest)[3:11])
  }else{
    colnames(df_perc_interest)[2:10] = paste0(by.field, "_", colnames(df_perc_interest)[2:10])
  }

  return(df_perc_interest)
}



create.agg.features.misc <- function(df, by.field, thresh = 0, norm.field = NULL, thresh_n=0, var){
  
  df[, id := 1]
  df_perc_interest <- df[ ,  list(mean_rating = as.numeric(mean(get(var))),
                                  median_rating = as.numeric(median(get(var))),
                                  min_rating = min(get(var)),
                                  max_rating = max(get(var)),
                                  sum_rating = sum(get(var)),
                                  count = .N,
                                  id = 1), by = by.field]
  
  setnames(df_perc_interest, "mean_rating",paste0("mean","_",var))
  setnames(df_perc_interest, "median_rating",paste0("median","_",var))
  setnames(df_perc_interest, "min_rating",paste0("min","_",var))
  setnames(df_perc_interest, "max_rating",paste0("max","_",var))
  setnames(df_perc_interest, "sum_rating",paste0("sum","_",var))
  
  # overall <- df[ , list(o_mean_rating = as.numeric(mean(rating)),
  #                       o_median_rating = as.numeric(median(rating)),
  #                       id = 1)]
  # 
  # 
  # df_perc_interest <- merge(df_perc_interest, overall, by = "id", all.x = T)
  # 
  # df_perc_interest[count <thresh,
  #                  ":="(mean_rating = (mean_rating*count/thresh)+(o_mean_rating*(thresh - count)/thresh),
  #                       median_rating = (median_rating*count/thresh)+(o_median_rating*(thresh - count)/thresh))]
  
  
  
  df_perc_interest[, count := NULL]
  df_perc_interest[, id := NULL]
  
  if(length(by.field)>1){
    colnames(df_perc_interest)[3:7] = paste0(by.field[1],"_",by.field[2], "_", colnames(df_perc_interest)[3:7])
  }else{
    colnames(df_perc_interest)[2:6] = paste0(by.field, "_", colnames(df_perc_interest)[2:6])
  }
  
  
  return(df_perc_interest)
}



create.agg.features.rating4 <- function(df, by.field, thresh = 0, norm.field = NULL, thresh_n=0, var){
  
  df_perc_interest <- df[ ,list(low_top = get.mode(get(var)[rating_level == "low"],1)[[1]],
                                low_top_count = as.numeric(get.mode(get(var)[rating_level == "low"],1)[[2]]),
                                low_top_unique = as.numeric(get.mode(get(var)[rating_level == "low"],1)[[3]]),
                                medium_top =  get.mode(get(var)[rating_level == "medium"],1)[[1]],
                                medium_top_count =  as.numeric(get.mode(get(var)[rating_level == "medium"],1)[[2]]),
                                medium_top_unique = as.numeric(get.mode(get(var)[rating_level == "medium"],1)[[3]]),
                                high_top = get.mode(get(var)[rating_level == "high"],1)[[1]],
                                high_top_count = as.numeric(get.mode(get(var)[rating_level == "high"],1)[[2]]),
                                high_top_unique = as.numeric(get.mode(get(var)[rating_level == "high"],1)[[3]])), by = by.field]
  df_perc_interest[low_top == "not found", low_top := NA]
  df_perc_interest[medium_top == "not found", low_top := NA]
  df_perc_interest[high_top == "not found", low_top := NA]
  
  setnames(df_perc_interest, "low_top",paste0("low_top","_",var))
  setnames(df_perc_interest, "medium_top",paste0("medium_top","_",var))
  setnames(df_perc_interest, "high_top",paste0("high_top","_",var))
  setnames(df_perc_interest, "low_top_count",paste0("low_top_count","_",var))
  setnames(df_perc_interest, "medium_top_count",paste0("medium_top_count","_",var))
  setnames(df_perc_interest, "high_top_count",paste0("high_top_count","_",var))
  setnames(df_perc_interest, "low_top_unique",paste0("low_top_unique","_",var))
  setnames(df_perc_interest, "medium_top_unique",paste0("medium_top_unique","_",var))
  setnames(df_perc_interest, "high_top_unique",paste0("high_top_unique","_",var))
  
  
  if(length(by.field)>1){
    colnames(df_perc_interest)[3:11] = paste0(by.field[1],"_",by.field[2], "_", colnames(df_perc_interest)[3:11])
  }else{
    colnames(df_perc_interest)[2:10] = paste0(by.field, "_", colnames(df_perc_interest)[2:10])
  }
  
  
  return(df_perc_interest)
}



create.agg.features.rating5 <- function(df, by.field, thresh = 0, norm.field = NULL, thresh_n=0, var){
  
  df_perc_interest <- df[ ,list(top = get.mode(get(var),1)[[1]],
                                top2 =get.mode(get(var),2)[[1]]), by = by.field]
  df_perc_interest[top == "not found", top := NA]
  df_perc_interest[top2 == "not found", top2 := NA]

  setnames(df_perc_interest, "top",paste0("top","_",var))
  setnames(df_perc_interest, "top2",paste0("top2","_",var))

  
  if(length(by.field)>1){
    colnames(df_perc_interest)[3:4] = paste0(by.field[1],"_",by.field[2], "_", colnames(df_perc_interest)[3:4])
  }else{
    colnames(df_perc_interest)[2:3] = paste0(by.field, "_", colnames(df_perc_interest)[2:3])
  }
  
  
  return(df_perc_interest)
}




get.mode <- function(x,l){
  
  n = table(x)
  
  n = sort(n, decreasing = T)
  
  if(length(x)==0){
    return(list("not found",NA,NA))
  }else{
    return(list(names(n)[l],n[l],length(n)))
  }
  
  
}