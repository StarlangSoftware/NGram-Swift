//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 28.08.2020.
//

import Foundation
import DataStructure

public class NGramNode<Symbol : Hashable>{
    
    var __children: [Symbol : NGramNode<Symbol>] = [:]
    var __symbol: Symbol? = nil
    var __count: Int = 0
    var __probability: Double = 0.0
    var __probabilityOfUnseen: Double = 0.0
    var __unknown: NGramNode<Symbol>? = nil

    /**
     * Constructor of {@link NGramNode}
     *
     * - Parameter symbol: symbol to be kept in this node.
     */
    public init(symbol: Symbol?) {
        self.__symbol = symbol
    }
    
    public init(isRootNode: Bool, lines: inout [String]){
        if !isRootNode{
            self.__symbol = (lines.removeFirst() as! Symbol)
        }
        var line = lines.removeFirst()
        line = line.trimmingCharacters(in: CharacterSet.init(charactersIn: "\t"))
        let items : [String] = line.components(separatedBy: " ")
        self.__count = Int(items[0])!
        self.__probability = Double(items[1])!
        self.__probabilityOfUnseen = Double(items[2])!
        let numberOfChildren = Int(items[3])
        if numberOfChildren! > 0{
            for _ in 0..<numberOfChildren!{
                let childNode = NGramNode<Symbol>(isRootNode: false, lines: &lines)
                self.__children[childNode.__symbol!] = childNode
            }
        }
    }
    
    public func merge(toBeMerged: NGramNode){
        for symbol in __children.keys{
            if toBeMerged.__children[symbol] != nil {
                __children[symbol]!.merge(toBeMerged: toBeMerged.__children[symbol]!)
            }
        }
        for symbol in toBeMerged.__children.keys{
            if __children[symbol] == nil{
                __children[symbol] = toBeMerged.__children[symbol]
            }
        }
    }
    
    /**
    Gets count of this node.

    - Returns: count of this node.
    */
    public func getCount() -> Int{
        return self.__count
    }

    /**
    Gets the size of children of this node.

    - Returns: size of children of NGramNode this node.
    */
    public func size() -> Int{
        return self.__children.count
    }

    /**
    Finds maximum occurrence. If height is 0, returns the count of this node.
    Otherwise, traverses this nodes' children recursively and returns maximum occurrence.

    - Parameter height : height for NGram.

    - Returns: maximum occurrence.
    */
    public func maximumOccurence(height: Int) -> Int{
        var maxValue : Int = 0
        if height == 0{
            return self.__count
        } else {
            for child in self.__children.values{
                let current = child.maximumOccurence(height: height - 1)
                if current > maxValue{
                    maxValue = current
                }
            }
            return maxValue
        }
    }

    /**
    - Returns: sum of counts of children nodes.
    */
    public func childSum() -> Double{
        var total : Double = 0
        for child in self.__children.values{
            total += Double(child.__count)
        }
        if self.__unknown != nil{
            total += Double(self.__unknown!.__count)
        }
        return total
    }

    /**
    Traverses nodes and updates counts of counts for each node.

    - Parameters:
        - countsOfCounts : counts of counts of NGrams.
        - height : height for NGram. if height = 1, If level = 1, N-Gram is treated as UniGram, if level = 2, N-Gram is treated
        as Bigram, etc.
    */
    public func updateCountsOfCounts(countsOfCounts: inout [Int], height: Int){
        if height == 0{
            countsOfCounts[self.__count] = countsOfCounts[self.__count] + 1
        } else {
            for child in self.__children.values{
                child.updateCountsOfCounts(countsOfCounts: &countsOfCounts, height: height - 1)
            }
        }
    }

