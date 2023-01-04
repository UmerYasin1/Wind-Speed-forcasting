# Call model.py
source_python("model.py")

#ipp = "Sapphire Wind Power Company Limited"

fetch_data_for_model <- function(ipp){

  df1 <- data.frame()

  for (id in c(0 ,-1 ,-2)){

  current_day_sheet = paste0(Sys.Date() + id,"_", ipp , ".csv")

  df2 = read.csv(paste0("./Sheets/", ipp, "/",current_day_sheet))

  df1 <- rbind(df1, df2)

  }

  final_df <- df1[0:42,]

  final_df <-final_df[order(final_df$StartTime),]

  return(final_df)

}

call_model_lstm <- function(ipp){

  ipp = "Sapphire Wind Power Company Limited"

  total_prediction = list()

  get_data = fetch_data_for_model(ipp)

  pass_data = get_data$WindSpeed

  data = list(as.character(pass_data ))

  unlist_set = unlist(data)

  final_list = as.list(strsplit(unlist_set, " "))

  # For fourth hours prediction
  for (id in c(1,2,3,4)){

    pridict_value = test_model(final_list)
    final_list <- c(final_list, pridict_value )
    final_list[[1]] = NULL

    total_prediction = c(total_prediction, pridict_value)


  }

  return(list("model_predict" = total_prediction ,"pass_values" = get_data))

}

History_store_data_api <- function(ipp){

  # ipp = "Sapphire Wind Power Company Limited"

  df1 <- data.frame()

  folder <- paste0("./Sheets/", ipp, "/")
  files <-  list.files(folder, pattern = ".", all.files = FALSE, recursive = TRUE, full.names = TRUE)

  for (id in files){

    read_sheet_data = read.csv(id)

    df1 <- rbind(df1, read_sheet_data)

  }

  return(df1)

}

History_all_provided_data <- function(){

  #ipp = "Sapphire Wind Power Company Limited"

  # Will work on

}

predicted_data_time <- function(ipp){

  #ipp = "Sapphire Wind Power Company Limited"

  get_data = fetch_data_for_model(ipp)

  get_forcast = call_model_lstm(ipp)

  total_forcaste_time = as.character()

  start_time_data = get_data$StartTime

  final_1 <- as.POSIXct(start_time_data, format="%m/%d/%Y %H:%M")

  last_data = tail(final_1, n =1)

  # For fourth hours prediction
  for (id in c(1,2,3,4)){

    next_data_time = last_data + hours(id)

    total_forcaste_time = c(total_forcaste_time, as.character(next_data_time))

  }

  return (total_forcaste_time)

}





