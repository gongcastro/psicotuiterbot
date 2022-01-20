# bot R code
library(dplyr)

options(httr_oob_default = TRUE)

# restore packages
renv::restore()

# authenticate Twitter API
my_token <- rtweet::create_token(
    app = "psicotuiterbot",  # the name of the Twitter app
    consumer_key = Sys.getenv("TWITTER_CONSUMER_API_KEY"),
    consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_KEY_SECRET"),
    access_token = Sys.getenv("TWITTER_ACCESS_TOKEN"),
    access_secret = Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET"), 
    set_renv = FALSE
)

# define hashtags
hashtags_vct <- c("#psicotuiter", "#psicotwitter", "#Psicotuiter", "#Psicotwitter", "#PsicoTuiter", "#PsicoTwitter")
hashtags <- paste(hashtags_vct, collapse = " OR ")
hate_words <- unlist(strsplit(Sys.getenv("HATE_WORDS"), " ")) # words banned from psicotuiterbot (separated by a space)
blocked_accounts <- unlist(strsplit(Sys.getenv("BLOCKED_ACCOUNTS"), " ")) # accounts banned from psicotuiterbot (separated by a space)

time_interval <- lubridate::now(tzone = "UCT")-lubridate::minutes(120)

# get mentions to #psicotuiter and others
all_tweets <- rtweet::search_tweets(
    hashtags, 
    type = "recent", 
    token = my_token, 
    include_rts = FALSE, 
    tzone = "CET"
) 

status_ids <- all_tweets %>% 
    filter(
	!(screen_name %in% gsub("@", "", blocked_accounts)),
        created_at >=  time_interval, # 15 min
        !grepl(paste(hate_words, collapse = "|"), text), # filter out hate words
        stringr::str_count(text, "#") < 4, # no more than 3 hashtags
        lang %in% c("es", "und") # in Spanish or undefined language
    ) %>% 
    pull(status_id)

# get request ID
request_tweets <- rtweet::get_mentions(
    token = my_token, 
    tzone = "CET"
) 

if (nrow(request_tweets) > 0) {
    request_ids <- request_tweets %>% 
        filter(
            created_at >= time_interval, # 15 min
            grepl("@psicotuiterbot", text),
            grepl("rt|RT|Rt", text),
            !grepl(paste(hate_words, collapse = "|"), text) # filter out hate words
        ) %>% 
        pull(status_in_reply_to_status_id)
    
    # get requested IDS
    if (length(request_ids) > 0) {
        requested_ids <- rtweet::lookup_statuses(request_ids, token = my_token) %>% 
            filter(
                !grepl(paste(hate_words, collapse = "|"), text) # filter out hate words
            ) %>% 
            pull(status_id)
    } else {
        requested_ids <- NULL
    }
} else {
    requested_ids <- NULL
}


# RT all IDs
if (length(status_ids) > 0){
    for (i in 1:length(status_ids)){
        rtweet::post_tweet(
            retweet_id = unique(status_ids)[i], # vector with IDs
            token = my_token
        )
    }
    print(paste0(length(status_ids), " RT(s): ", paste(status_ids, collapse = ", ")))
} else {
    print("No tweets to RT")
}

# tweet requests
if (length(requested_ids) > 0){
    for (i in 1:length(requested_ids)){
        rtweet::post_tweet(
            retweet_id = unique(requested_ids)[i], # vector with IDs
            token = my_token
        )
    }
    print(paste0(length(requested_ids), " request(s) posted: ", paste(requested_ids, collapse = ", ")))
} else {
    print("No requests")
}