    /**
    Sets probabilities by traversing nodes and adding pseudocount for each NGram.

    - Parameters:
        - pseudoCount : pseudocount added to each NGram.
        - height : height for NGram. if height = 1, If level = 1, N-Gram is treated as UniGram, if level = 2, N-Gram is treated
        as Bigram, etc.
        - vocabularySize : size of vocabulary
    */
    public func setProbabilityWithPseudoCount(pseudoCount: Double, height: Int, vocabularySize: Double){
        if height == 1{
            let total : Double = self.childSum() + pseudoCount * vocabularySize
            for child in self.__children.values{
                child.__probability = (Double(child.__count) + pseudoCount) / total
            }
            if self.__unknown != nil{
                self.__unknown!.__probability = (Double(self.__unknown!.__count) + pseudoCount) / total
            }
            self.__probabilityOfUnseen = pseudoCount / total
        } else {
            for child in self.__children.values{
                child.setProbabilityWithPseudoCount(pseudoCount: pseudoCount, height: height - 1, vocabularySize: vocabularySize)
            }
        }
    }

    /**
    Sets adjusted probabilities with counts of counts of NGrams.
    For count < 5, count is considered as ((r + 1) * N[r + 1]) / N[r]), otherwise, count is considered as it is.
    Sum of children counts are computed. Then, probability of a child node is (1 - pZero) * (r / sum) if r > 5
    otherwise, r is replaced with ((r + 1) * N[r + 1]) / N[r]) and calculated the same.

    - Parameters:
        - N : counts of counts of NGrams.
        - height : height for NGram. if height = 1, If level = 1, N-Gram is treated as UniGram, if level = 2, N-Gram is treated
        as Bigram, etc.
        - vocabularySize : size of vocabulary.
        - pZero : probability of zero.
    */
    public func setAdjustedProbability(N: [Double], height: Int, vocabularySize: Double, pZero: Double){
        if height == 1{
            var total : Double = 0
            for child in self.__children.values{
                let r : Int = child.__count
                if r <= 5{
                    let newR = (Double(r + 1) * N[r + 1]) / N[r]
                    total += newR
                } else {
                    total += Double(r)
                }
            }
            for child in self.__children.values{
                let r : Int = child.__count
                if r <= 5{
                    let newR = (Double(r + 1) * N[r + 1]) / N[r]
                    child.__probability = (1 - pZero) * (newR / total)
                } else {
                    child.__probability = (1 - pZero) * (Double(r) / total)
                }
            }
            self.__probabilityOfUnseen = pZero / (vocabularySize - Double(self.__children.count))
        } else {
            for child in self.__children.values{
                child.setAdjustedProbability(N: N, height: height - 1, vocabularySize: vocabularySize, pZero: pZero)
            }
        }
    }

    /**
    Adds NGram given as array of symbols to the node as a child.

    - Parameters:
        - s : array of symbols
        - index : start index of NGram
        - height : height for NGram. if height = 1, If level = 1, N-Gram is treated as UniGram, if level = 2, N-Gram is treated
        as Bigram, etc.
        - sentenceCount : Number of times this sentence is added.
    */
    public func addNGram(s: [Symbol], index: Int, height: Int, sentenceCount: Int = 1){
        if height == 0{
            return
        }
        let symbol : Symbol = s[index]
        var child : NGramNode<Symbol>
        if self.__children[symbol] != nil{
            child = self.__children[symbol]!
        } else {
            child = NGramNode(symbol: symbol)
            self.__children[symbol] = child
        }
        child.__count += sentenceCount
        child.addNGram(s: s, index: index + 1, height: height - 1, sentenceCount: sentenceCount)
    }

    /**
    Gets unigram probability of given symbol.

    - Parameter w1: unigram.

    - Returns: unigram probability of given symbol.
    */
    public func getUniGramProbability(w1: Symbol) -> Double{
        if self.__children[w1] != nil{
            return self.__children[w1]!.__probability
        } else if self.__unknown != nil{
            return self.__unknown!.__probability
        } else {
            return self.__probabilityOfUnseen
        }
    }

