# update blocked accounts
options(httr_oob_default = TRUE)

# restore packages
renv::restore()

# authenticate Twitter API
my_token <- get_api_token()

vip_users <- get_vip_accounts()
vip_users_id <- rtweet::lookup_users(vip_users, token = my_token)$user_id

# get DMs
msg <- rtweet::direct_messages(n = 10, token = my_token)$events
msg <- dplyr::arrange(msg, created_timestamp)

# if new DMs have been received
if (nrow(msg) > 0){
    # for each received DM
    blocked_accounts_vct <- get_blocked_accounts()
    
    # get target users
    msg_text <- msg$message_create$message_data$text
    is_block <- grepl("block|block|bloquea", tolower(msg_text)) # is the DM asking for a block
    is_vip_sender_name <- msg$message_create$sender_id %in% vip_users_id # is the DM from a VIP account?
    
    str_rm <- "block @|block @|bloquea @|Block @|Block @|Bloquea @"
    target_users <- gsub(str_rm, "", msg_text[is_block & is_vip_sender_name])
    
    # get list of repeated and new users to block
    repeated_users <- target_users[paste0("@", target_users) %in% blocked_accounts_vct]
    new_users <- target_users[!(paste0("@", target_users) %in% blocked_accounts_vct)]
    
    # prepare strings
    blocked_accounts_new <- sort(unique(c(blocked_accounts_vct, paste0("@", target_users))))
    
    renviron_text <- paste0(
        'BLOCKED_ACCOUNTS = "', 
        paste0(blocked_accounts_new, collapse = " "),
        '"'
    )
    
    # remove last line in .Renviron and write new one
    env_lines <- readLines(".Renviron")
    writeLines(env_lines[-length(env_lines)], con = ".Renviron")
    write(renviron_text, ".Renviron", append = TRUE)
    
    # print results in console
    if (length(new_users > 0)) message(paste0("User(s) ", paste0(new_users, collapse = " "), " now blocked"))
    if (length(repeated_users > 0)) message(paste0("User(s) ", paste0(repeated_users, collapse = " "), " had already been blocked"))
}
