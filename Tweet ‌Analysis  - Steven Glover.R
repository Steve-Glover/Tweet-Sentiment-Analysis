#TWEET TEXT ANALYSIS

# Obtain Tweets from Twitter
library(twitteR) 
library(tm)      
library(wordcloud) 
# set java home for qdap library : I get an error loading the qdap library otherwise.
Sys.setenv(JAVA_HOME = 'C:/Program Files/Java/jre-9.0.4')
library(qdap)
library(RWeka)
library(tidytext)
library(gutenbergr)
library(dplyr)
library(tidyr)
library(ggplot2)

#----------------------
# Extract Twitter Data
# ====================

# Customer Keys and Access Tokens to use the Twitter API
consumer_key <- "consumer...key"
consumer_secret <- "consumer....secret"
access_token <- "access....token"
access_secret <- "access....secret"

# Send Authorization to Twitter
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

# Pull chatter associated with Starbucks
tw = twitteR::searchTwitter("#starbucks", n = 2000, since = '2017-01-01', retryOnRateLimit = 1e3)
av = twitteR::twListToDF(tw)

#---------------------
# Tweet Preporcessing
# ===================

# convert the encoding of the text to eliminate unrecognized characters
av$text <- iconv(av$text, from = "UTF-8", to = "ASCII", sub = "")

# save text for later use
file_text = 'D:/Analytics/Spring Semester/Text Mining/TXT #2/Data/tweet_text.RData'
save(av, file = file_text)

# Check Point: Load previously pulled tweets
# load('D:/Analytics/Spring Semester/Text Mining/TXT #2/Data/tweet_text.RData')

# Convert the corpus to a vector sources
av_review_corpus <- VCorpus(VectorSource(av$text))

# Cleaning corpus - preprocessing function
clean_corpus <- function(cleaned_corpus) {
    removeURL <- content_transformer(function(x) gsub("(f|ht)tp(s?)://\\S+", "", x, perl = T))
    cleaned_corpus <- tm_map(cleaned_corpus, removeURL)
    # remove abbreviations
    cleaned_corpus <- tm_map(cleaned_corpus, content_transformer(replace_abbreviation))
    # convert all text to lower
    cleaned_corpus <- tm_map(cleaned_corpus, content_transformer(tolower))
    # remove punctuations
    cleaned_corpus <- tm_map(cleaned_corpus, removePunctuation)
    # remove all numeric values
    cleaned_corpus <- tm_map(cleaned_corpus, removeNumbers)
    # exclude english stop words
    cleaned_corpus <- tm_map(cleaned_corpus, removeWords, stopwords("english"))
    # trim additional white space
    cleaned_corpus <- tm_map(cleaned_corpus, stripWhitespace)
    return(cleaned_corpus)
}

# Clean the corpus
cleaned_av_review_corpus <- clean_corpus(av_review_corpus)


#---------------------
# Word Cloud - Unigram
# ====================

# Create a term-document matrix for the corpus
TDM_tweets <- TermDocumentMatrix(cleaned_av_review_corpus)
TDM_tweets_m <- as.matrix(TDM_tweets)

# Calculate the Term Frequency 
term_frequency <- rowSums(TDM_tweets_m)

# Sort term_frequency in descending order
term_frequency <- sort(term_frequency, dec = TRUE)

# Create word_frequency data frame
word_freqs <- data.frame(term = names(term_frequency), num = term_frequency)

# Create a word cloud for the values in word_freqs
wordcloud(word_freqs$term, word_freqs$num, min.freq = 5, max.words = 500, colors = brewer.pal(8, "Paired"))



# --------------------
# Word Cloud - Bigram
# ====================

# Create a bigram tokenizer function
tokenizer <- function(x)
    NGramTokenizer(x, Weka_control(min = 2, max = 2))

# Bigram term-document matrix
bigram_tdm <- TermDocumentMatrix(cleaned_av_review_corpus, control = list(tokenize = tokenizer))
bigram_tdm_m <- as.matrix(bigram_tdm)

# Term Frequency
term_frequency <- rowSums(bigram_tdm_m)

# Sort term_frequency in descending order
term_frequency <- sort(term_frequency, dec = TRUE)

# Create a data frame of word_freqs
word_freqs <- data.frame(term = names(term_frequency), num = term_frequency)