    /**
    Gets bigram probability of given symbols w1 and w2

    - Parameters:
        - w1: first gram of bigram.
        - w2: second gram of bigram.

    - Returns: probability of given bigram
    */
    public func getBiGramProbability(w1 : Symbol, w2 : Symbol) -> Double?{
        if self.__children[w1] != nil{
            let child = self.__children[w1]
            return child!.getUniGramProbability(w1: w2)
        } else if self.__unknown != nil{
            return self.__unknown!.getUniGramProbability(w1: w2)
        } else {
            return nil
        }
    }

    /**
    Gets trigram probability of given symbols w1, w2 and w3.

    - Parameters:
        - w1: first gram of trigram
        - w2: second gram of trigram
        - w3: third gram of trigram

    - Returns: probability of given trigram.
    */
    public func getTriGramProbability(w1 : Symbol, w2 : Symbol, w3: Symbol) -> Double?{
        if self.__children[w1] != nil{
            let child = self.__children[w1]
            return child!.getBiGramProbability(w1: w2, w2: w3)
        } else if self.__unknown != nil{
            return self.__unknown!.getBiGramProbability(w1: w2, w2: w3)
        } else {
            return nil
        }
    }

    /**
    Counts words recursively given height and wordCounter.
     
     - Parameters:
        - wordCounter : word counter keeping symbols and their counts.
        - height : height for NGram. if height = 1, If height = 1, N-Gram is treated as UniGram, if height = 2, N-Gram is
        treated as Bigram, etc.
    */
    public func countWords(wordCounter: CounterHashMap<Symbol>, height: Int){
        if height == 0{
            wordCounter.putNTimes(key: self.__symbol!, N: self.__count)
        } else {
            for child in self.__children.values{
                child.countWords(wordCounter: wordCounter, height: height - 1)
            }
        }
    }

    /**
    Replace words not in given dictionary.
    Deletes unknown words from children nodes and adds them to NGramNode#unknown unknown node as children
    recursively.

    - Parameter dictionary : dictionary of known words.
    */
    public func replaceUnknownWords(dictionary: Set<Symbol>){
        var childList : [NGramNode<Symbol>] = []
        for symbol in self.__children.keys{
            if !dictionary.contains(symbol){
                childList.append(self.__children[symbol]!)
            }
        }
        if childList.count > 0{
            self.__unknown = NGramNode<Symbol>(symbol: nil)
            self.__unknown!.__children = [:]
            var total : Double = 0
            for child in childList{
                for newSymbol in child.__children.keys{
                    self.__unknown!.__children[newSymbol] = child.__children[newSymbol]
                }
                total += Double(child.__count)
                self.__children[child.__symbol!] = nil
            }
            self.__unknown!.__count = Int(total)
            self.__unknown!.replaceUnknownWords(dictionary: dictionary)
        }
        for child in self.__children.values{
            child.replaceUnknownWords(dictionary: dictionary)
        }
    }

    /**
    Gets count of symbol given array of symbols and index of symbol in this array.

    - Parameters:
        - s : array of symbols
        - index : index of symbol whose count is returned

    - Returns: count of the symbol.
    */
    public func getCountForListItem(s: [Symbol], index: Int) -> Int{
        if index < s.count{
            if self.__children[s[index]] != nil {
                return self.__children[s[index]]!.getCountForListItem(s: s, index: index + 1)
            } else {
                return 0
            }
        } else {
            return self.getCount()
        }
    }

    /**
    Generates next string for given list of symbol and index
    - Parameters:
        - s : array of symbols
        - index : index of generated string

    - Returns: generated string.
    */
    public func generateNextString(s: [Symbol], index: Int) -> Symbol?{
        var total : Double = 0.0
        if index == s.count{
            let prob = Double.random(in: 0..<1)
            for node in self.__children.values{
                if prob < node.__probability + total{
                    return node.__symbol
                } else {
                    total += node.__probability
                }
            }
        } else {
            return self.__children[s[index]]!.generateNextString(s: s, index: index + 1)
        }
        return nil
    }
}
