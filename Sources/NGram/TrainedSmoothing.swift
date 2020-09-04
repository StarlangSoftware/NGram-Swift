//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 3.09.2020.
//

import Foundation

class TrainedSmoothing<Symbol : Hashable> : SimpleSmoothing<Symbol>{
    
    public func learnParameters(corpus: [[Symbol]], N: Int){
    }
    
    /**
    Calculates new lower bound.

    - Parameters:
        - current : current value.
        - currentLowerBound : current lower bound
        - currentUpperBound : current upper bound
        - numberOfParts : number of parts between lower and upper bound.

    - Returns: new lower bound
    */
    public func newLowerBound(current: Double, currentLowerBound: Double,
                                    currentUpperBound: Double, numberOfParts: Int) -> Double{
        if current != currentLowerBound{
            return current - (currentUpperBound - currentLowerBound) / Double(numberOfParts)
        } else {
            return current / Double(numberOfParts)
        }
    }

    /**
    Calculates new upper bound.

    - Parameters:
        - current : current value.
        - currentLowerBound : current lower bound
        - currentUpperBound : current upper bound
        - numberOfParts : number of parts between lower and upper bound.

    - Returns: new upper bound
    */
    public func newUpperBound(current: Double, currentLowerBound: Double,
                                    currentUpperBound: Double, numberOfParts: Int) -> Double{
        if current != currentUpperBound{
            return current + (currentUpperBound - currentLowerBound) / Double(numberOfParts)
        } else {
            return current * Double(numberOfParts)
        }
    }

    /**
    Wrapper function to learn parameters of the smoothing method and set the N-gram probabilities.

    - Parameters:
        - corpus : Train corpus used to optimize parameters of the smoothing method.
        - nGram : N-Gram for which the probabilities will be set.
    */
    public func train(corpus: [[Symbol]], nGram: NGram<Symbol>){
        self.learnParameters(corpus: corpus, N: nGram.getN())
        self.setProbabilitiesGeneral(nGram: nGram)
    }
}