# Create a word cloud for the values in the word_freqs data frame
wordcloud(word_freqs$term, word_freqs$num, min.freq = 5, max.words = 500, colors = brewer.pal(8, "Paired"))



# --------------------
# Word Cloud - Trigram
# ====================

# Create a trigram tokenizer
tokenizer <- function(x)
    NGramTokenizer(x, Weka_control(min = 3, max = 3))

# Trigram term-document matrix
trigram_tdm <- TermDocumentMatrix(cleaned_av_review_corpus, control = list(tokenize = tokenizer))
trigram_tdm_m <- as.matrix(trigram_tdm)

# Term Frequency
term_frequency <- rowSums(trigram_tdm_m)

# Sort term frequency in descending order
term_frequency <- sort(term_frequency, dec = TRUE)

# Create a data frame of word_freqs
word_freqs <- data.frame(term = names(term_frequency), num = term_frequency)

# Create a word cloud for the values in the trigram word frequencies
wordcloud(word_freqs$term, word_freqs$num, min.freq = 5, max.words = 500, colors = brewer.pal(8, "Paired"))



#----------------------------
# TF-IDF Word Cloud (Task #3)
# ============================
tfidf_tdm <- TermDocumentMatrix(cleaned_av_review_corpus, control = list(weighting = weightTfIdf))
tfidf_tdm_m <- as.matrix(tfidf_tdm)

# Term Frequency
term_frequency <- rowSums(tfidf_tdm_m)

# Sort term frequency in descending order
term_frequency <- sort(term_frequency, dec = TRUE)

# Create word_freqs
word_freqs <- data.frame(term = names(term_frequency), num = term_frequency)

# Create a word cloud for the values in word frequencies
wordcloud(word_freqs$term, word_freqs$num, min.freq = 5, max.words = 1000, colors = brewer.pal(8, "Paired"))


#--------------------------------------
# Sentiment Analysis Using Bing Lexicon
# =====================================

# Tidy up unigram TDM
TDM_tweets <- TermDocumentMatrix(cleaned_av_review_corpus)
tidy_tweets <- tidy(TDM_tweets)

# Use bing lexicon for sentiment analysis
bing_lex <- get_sentiments("bing")

# Join sentiments from the lexicon to the tidy tweet table
tweet_bing_lex <- inner_join(tidy_tweets, bing_lex, by = c("term" = "word"))

# Add -1 to negative sentiment and +1 to positive sentiment
tweet_bing_lex$sentiment_n <- ifelse(tweet_bing_lex$sentiment == "negative", -1, 1)

# Get the sentiment for each document (sentiment x word count in the doc)
tweet_bing_lex$sentiment_value <- tweet_bing_lex$sentiment_n * tweet_bing_lex$count

# Get the sum sentiment by document 
bing_aggdata <- aggregate(tweet_bing_lex$sentiment_value, list(index = tweet_bing_lex$document), sum)

# Check types of data
sapply(bing_aggdata, typeof)

# Convert index to numeric
bing_aggdata$index <- as.numeric(bing_aggdata$index)

# Change column names
colnames(bing_aggdata) <- c("index", "bing_score")

# Visualize sentiment over time
ggplot(bing_aggdata, aes(index, bing_score)) + geom_point()
ggplot(bing_aggdata, aes(index, bing_score)) + geom_smooth()

# Sort the aggregated data
bing_aggdata <- bing_aggdata[order(bing_aggdata$index),]

# Display a bar chart of the sentiment over time
barplot(bing_aggdata$bing_score, names.arg = bing_aggdata$index)

# From the visualization we can see that there is overwhelmingly negative sentiment for Starbucks.
# I was curious to see what language was contributing the most to the negative sentiments.
tweet_word_sentiment <- aggregate(tweet_bing_lex$sentiment_value, list(index = tweet_bing_lex$term), sum)

# Visualize the commonly used language with bar plots
# All sentiment
tweet_word_sentiment <- tweet_word_sentiment[order(tweet_word_sentiment$x),]
barplot(tweet_word_sentiment$x, names.arg = tweet_word_sentiment$index)

# Highly Positive
tweet_word_positive <- tweet_word_sentiment[tweet_word_sentiment$x > 10,]
barplot(tweet_word_positive$x, names.arg = tweet_word_positive$index, col = 'darkgreen')

