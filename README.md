N-Gram
============

An N-gram is a sequence of N words: a 2-gram (or bigram) is a two-word sequence of words like “lütfen ödevinizi”, “ödevinizi çabuk”, or ”çabuk veriniz”, and a 3-gram (or trigram) is a three-word sequence of words like “lütfen ödevinizi çabuk”, or “ödevinizi çabuk veriniz”.

## Smoothing

To keep a language model from assigning zero probability to unseen events, we’ll have to shave off a bit of probability mass from some more frequent events and give it to the events we’ve never seen. This modification is called smoothing or discounting.

### Laplace Smoothing

The simplest way to do smoothing is to add one to all the bigram counts, before we normalize them into probabilities. All the counts that used to be zero will now have a count of 1, the counts of 1 will be 2, and so on. This algorithm is called Laplace smoothing.

### Add-k Smoothing

One alternative to add-one smoothing is to move a bit less of the probability mass from the seen to the unseen events. Instead of adding 1 to each count, we add a fractional count k. This algorithm is therefore called add-k smoothing.

For Developers
============
You can also see [Java](https://github.com/starlangsoftware/NGram), [Python](https://github.com/starlangsoftware/NGram-Py), [Cython](https://github.com/starlangsoftware/NGram-Cy), [C#](https://github.com/starlangsoftware/NGram-CS), or [C++](https://github.com/starlangsoftware/NGram-CPP) repository.

## Requirements

* Xcode Editor
* [Git](#git)

### Git

Install the [latest version of Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).

## Download Code

In order to work on code, create a fork from GitHub page. 
Use Git for cloning the code to your local or below line for Ubuntu:

	git clone <your-fork-git-link>

A directory called NGram-Swift will be created. Or you can use below link for exploring the code:

	git clone https://github.com/starlangsoftware/NGram-Swift.git

## Open project with XCode

To import projects from Git with version control:

* XCode IDE, select Clone an Existing Project.

* In the Import window, paste github URL.

* Click Clone.

Result: The imported project is listed in the Project Explorer view and files are loaded.


## Compile

**From IDE**

After being done with the downloading and opening project, select **Build** option from **Product** menu. After compilation process, user can run NGram-Swift.

Detailed Description
============

+ [Training NGram](#training-ngram)
+ [Using NGram](#using-ngram)
+ [Saving NGram](#saving-ngram)
+ [Loading NGram](#loading-ngram)

## Training NGram
     
To create an empty NGram model:

	init(N: Int)

For example,

	a = NGram(N: 2)

this creates an empty NGram model.

To add an sentence to NGram

	func addNGramSentence(symbols: [Symbol], sentenceCount: Int = 1)

For example,

	var text1: [String] = ["<s>", "ali", "topu", "at", "mehmet", "ayşeye", "gitti", "</s>"]
	var text2: [String] = ["<s>", "ali", "top", "at", "ayşe", "eve", "gitti", "</s>"]
	nGram = NGram(N: 2)
	nGram.addNGramSentence(text1)
	nGram.addNGramSentence(text2)

with the lines above, an empty NGram model is created and the sentences text1 and text2 are
added to the bigram model.

Another possibility is to create an Ngram from a corpus consisting of two dimensional String array such as

	var simpleCorpus : [[String]] = ...
	nGram = NGram(N: 1, corpus: simpleCorpus)

### Training With Smoothings

NoSmoothing class is the simplest technique for smoothing. It doesn't require training.
Only probabilities are calculated using counters. For example, to calculate the probabilities
of a given NGram model using NoSmoothing:

	let simpleSmoothing = NoSmoothing<String>()
	a.calculateNGramProbabilitiesSimple(simpleSmoothing: simpleSmoothing)

LaplaceSmoothing class is a simple smoothing technique for smoothing. It doesn't require
training. Probabilities are calculated adding 1 to each counter. For example, to calculate
the probabilities of a given NGram model using LaplaceSmoothing:

        let simpleSmoothing = LaplaceSmoothing<String>()
        a.calculateNGramProbabilitiesSimple(simpleSmoothing: simpleSmoothing)

GoodTuringSmoothing class is a complex smoothing technique that doesn't require training.
To calculate the probabilities of a given NGram model using GoodTuringSmoothing:

        let simpleSmoothing = GoodTuringSmoothing<String>()
        a.calculateNGramProbabilitiesSimple(simpleSmoothing: simpleSmoothing)

AdditiveSmoothing class is a smoothing technique that requires training.

	var validationCorpus : [[String]] = ...
        let additiveSmoothing = AdditiveSmoothing<String>()
        a.calculateNGramProbabilitiesTrained(corpus: validationCorpus, trainedSmoothing: additiveSmoothing)

## Using NGram

To find the probability of an NGram:

	func getProbability(_ args: Symbol...) -> Double

For example, to find the bigram probability:

	a.getProbability("jack", "reads")

To find the trigram probability:

	a.getProbability("jack", "reads", "books")
