# authenticate Twitter API
my_token <- get_api_token()

# define hashtags
hashtags_vct <- c(
    "#psicotuiter", 
    "#psicotwitter", 
    "#Psicotuiter",
    "#Psicotwitter", 
    "#PsicoTuiter", 
    "#PsicoTwitter"
)

hashtags <- paste(hashtags_vct, collapse = " OR ") # build query with hashtags
hate_words <- get_hate_words() # hate words will be filtered later
blocked_accounts <- get_blocked_accounts() # blocked accounts will be filtered later

# define time limit
time_interval <- lubridate::now(tzone = "UCT")-lubridate::minutes(60)

# RT mentions to any hashtag ----

# get mentions to #psicotuiter and others
all_tweets <- rtweet::search_tweets(
    hashtags, 
    type = "recent", 
    token = my_token, 
    include_rts = FALSE, 
    tzone = "CET"
) 
message("RTs: tweets retrieved")

# retrieve status ID of mentions to any hashtag
status_ids <- poorman::filter(
    all_tweets,
    !(screen_name %in% gsub("@", "", blocked_accounts)), # if user has not been blocked
    created_at >= time_interval, # 2 hours
    !grepl(paste(hate_words, collapse = "|"), text), # filter out hate words
    count_character(text, "#") < 4, # no more than 3 hashtags
    lang %in% c("es", "und") # in Spanish or undefined language
)$status_id

message("RTs: status IDs retrieved")

# RT all IDs
if (length(status_ids) > 0){
    
    for (i in 1:length(status_ids)){
        rtweet::post_tweet(
            retweet_id = unique(status_ids)[i], # vector with IDs
            token = my_token
        )
    }
    message(paste0("RTs: ", length(status_ids), paste(status_ids, collapse = ", ")))
}

# RT requests ----
request_tweets <- rtweet::get_mentions(token = my_token, tzone = "CET") 
message("RT requests: mentions retrieved")

# if any RT has been requested
requested_ids <- NULL

if (nrow(request_tweets) > 0) {
    
    request_ids <- poorman::filter(
            request_tweets,
            created_at >= time_interval, # 2 hours limit
            !(in_reply_to_screen_name %in% gsub("@", "", blocked_accounts)), # if user has not been blocked
            grepl("@psicotuiterbot", text), # get only if mentions @psicotuiterbot
            grepl("rt|RT|Rt", text), # get only if asks for RT
            !grepl(paste(hate_words, collapse = "|"), text) # filter out hate words
        )$status_in_reply_to_status_id
    
    message("RT requests: request IDs retrieved")
    
    # get requested IDS
    if (length(request_ids) > 0) {
        
        request_ids <- poorman::filter(
                rtweet::lookup_statuses(request_ids, token = my_token),
                !(screen_name %in% gsub("@", "", blocked_accounts)), # if user has not been blocked
                !grepl(paste(hate_words, collapse = "|"), text) # filter out hate words
            )$status_id
            
            message("RT requests: requested IDs retrieved")
            
    }
}

# tweet requests
if (length(requested_ids) > 0){
    
    for (i in 1:length(requested_ids)){
        rtweet::post_tweet(
            retweet_id = unique(requested_ids)[i], # vector with IDs
            token = my_token
        )
    }
    message(paste0("RT requests: ", length(requested_ids), " request(s) posted: ", paste(requested_ids, collapse = ", ")))
}
