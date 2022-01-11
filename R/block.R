# update blocked accounts
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

vip_users <- unlist(strsplit(Sys.getenv("VIP_USERS"), " "))
blocked_accounts <- Sys.getenv("BLOCKED_ACCOUNTS")
blocked_accounts_vct <- unlist(strsplit(blocked_accounts, split = " "))

# get DMs
msg <- rtweet::direct_messages(n = 10, token = my_token)$events

# if new DMs have been received
if (nrow(msg) > 0){
    # for each received DM
    for (i in 1:nrow(msg)){
        msg_text <- msg$message_create$message_data$text[i]
        is_block <- grepl("block|block|bloquea", tolower(msg_text))
        sender_name <- rtweet::lookup_users(msg$message_create$sender_id[i])$screen_name
        
        # if message is sent by VIP user and contains keyword "block"
        if (is_block & (paste0("@", sender_name) %in% vip_users)){
            msg_text_vct <- unlist(strsplit(msg_text, " "))
            target_users <- msg_text_vct[grepl("@", msg_text_vct)]
            
            # if at least one targeted users has not been blocked yet
            if (!all(target_users %in% blocked_accounts_vct)){
                target_users_str <- paste0(target_users, collapse = " ")
                blocked_accounts_new <- paste0(blocked_accounts, " ", target_users_str)
                renviron_text <- paste0('BLOCKED_ACCOUNTS = "', blocked_accounts_new, '"')
                write(renviron_text, ".Renviron", append = TRUE)
                message(paste0("User(s) ", paste0(target_users_str, collapse = " "), " is now blocked"))
                
            } else {
                repeated_target <- target_users[which(target_users %in% blocked_accounts_vct)]
                message(paste0("User(s) ", paste0(repeated_target, collapse = " "), " has already been blocked"))
            }
        } else {
            message(paste0("Message from a non-VIP: ", paste0("@", sender_name)))
        }
    }
}


