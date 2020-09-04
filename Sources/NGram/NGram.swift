//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 31.08.2020.
//

import Foundation
import DataStructure

class NGram<Symbol: Hashable>{
    
    var rootNode: NGramNode<Symbol>? = nil
    var __N: Int = 0
    var __lambda1: Double = 0.0
    var __lambda2: Double = 0.0
    var __Interpolated: Bool = false
    var __vocabulary: Set<Symbol> = []
    var __probabilityOfUnseen: [Double] = []

    public init(N: Int){
        self.__N = N;
    }

    public init(N: Int, corpus: [[Symbol]]){
        self.__N = N;
        self.rootNode = NGramNode(symbol: nil)
        self.__probabilityOfUnseen = Array(repeating: 0.0, count: N)
        for i in 0..<corpus.count{
            self.addNGramSentence(symbols: corpus[i])
        }
    }

    public init(fileName: String){
        let thisSourceFile = URL(fileURLWithPath: #file)
        let thisDirectory = thisSourceFile.deletingLastPathComponent()
        let url = thisDirectory.appendingPathComponent(fileName)
        do{
            let fileContent = try String(contentsOf: url, encoding: .utf8)
            var lines : [String] = fileContent.split(whereSeparator: \.isNewline).map(String.init)
            var items : [String] = lines.removeFirst().split(separator: " ").map(String.init)
            self.__N = Int(items[0])!
            self.__lambda1 = Double(items[1])!
            self.__lambda2 = Double(items[2])!
            items = lines.removeFirst().split(separator: " ").map(String.init)
            for i in 0..<items.count{
                self.__probabilityOfUnseen[i] = Double(items[i])!
            }
            let vocabularySize = Int(lines.removeFirst())!
            for _ in 0..<vocabularySize{
                self.__vocabulary.insert(lines.removeFirst() as! Symbol)
            }
            self.rootNode = NGramNode(isRootNode: true, lines: &lines)
        } catch {
        }
    }
    
    /**
    - Returns: size of ngram.
    */
    public func getN() -> Int{
        return self.__N
    }

    /**
    Set size of ngram.

    - Parameter N : size of ngram
    */
    public func setN(N: Int){
        self.__N = N
    }

    /**
    Adds given sentence to set the vocabulary and create and add ngrams of the sentence to NGramNode the rootNode

    - Parameters:
        - symbols : Sentence whose ngrams are added.
        - sentenceCount : Number of times this sentence is added.
    */
    public func addNGramSentence(symbols: [Symbol], sentenceCount: Int = 1){
        for s in symbols{
            self.__vocabulary.insert(s)
        }
        for j in 0..<symbols.count - self.__N + 1{
            self.rootNode!.addNGram(s: symbols, index: j, height: self.__N, sentenceCount: sentenceCount)
        }
    }

    /**
    Adds given array of symbols to set the vocabulary and to NGramNode the rootNode

    - Parameter symbols : ngram added.
    */
    public func addNGram(symbols: [Symbol]){
        for s in symbols{
            self.__vocabulary.insert(s)
        }
        self.rootNode!.addNGram(s: symbols, index: 0, height: self.__N)
    }

    /**
    - Returns: vocabulary size.
    */
    public func vocabularySize() -> Double{
        return Double(self.__vocabulary.count)
    }

    /**
    Sets lambda, Interpolation ratio, for bigram and unigram probabilities.
    ie. lambda1 * bigramProbability + (1 - lambda1) * unigramProbability

    - Parameter lambda1 : Interpolation ratio for bigram probabilities
    */
    public func setLambda2(lambda1: Double){
        if self.__N == 2{
            self.__Interpolated = true
            self.__lambda1 = lambda1
        }
    }

    /**
    Sets lambdas, Interpolation ratios, for trigram, bigram and unigram probabilities.
    ie. lambda1 * trigramProbability + lambda2 * bigramProbability  + (1 - lambda1 - lambda2) * unigramProbability

    - Parameters:
        - lambda1 : Interpolation ratio for trigram probabilities
        - lambda2 : Interpolation ratio for bigram probabilities
    */
    public func setLambda3(lambda1: Double, lambda2: Double){
        if self.__N == 3{
            self.__Interpolated = true
            self.__lambda1 = lambda1
            self.__lambda2 = lambda2
        }
    }

    /**
    Calculates NGram probabilities using given corpus and TrainedSmoothing smoothing method.

    - Parameters:
        - corpus : corpus for calculating NGram probabilities.
        - trainedSmoothing : instance of smoothing method for calculating ngram probabilities.
    */
    public func calculateNGramProbabilitiesTrained(corpus: [[Symbol]], trainedSmoothing: TrainedSmoothing<Symbol>){
        trainedSmoothing.train(corpus: corpus, nGram: self)
    }

    /**
    Calculates NGram probabilities using simple smoothing.

    - Parameter simpleSmoothing : SimpleSmoothing
    */
    public func calculateNGramProbabilitiesSimple(simpleSmoothing: SimpleSmoothing<Symbol>){
        simpleSmoothing.setProbabilitiesGeneral(nGram: self)
    }

    /**
    Calculates NGram probabilities given simple smoothing and level.

    - Parameters:
        - simpleSmoothing : SimpleSmoothing
        - level : Level for which N-Gram probabilities will be set.
    */
    public func calculateNGramProbabilitiesSimpleLevel(simpleSmoothing: SimpleSmoothing<Symbol>, level: Int){
        simpleSmoothing.setProbabilities(nGram: self, level: level)
    }

    /**
    Replaces words not in set given dictionary.

    - Parameter dictionary : dictionary of known words.
    */
    public func replaceUnknownWords(dictionary: Set<Symbol>){
        self.rootNode!.replaceUnknownWords(dictionary: dictionary)
    }

    /**
    Constructs a dictionary of nonrare words with given N-Gram level and probability threshold.

    - Parameters:
        - level : Level for counting words. Counts for different levels of the N-Gram can be set. If level = 1, N-Gram is
        treated as UniGram, if level = 2, N-Gram is treated as Bigram, etc.
        - probability : probability threshold for nonrare words.

    - Returns: set of nonrare words.
    */
    public func constructDictionaryWithNonRareWords(level: Int, probability: Double) -> Set<Symbol>{
        var result : Set<Symbol> = []
        let wordCounter : CounterHashMap<Symbol> = CounterHashMap()
        self.rootNode!.countWords(wordCounter: wordCounter, height: level)
        let total : Int = wordCounter.sumOfCounts()
        for symbol in wordCounter.keys(){
            if Double(wordCounter.count(key: symbol)) / Double(total) > probability{
                result.insert(symbol)
            }
        }
        return result
    }

    /**
    Calculates unigram perplexity of given corpus. First sums negative log likelihoods of all unigrams in corpus.
    Then returns exp of average negative log likelihood.

    - Parameter corpus : corpus whose unigram perplexity is calculated.

    - Returns: unigram perplexity of corpus.
    */
    private func getUniGramPerplexity(corpus: [[Symbol]]) -> Double{
        var total : Double = 0
        var count : Double = 0
        for i in 0..<corpus.count{
            for j in 0..<corpus[i].count{
                let p = self.getProbability(corpus[i][j])
                total -= log(p)
                count += 1
            }
        }
        return exp(total / count)
    }

    /**
    Calculates bigram perplexity of given corpus. First sums negative log likelihoods of all bigrams in corpus.
    Then returns exp of average negative log likelihood.

    - Parameter corpus : corpus whose bigram perplexity is calculated.

    - Returns: bigram perplexity of corpus.
    */
    private func getBiGramPerplexity(corpus: [[Symbol]]) -> Double{
        var total : Double = 0
        var count : Double = 0
        for i in 0..<corpus.count{
            for j in 0..<corpus[i].count - 1{
                let p = self.getProbability(corpus[i][j], corpus[i][j + 1])
                total -= log(p)
                count += 1
            }
        }
        return exp(total / count)
    }

    /**
    Calculates trigram perplexity of given corpus. First sums negative log likelihoods of all trigrams in corpus.
    Then returns exp of average negative log likelihood.

    - Parameter corpus : corpus whose trigram perplexity is calculated.

    - Returns: trigram perplexity of corpus.
    */
    private func getTriGramPerplexity(corpus: [[Symbol]]) -> Double{
        var total : Double = 0
        var count : Double = 0
        for i in 0..<corpus.count{
            for j in 0..<corpus[i].count - 2{
                let p = self.getProbability(corpus[i][j], corpus[i][j + 1], corpus[i][j + 2])
                total -= log(p)
                count += 1
            }
        }
        return exp(total / count)
    }

    /**
    Calculates the perplexity of given corpus depending on N-Gram model (unigram, bigram, trigram, etc.)

    - Parameter corpus : corpus whose perplexity is calculated.

    - Returns: perplexity of given corpus
    */
    public func getPerplexity(corpus: [[Symbol]]) -> Double{
        if self.__N == 1{
            return self.getUniGramPerplexity(corpus: corpus)
        } else if self.__N == 2{
            return self.getBiGramPerplexity(corpus: corpus)
        } else if self.__N == 3{
            return self.getTriGramPerplexity(corpus: corpus)
        } else {
            return 0
        }
    }

    /**
    Gets probability of sequence of symbols depending on N in N-Gram. If N is 1, returns unigram probability.
    If N is 2, if Interpolated is true, then returns Interpolated bigram and unigram probability, otherwise returns
    only bigram probability.
    If N is 3, if Interpolated is true, then returns Interpolated trigram, bigram and unigram probability, otherwise
    returns only trigram probability.

    - Parameter args: symbols sequence of symbol.

    - Returns: probability of given sequence.
    */
    public func getProbability(_ args: Symbol...) -> Double{
        if self.__N == 1{
            return self.getUniGramProbability(w1: args[0])
        } else if self.__N == 2{
            if args.count == 1{
                return self.getUniGramProbability(w1: args[0])
            }
            if self.__Interpolated{
                return self.__lambda1 * self.getBiGramProbability(w1: args[0], w2: args[1]) + (1 - self.__lambda1) * self.getUniGramProbability(w1: args[1])
            } else {
                return self.getBiGramProbability(w1: args[0], w2: args[1])
            }
        } else if self.__N == 3{
            if args.count == 1{
                return self.getUniGramProbability(w1: args[0])
            } else if args.count == 2{
                return self.getBiGramProbability(w1: args[0], w2: args[1])
            }
            if self.__Interpolated{
                return self.__lambda1 * self.getTriGramProbability(w1: args[0], w2: args[1], w3: args[2]) +
                    self.__lambda2 * self.getBiGramProbability(w1: args[1], w2: args[2]) +
                    (1 - self.__lambda1 - self.__lambda2) * self.getUniGramProbability(w1: args[2])
            } else {
                return self.getTriGramProbability(w1: args[0], w2: args[1], w3: args[2])
            }
        } else {
            return 0.0
        }
    }

    /**
    Gets unigram probability of given symbol.

    - Parameter w1: a unigram symbol.

    - Returns: probability of given unigram.
    */
    private func getUniGramProbability(w1 : Symbol) -> Double{
        return self.rootNode!.getUniGramProbability(w1: w1)
    }

    /**
    Gets bigram probability of given symbols.

    - Parameters:
        - w1: first gram of bigram
        - w2: second gram of bigram

    - Returns: probability of bigram formed by w1 and w2.
    */
    private func getBiGramProbability(w1 : Symbol, w2: Symbol) -> Double{
        let probability = self.rootNode!.getBiGramProbability(w1: w1, w2: w2)
        if probability != nil{
            return probability!
        } else {
            return self.__probabilityOfUnseen[1]
        }
    }

    /**
    Gets trigram probability of given symbols.

    - Parameters:
        - w1: first gram of trigram
        - w2: second gram of trigram
        - w3: third gram of trigram

    - Returns: probability of trigram formed by w1, w2, w3.
    */
    public func getTriGramProbability(w1: Symbol, w2: Symbol,  w3: Symbol) -> Double{
        let probability = self.rootNode!.getTriGramProbability(w1: w1, w2: w2, w3: w3)
        if probability != nil{
            return probability!
        } else {
            return self.__probabilityOfUnseen[2]
        }
    }

    /**
    Gets count of given sequence of symbol.

    - Parameter symbols : sequence of symbol.

    - Returns: count of symbols.
    */
    public func getCount(symbols: [Symbol]) -> Int{
        return self.rootNode!.getCountForListItem(s: symbols, index: 0)
    }

    /**
    Sets probabilities by adding pseudocounts given height and pseudocount.

    - Parameters:
        - pseudoCount : fpseudocount added to all N-Grams.
        - height : height for NGram. if height = 1, If level = 1, N-Gram is treated as UniGram, if level = 2, N-Gram is treated
        as Bigram, etc.
    */
    public func setProbabilityWithPseudoCount(pseudoCount: Double, height: Int){
        var vocabularySize : Double
        if pseudoCount != 0{
            vocabularySize = self.vocabularySize() + 1
        } else {
            vocabularySize = self.vocabularySize()
        }
        self.rootNode!.setProbabilityWithPseudoCount(pseudoCount: pseudoCount, height: height, vocabularySize: vocabularySize)
        if pseudoCount != 0{
            self.__probabilityOfUnseen[height - 1] = 1.0 / vocabularySize
        } else {
            self.__probabilityOfUnseen[height - 1] = 0.0
        }
    }

    /**
    Find maximum occurrence in given height.

    - Parameter height : height for occurrences. If height = 1, N-Gram is treated as UniGram, if height = 2, N-Gram is treated as
        Bigram, etc.

    - Returns: maximum occurrence in given height.
    */
    public func maximumOccurence(height: Int) -> Int{
        return self.rootNode!.maximumOccurence(height: height)
    }

    /**
    Update counts of counts of N-Grams with given counts of counts and given height.

    - Parameters:
        - countsOfCounts : updated counts of counts.
        - height : height for NGram. If height = 1, N-Gram is treated as UniGram, if height = 2, N-Gram is treated as Bigram, etc.
    */
    public func updateCountsOfCounts(countsOfCounts: inout [Int], height: Int){
        self.rootNode!.updateCountsOfCounts(countsOfCounts: &countsOfCounts, height: height)
    }

    /**
    Calculates counts of counts of NGrams.

    - Parameter height : height for NGram. If height = 1, N-Gram is treated as UniGram, if height = 2, N-Gram is treated as Bigram, etc.

    - Returns: counts of counts of NGrams.
    */
    public func calculateCountsOfCounts(height: Int) -> [Int]{
        let maxCount = self.maximumOccurence(height: height)
        var countsOfCounts : [Int] = Array(repeating: 0, count: maxCount + 2)
        self.updateCountsOfCounts(countsOfCounts: &countsOfCounts, height: height)
        return countsOfCounts
    }

    /**
    Sets probability with given counts of counts and pZero.

    - Parameters:
        - countsOfCounts : counts of counts of NGrams.
        - height : height for NGram. If height = 1, N-Gram is treated as UniGram, if height = 2, N-Gram is treated as Bigram, etc.
        - pZero : probability of zero.
    */
    public func setAdjustedProbability(countsOfCounts: [Double], height: Int, pZero: Double){
        self.rootNode!.setAdjustedProbability(N: countsOfCounts, height: height, vocabularySize: self.vocabularySize() + 1, pZero: pZero)
        self.__probabilityOfUnseen[height - 1] = 1.0 / (self.vocabularySize() + 1)
    }

}
