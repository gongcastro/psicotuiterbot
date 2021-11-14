#! /bin/bash
TZ="Spain/Madrid" Rscript -e 'source("R/bot.R")'
cd ~
find . -name '*rtweet_token*' -delete

