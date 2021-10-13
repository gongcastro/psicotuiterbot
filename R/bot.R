# bot R code
library(dplyr)

options(httr_oob_default = TRUE)

# authenticate Twitter API
my_token <- rtweet::create_token(
    app = "psicotuiterbot",  # the name of the Twitter app
    consumer_key = Sys.getenv("TWITTER_CONSUMER_API_KEY"),
    consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_KEY_SECRET"),
    access_token = Sys.getenv("TWITTER_ACCESS_TOKEN"),
    access_secret = Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

# define hashtags
hashtags <- "#psicotuiter OR #psicotwitter OR #Psicotuiter OR #Psicotwitter OR #PsicoTuiter OR #PsicoTwitter"
hate_words <- 
time_interval <- lubridate::now(tzone = "UCT")-lubridate::minutes(120)

# retrieve mentions to #psicotuiter in the last 15 minutes
status_ids <- rtweet::search_tweets(hashtags, type = "recent", token = my_token, include_rts = FALSE) %>% 
    filter(
        created_at >=  time_interval # 15 min
    ) %>% 
    pull(status_id) # get vector with IDs

# simple hate words filter
hate_words <- matrix(c("Gay", "gay", "Maricon", "maricon", "Marica", "marica"), ncol = 1) # words banned from psicotuiterbot (subject to change)

if (length(status_ids) > 0){
  for (i in length(hate_words)){
    filt <- paste(hashtags, hate_words[i], sep = " AND ") # adding words to the filter (not sure if needs one AND for each hastag)
    status_ids_hate <- rtweet::search_tweets(filt, type = "recent", token = my_token, include_rts = FALSE) %>%
      filter(
        created_at >=  time_interval # 15 min
      ) %>% 
      pull(status_id) # get vector with IDs
    status_ids <- status_ids %>%
      filter(
        !status_ids %in% status_ids_hate[,1] # deleting al the IDs in status_ids_hate from status_ids
      ) 
  }
} else {
    print("No tweets to filter")
}

# RT all IDs
if (length(status_ids) > 0){
    for (i in 1:length(status_ids)){
        rtweet::post_tweet(
            retweet_id = status_ids[i],
            token = my_token
        )
    }
    print(paste0(length(status_ids), " tweet(s) posted: ", paste(status_ids, collapse = ", ")))
} else {
    print("No tweets to post")
}
