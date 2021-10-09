# bot R code

library(rtweet)
library(dplyr)
library(lubridate)

options(httr_oob_default = TRUE)

my_token <- create_token(
    app = "psicotuiterbot",  # the name of the Twitter app
    consumer_key = Sys.getenv("TWITTER_CONSUMER_API_KEY"),
    consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_KEY_SECRET"),
    access_token = Sys.getenv("TWITTER_ACCESS_TOKEN"),
    access_secret = Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

status_ids <- search_tweets("#psicotuiter", type = "recent", token = my_token) %>% 
    filter(!is.na(retweet_status_id), created_at > now()-minutes(15)) %>% 
    pull(status_id)

for (i in 1:length(status_ids)){
    post_tweet(
        retweet_id = status_ids[1],
        token = my_token
    )
}

print("Nothing to RT!")