# Negative Positive
tweet_word_negative <- tweet_word_sentiment[tweet_word_sentiment$x < -10,]
barplot(tweet_word_negative$x, names.arg = tweet_word_negative$index, col = 'darkred')


#---------------------------------------------------
# Create a Comparision Cloud and a Commonality Cloud
# ==================================================

# [NOTE]: There is an interaction between the polarity function in the qdap package
#         and the tweeteR package. To use the polarity function the workspace and R kernel need to be rest.

# Reimporting libraries.
library(tm)
library(wordcloud)
# set java home for qdap library : I get an error loading the qdap library otherwise.
Sys.setenv(JAVA_HOME = 'C:/Program Files/Java/jre-9.0.4')
library(qdap)
library(RWeka)
library(tidytext)
library(dplyr)
library(tidyr)
library(ggplot2)
library(radarchart)

# Load Tweet Texts
load('D:/Analytics/Spring Semester/Text Mining/TXT #2/Data/tweet_text.RData')

# Attach polarity values to the data frame of tweets 
tweet_polarity = polarity(av$text)
av$polarity = tweet_polarity$all$polarity

# Subset the text and the polarity. 
tweets <- av[,c('text', 'polarity')]

# divide positive and negative polarity tweets and concatenate each to a single string
positive_polarity = paste(tweets[tweets$polarity > 0, "text"], collapse = " ")
negative_polarity = paste(tweets[tweets$polarity < 0, "text"], collapse = " ")

# Making a corpus of a vector source of both polarities 
mixed_polarity_corpus <- VCorpus(VectorSource(c(positive_polarity, negative_polarity)))

# Cleaning corpus - pre_processing function
clean_corpus <- function(cleaned_corpus) {
    removeURL <- content_transformer(function(x) gsub("(f|ht)tp(s?)://\\S+", "", x, perl = T))
    cleaned_corpus <- tm_map(cleaned_corpus, removeURL)
    # Remove abbreviations
    cleaned_corpus <- tm_map(cleaned_corpus, content_transformer(replace_abbreviation))
    # Convert all text to lower
    cleaned_corpus <- tm_map(cleaned_corpus, content_transformer(tolower))
    # Remove punctuations
    cleaned_corpus <- tm_map(cleaned_corpus, removePunctuation)
    # remove all numeric values
    cleaned_corpus <- tm_map(cleaned_corpus, removeNumbers)
    # Exclude English stop words
    cleaned_corpus <- tm_map(cleaned_corpus, removeWords, stopwords("english"))
    # Exclude Starbucks from the analysis
    cleaned_corpus <- tm_map(cleaned_corpus, removeWords, c("starbucks"))
    # Trim additional white space
    cleaned_corpus <- tm_map(cleaned_corpus, stripWhitespace)
    return(cleaned_corpus)
}

# Clean the corpora
cleaned_mixed_polarity_corpus <- clean_corpus(mixed_polarity_corpus)

# Create a term-document matrix
TDM <- as.matrix(TermDocumentMatrix(cleaned_mixed_polarity_corpus))
colnames(TDM) <- c("Positive Tweets", "Negative Tweets")

# Commonality cloud
commonality.cloud(TDM, colors = brewer.pal(8, "Dark2"), max.words = 1000)

# Comparison cloud
comparison.cloud(TDM, colors = brewer.pal(8, "Dark2"), max.words = 500)


#-----------------------------------------
# Emotional Analysis Using the NRC Lexicon
# ========================================

# Import the NRC Lexicon
nrc_lexicon <- get_sentiments("nrc")

# Create a corpus from the tweet texts and preprocess the text using the custom function
cleaned_av_review_corpus <- clean_corpus(VCorpus(VectorSource(av$text)))

# Create a tidy term-document matrix
tidy_tweets <- tidy(TermDocumentMatrix(cleaned_av_review_corpus))

# Join the lexicon to the tidy TDM
tidy_tweets <- inner_join(tidy_tweets, nrc_lexicon, by = c("term" = "word"))

# Aggregate the emotions
agg_emotions <- aggregate(tidy_tweets$count, list(index = tidy_tweets$sentiment), sum)

# Display the radar chart of emotions
chartJSRadar(agg_emotions)
