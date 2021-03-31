//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 3.09.2020.
//

import Foundation
import Sampling

public class InterpolatedSmoothing<Symbol: Hashable>: TrainedSmoothing<Symbol>{
    
    private var lambda1: Double = 0.0
    private var lambda2: Double = 0.0
    private var simpleSmoothing: SimpleSmoothing<Symbol>?

    /**
    Constructor of InterpolatedSmoothing

    - Parameter simpleSmoothing : smoothing method.
    */
    public init(simpleSmoothing : SimpleSmoothing<Symbol>? = nil){
        if simpleSmoothing == nil{
            self.simpleSmoothing = GoodTuringSmoothing()
        } else {
            self.simpleSmoothing = simpleSmoothing
        }
    }

    /**
    The algorithm tries to optimize the best lambda for a given corpus. The algorithm uses perplexity on the
    validation set as the optimization criterion.

    - Parameters:
        - nGrams : 10 N-Grams learned for different folds of the corpus. nGrams[i] is the N-Gram trained with i'th train fold
        of the corpus.
        - kFoldCrossValidation : Cross-validation data used in training and testing the N-grams.
        - lowerBound : Initial lower bound for optimizing the best lambda.

    - Returns: Best lambda optimized with k-fold crossvalidation.
    */
    public func learnBestLambda(nGrams: [NGram<Symbol>], kFoldCrossValidation: KFoldCrossValidation<[Symbol]>, lowerBound: Double) -> Double{
        var bestPrevious : Double = -1.0
        var upperBound : Double = 0.999
        var bestLambda : Double = (lowerBound + upperBound) / 2
        let numberOfParts = 5
        var newLowerBound = lowerBound
        var testFolds : [[[Symbol]]] = []
        for i in 0..<10{
            testFolds.append(kFoldCrossValidation.getTestFold(k: i))
        }
        while true{
            var bestPerplexity : Double = 1000000000
            var value : Double = lowerBound
            while value <= upperBound{
                var perplexity : Double = 0
                for i in 0..<10{
                    nGrams[i].setLambda2(lambda1: value)
                    perplexity += nGrams[i].getPerplexity(corpus: testFolds[i])
                }
                if perplexity < bestPerplexity{
                    bestPerplexity = perplexity
                    bestLambda = value
                }
                value += (upperBound - lowerBound) / Double(numberOfParts)
            }
            newLowerBound = self.newLowerBound(current: bestLambda, currentLowerBound: newLowerBound, currentUpperBound: upperBound, numberOfParts: numberOfParts)
            upperBound = self.newUpperBound(current: bestLambda, currentLowerBound: newLowerBound, currentUpperBound: upperBound, numberOfParts: numberOfParts)
            if bestPrevious != -1{
                if abs(bestPrevious - bestPerplexity) / bestPerplexity < 0.001{
                    break
                }
            }
            bestPrevious = bestPerplexity
        }
        return bestLambda
    }

