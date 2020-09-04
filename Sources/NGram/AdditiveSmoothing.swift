//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 3.09.2020.
//

import Foundation
import Sampling

class AdditiveSmoothing<Symbol : Hashable>:TrainedSmoothing<Symbol>{
    
    private var delta: Double = 0.0

    /**
    The algorithm tries to optimize the best delta for a given corpus. The algorithm uses perplexity on the
    validation set as the optimization criterion.

    - Parameters:
        - nGrams : 10 N-Grams learned for different folds of the corpus. nGrams[i] is the N-Gram trained with i'th train fold
        of the corpus.
        - kFoldCrossValidation: Cross-validation data used in training and testing the N-grams.
        - lowerBound : Initial lower bound for optimizing the best delta.

    - Returns: Best delta optimized with k-fold crossvalidation.
    */
    public func learnBestDelta(nGrams: [NGram<Symbol>], kFoldCrossValidation: KFoldCrossValidation<[Symbol]>, lowerBound: Double) -> Double{
        var bestPrevious : Double = -1
        var upperBound : Double = 1.0
        var newLowerBound = lowerBound
        var bestDelta : Double = (lowerBound + upperBound) / 2
        let numberOfParts = 5
        while true{
            var bestPerplexity : Double = 100000000
            var value : Double = lowerBound
            while value <= upperBound{
                var perplexity = 0.0
                for i in 0..<10{
                    nGrams[i].setProbabilityWithPseudoCount(pseudoCount: value, height: nGrams[i].getN())
                    perplexity += nGrams[i].getPerplexity(corpus: kFoldCrossValidation.getTestFold(k: i))
                }
                if perplexity < bestPerplexity{
                    bestPerplexity = perplexity
                    bestDelta = value
                }
                value += (upperBound - lowerBound) / Double(numberOfParts)
            }
            newLowerBound = self.newLowerBound(current: bestDelta, currentLowerBound: newLowerBound, currentUpperBound: upperBound, numberOfParts: numberOfParts)
            upperBound = self.newUpperBound(current: bestDelta, currentLowerBound: newLowerBound, currentUpperBound: upperBound, numberOfParts: numberOfParts)
            if bestPrevious != -1{
                if abs(bestPrevious - bestPerplexity) / bestPerplexity < 0.001{
                    break
                }
            }
            bestPrevious = bestPerplexity
        }
        return bestDelta
    }

    /**
    Wrapper function to learn the parameter (delta) in additive smoothing. The function first creates K NGrams
    with the train folds of the corpus. Then optimizes delta with respect to the test folds of the corpus.

    - Parameters:
        - corpus : Train corpus used to optimize delta parameter
        - N : N in N-Gram.
    */
    public override func learnParameters(corpus: [[Symbol]], N: Int){
        let K = 10
        var nGrams : [NGram<Symbol>] = []
        let kFoldCrossValidation : KFoldCrossValidation<[Symbol]> = KFoldCrossValidation(instanceList: corpus, K: K, seed: 0)
        for i in 0..<K{
            nGrams.append(NGram(N: N, corpus: kFoldCrossValidation.getTrainFold(k: i)))
        }
        self.delta = self.learnBestDelta(nGrams: nGrams, kFoldCrossValidation: kFoldCrossValidation, lowerBound: 0.1)
    }

    /**
    Wrapper function to set the N-gram probabilities with additive smoothing.

    - Parameters:
        - nGram : N-Gram for which the probabilities will be set.
        - level : Level for which N-Gram probabilities will be set. Probabilities for different levels of the N-gram can be
        set with this function. If level = 1, N-Gram is treated as UniGram, if level = 2, N-Gram is treated as
        Bigram, etc.
    */
    public override func setProbabilities(nGram: NGram<Symbol>, level: Int){
        nGram.setProbabilityWithPseudoCount(pseudoCount: self.delta, height: level)
    }

    /**
    Gets the best delta.

    - Returns: learned best delta
    */
    public func getDelta() -> Double{
        return self.delta
    }
}
