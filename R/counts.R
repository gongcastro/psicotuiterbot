# bot activity count and plot
library(ggplot2)
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

source(here::here("R", "utils.R"))

# define hashtags
hashtags <- "#psicotuiter OR #psicotwitter OR #Psicotuiter OR #Psicotwitter OR #PsicoTuiter OR #PsicoTwitter"

# retrieve mentions to #psicotuiter in the last 15 minutes
status <- rtweet::search_tweets(hashtags, type = "recent", token = my_token, include_rts = FALSE)
saveRDS(status, here::here("data", paste0(lubridate::today(), "_tweets.rds")))

files <- list.files(here::here("data"), pattern = ".rds", full.names = TRUE)
tweets_all <- lapply(files, readRDS) %>% 
    bind_rows() %>% 
    distinct(status_id, created_at) %>% 
    mutate(created_at = lubridate::as_date(created_at)) %>% 
    count(created_at)

ggplot(tweets_all, aes(created_at, y = n)) +
    geom_vline(xintercept = lubridate::dmy("9-10-2021"), colour = "grey", size = 1) +
    geom_line(colour = "#ad03fc", size = 1.5) +
    geom_point(colour = "#ad03fc", size = 3, stroke = 1, fill = "black") +
    labs(x = "Fecha", y = "Tweets mencionando #psictuiter o #psicotwitter") +
    theme_github()

ggsave(here::here("img", "counts.png"), dpi = 1000)
