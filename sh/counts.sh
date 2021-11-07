#! /bin/bash
Rscript -e 'source("R/counts.R")'
cd ~ 
find . -name '*rtweet_token*' -delete