    /**
    The algorithm tries to optimize the best lambdas (lambda1, lambda2) for a given corpus. The algorithm uses
    perplexity on the validation set as the optimization criterion.

    - Parameters:
        - nGrams : 10 N-Grams learned for different folds of the corpus. nGrams[i] is the N-Gram trained with i'th train fold
        of the corpus.
        - kFoldCrossValidation : Cross-validation data used in training and testing the N-grams.
        - lowerBound1 : Initial lower bound for optimizing the best lambda1.
        - lowerBound2 : Initial lower bound for optimizing the best lambda2.

    - Returns: bestLambda1 and bestLambda2
    */
    public func learnBestLambdas(nGrams: [NGram<Symbol>], kFoldCrossValidation: KFoldCrossValidation<[Symbol]>, lowerBound1: Double, lowerBound2: Double) -> (Double, Double){
        var upperBound1 : Double = 0.999
        var upperBound2 : Double = 0.999
        var newLowerBound1 : Double = lowerBound1
        var newLowerBound2 : Double = lowerBound2
        var bestPrevious : Double = -1.0
        var bestLambda1 : Double = (lowerBound1 + upperBound1) / 2
        var bestLambda2 : Double = (lowerBound2 + upperBound2) / 2
        let numberOfParts = 5
        var testFolds : [[[Symbol]]] = []
        for i in 0..<10{
            testFolds.append(kFoldCrossValidation.getTestFold(k: i))
        }
        while true{
            var bestPerplexity : Double = 1000000000
            var value1 : Double = lowerBound1
            while value1 <= upperBound1{
                var value2 : Double = lowerBound2
                while value2 <= upperBound2 && value1 + value2 < 1{
                    var perplexity = 0.0
                    for i in 0..<10{
                        nGrams[i].setLambda3(lambda1: value1, lambda2: value2)
                        perplexity += nGrams[i].getPerplexity(corpus: testFolds[i])
                    }
                    if perplexity < bestPerplexity{
                        bestPerplexity = Double(perplexity)
                        bestLambda1 = value1
                        bestLambda2 = value2
                    }
                    value2 += (upperBound1 - lowerBound1) / Double(numberOfParts)
                }
                value1 += (upperBound1 - lowerBound1) / Double(numberOfParts)
            }
            newLowerBound1 = self.newLowerBound(current: bestLambda1, currentLowerBound: newLowerBound1, currentUpperBound: upperBound1, numberOfParts: numberOfParts)
            upperBound1 = self.newUpperBound(current: bestLambda1, currentLowerBound: newLowerBound1, currentUpperBound: upperBound1, numberOfParts: numberOfParts)
            newLowerBound2 = self.newLowerBound(current: bestLambda2, currentLowerBound: newLowerBound2, currentUpperBound: upperBound2, numberOfParts: numberOfParts)
            upperBound2 = self.newUpperBound(current: bestLambda2, currentLowerBound: newLowerBound2, currentUpperBound: upperBound2, numberOfParts: numberOfParts)
            if bestPrevious != -1{
                if fabs(bestPrevious - bestPerplexity) / bestPerplexity < 0.001{
                    break
                }
            }
            bestPrevious = bestPerplexity
        }
        return (bestLambda1, bestLambda2)
    }

    /**
    Wrapper function to learn the parameters (lambda1 and lambda2) in interpolated smoothing. The function first
    creates K NGrams with the train folds of the corpus. Then optimizes lambdas with respect to the test folds of
    the corpus depending on given N.

    PARAMETERS
    ----------
    corpus : list
        Train corpus used to optimize lambda parameters
    N : int
        N in N-Gram.
    */
    public override func learnParameters(corpus: [[Symbol]], N: Int){
        if N <= 1{
            return
        }
        let K = 10
        var nGrams : [NGram<Symbol>] = []
        let kFoldCrossValidation : KFoldCrossValidation<[Symbol]> = KFoldCrossValidation(instanceList: corpus, K: K, seed: 0)
        for i in 0..<K{
            nGrams.append(NGram(N: N, corpus: kFoldCrossValidation.getTrainFold(k: i)))
            for j in 2..<N + 1{
                nGrams[i].calculateNGramProbabilitiesSimpleLevel(simpleSmoothing: self.simpleSmoothing!, level: j)
            }
            nGrams[i].calculateNGramProbabilitiesSimpleLevel(simpleSmoothing: self.simpleSmoothing!, level: 1)
        }
        if N == 2{
            self.lambda1 = self.learnBestLambda(nGrams: nGrams, kFoldCrossValidation: kFoldCrossValidation, lowerBound: 0.1)
        } else if N == 3{
            (self.lambda1, self.lambda2) = self.learnBestLambdas(nGrams: nGrams, kFoldCrossValidation: kFoldCrossValidation, lowerBound1: 0.1, lowerBound2: 0.1)
        }
    }

    /**
    Wrapper function to set the N-gram probabilities with interpolated smoothing.

    - Parameters:
        - nGram : N-Gram for which the probabilities will be set.
        - level : Level for which N-Gram probabilities will be set. Probabilities for different levels of the N-gram can be
        set with this function. If level = 1, N-Gram is treated as UniGram, if level = 2, N-Gram is treated as
        Bigram, etc.
    */
    public override func setProbabilities(nGram: NGram<Symbol>, level: Int){
        for j in 2..<nGram.getN() + 1{
            nGram.calculateNGramProbabilitiesSimpleLevel(simpleSmoothing: self.simpleSmoothing!, level: j)
        }
        nGram.calculateNGramProbabilitiesSimpleLevel(simpleSmoothing: self.simpleSmoothing!, level: 1)
        if nGram.getN() == 2{
            nGram.setLambda2(lambda1: self.lambda1)
        } else if nGram.getN() == 3{
            nGram.setLambda3(lambda1: self.lambda1, lambda2: self.lambda2)
        }
    }
}
