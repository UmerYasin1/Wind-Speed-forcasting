{
  library(httr)
  library(jsonlite)
  library(googlesheets4)
  library(dplyr)
  library("googledrive")
}


#gs4_auth()

key <- "32e06722cc36c9eb21d7046b85070b9c"


## Get Last Hour Generation PK
{

  # This method returns last hour's Generation, Wind speed and Curtailment of respective Wind Power Plants.

  base <- "https://smdapi.azurewebsites.net/Forecast/GetLastHourGenerationPK"


  get_data <- GET(base, add_headers(Authorization = key))

  raw_data = content(get_data, "text")

  get_raw_json <- fromJSON(raw_data, flatten = TRUE)

  get_raw_df <- as.data.frame(get_raw_json)

  get_raw_df["Script_Run"] <- paste0(Sys.time())

}

{

  for (ipp in get_raw_df$IppName){

    current_day_sheet = paste0(Sys.Date(),"_", ipp , ".csv")

    All_ipp_files = list.files(path=paste0("./Sheets/",ipp , "/"), pattern=NULL, all.files=FALSE,
                               full.names=FALSE)

    All_ipp_files_list = as.list(strsplit(All_ipp_files, " "))

    if(current_day_sheet %in% All_ipp_files_list) {

      past_ipps_data = read.csv(paste0("./Sheets/",ipp , "/", current_day_sheet))

    } else {

      empty_ipp_df = data.frame()

      past_ipps_data = write.csv(empty_ipp_df , paste0("./Sheets/",ipp , "/", current_day_sheet))

    }

    if (!is.null(get_raw_df)){

        filter_data = filter(get_raw_df, IppName == ipp)

        common <- intersect(past_ipps_data$StartTime , filter_data$StartTime)

      if (!is.null(length(common))){

          write.table(filter_data, file = paste0("./Sheets/",ipp , "/", current_day_sheet), sep = ",", col.names = NA)

        }

    }


   file_ipp <- drive_get(ipp)

   drive_upload(
     paste0("./Sheets/",ipp , "/", current_day_sheet),
     path = as_id(file_ipp),
     overwrite = TRUE
   )

  }

  rm(get_raw_json, get_data, base, raw_data)


}

