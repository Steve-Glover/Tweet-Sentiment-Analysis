# Tweet-Sentiment-Analysis using R
Steve Glover
***

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; The purpose of this project was to explore various methods of text analysis on tweets using R. Given the bad press Starbucks has received over the last week, I thought it would be interesting to explore how well common text analysis practices capture the overall attitude toward Starbucks at present. I pulled the chatter of 2,000 tweets that included the hashtag “Starbucks” for the analysis using the twitteR API library. 

## Word Clouds
***
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Prior to diving into the sentiment analysis, I was curious to see if there were any words or phrases that were used more often than others. The frequency at which a word or phrase is used can provide a high-level insight into the attitudes and emotion of the aggregate text. Word clouds are a very simple and convenient way to evaluate the frequency of words and phrases in the corpus.  Generating a word cloud in R is a surprisingly simple procedure. The code is detailed in the attached script.
1.	Convert the encoding of the text to eliminate unrecognized characters
2.	Transform the collection of text to vector corpus
3.	Preprocess the text
  * Remove URLs
  * Replace abbreviations
  * Convert all text to lowercase
  * Remove punctuation
  * Remove numerical characters
  * Exclude commonly used stop words
  * Strip excessive which space
4.	Create a Term Document Matrix (TDM)
5.	Using the TDM, simply sum the frequency of each word
6.	Create a two-column data frame of the words and their frequencies
7.	Visualize the word cloud using the wordcloud function in the wordcloud library

**Note:** bigram and trigram word clouds are created using the same procedure. However, capture two-word or three-word phrases,  we must use a bigram or trigram tokenizer as an argument when creating the TDM using the TermDocumentMatrix function.  Likewise, we can use the Term Frequency, Inverse Frequency Document Frequency weighting  (TF-IDF) for each word by including the weighting parameter when creating the TDM. 

### Unigram Word Cloud
![unigram_wordcloud](https://user-images.githubusercontent.com/22827466/39077613-555551e0-44d1-11e8-8c9c-303b173eff46.png)

### Bigram Word Cloud
![bigram_wordcloud](https://user-images.githubusercontent.com/22827466/39077626-6c7eec64-44d1-11e8-84e6-86de7a9fc3e9.png)

### Trigram Word Cloud
![trigram_wordcloud](https://user-images.githubusercontent.com/22827466/39077636-8049e456-44d1-11e8-8f83-e542e001364c.png)

### TF-IDF Word Cloud
![tf-idf workdcloud](https://user-images.githubusercontent.com/22827466/39077648-8dd90ad4-44d1-11e8-99fb-3adf1eb507eb.png)
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Through reviewing the word clouds we can see that the unigram word cloud really does not offer very much insight at all.  However, it appears that two and three-word phrases give us more of an indication of what we may expect to find in our Sentiment Analysis. 
<br>

## Sentiment Analysis
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; R has a number of useful lexicons that can enable us to extract sentiment and emotion from a corpus of text with ease. For the purpose of this project, I explored three popular word association lexicons: bing, qdap, and NRC.
<br><br>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; The Bing lexicon associates positive words with a  “+” and negative words with a “-“. When analyzing whether a document has positive or negative sentiment, we only have to aggregate the scores of the words in the text.
<br><br>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Unlike the Bing lexicon, the qdap lexicon weights positive and negative words in the presence of other words. Through the use of amplification, de-amplification, and negate word libraries, qdap adjusts the intensity of a positive or negative word in the document. Qdap uses the weights and the total number of words in a document to calculate a total polarity score for the document.
<br><br>

The NRC lexicon is emotion association lexicon. The lexicon associates words with emotions such as anger, anticipation, disgust, fear, joy, and sadness. Evaluating the frequency of the emotional words used in a corpus can give us a high-level view of the emotional mix of the language used in the documents.
<br><br>

The procedure to evaluate the sentiment of a corpus of documents is essentially the same regardless of which lexicon is used with small variations. I followed the following steps to analyze the sentiments of the tweets:
1.	Use the tidy function to create a “tidy” data frame using the TDM. The tidy function transforms the TDM from a wide and shallow matrix to a narrow and deep matrix. The tidy matrix details the count of each word for each document. 
2.	Left join the values associated with each word from the lexicon that is being used. Note that if the bing lexicon is being used a conversion is needed to transform the “-“ to a -1 and the “+” to a 1. These values can then be multiplied by the frequency the word appears in the document to get a total score. 
3.	The sentiment values are then aggregated for each document and visualized.
<br>

### Bing Sentiment Behavior with Smoothing
![bing sentiment over time](https://user-images.githubusercontent.com/22827466/39077668-adaab506-44d1-11e8-9297-a72a15a0adc1.png)

### Bing Sentiment Bar Chart
![bar chart bing sentiment measure over time](https://user-images.githubusercontent.com/22827466/39077682-bb55b7b4-44d1-11e8-8a61-065da7a2e9d0.png)
