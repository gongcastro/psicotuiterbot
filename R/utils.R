# get Twitter API token
get_api_token <- function(silent = FALSE){
    tok <- rtweet::create_token(
        app = "psicotuiterbot",  # the name of the Twitter app
        consumer_key = Sys.getenv("TWITTER_CONSUMER_API_KEY"),
        consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_KEY_SECRET"),
        access_token = Sys.getenv("TWITTER_ACCESS_TOKEN"),
        access_secret = Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET"), 
        set_renv = FALSE
    )
    if (!silent) message("API token created")
    return(tok)
}

# get hate words
get_hate_words <- function(){
    # words banned from psicotuiterbot (separated by a space)
    unlist(strsplit(Sys.getenv("HATE_WORDS"), " ")) 
}

# get blocked accounts
get_blocked_accounts <- function(){
    # accounts banned from psicotuiterbot (separated by a space)
    unlist(strsplit(Sys.getenv("BLOCKED_ACCOUNTS"), " ")) 
}

# get VIP accounts
get_vip_accounts <- function(){
    gsub("@", "", unlist(strsplit(Sys.getenv("VIP_USERS"), " ")))
}

# count the number of appearances of character in string
count_character <- function(x, pattern){
    lengths(regmatches(x, gregexpr(pattern, x)))
}
