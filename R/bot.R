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
hashtags <- "#psicotuiter OR #psicotwitter OR #Psicotuiter OR #Psicowitter OR #PsicoTuiter OR #PsicoTwitter"

# retrieve mentions to #psicotuiter in the last 15 minutes
status_ids <- rtweet::search_tweets(hashtags, type = "recent", token = my_token) %>% 
    filter(
        is.na(retweet_status_id), # eliminar RTs
           created_at > lubridate::now(tzone = "UCT")-lubridate::minutes(15) # 15 min
        ) %>% 
    pull(status_id) # get vector with IDs

# RT all IDs
if (length(status_ids) > 0){
    for (i in 1:length(status_ids)){
        rtweet::post_tweet(
            retweet_id = status_ids[i],
            token = my_token
        )
    }
}

