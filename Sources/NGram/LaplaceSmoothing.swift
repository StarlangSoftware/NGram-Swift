//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 3.09.2020.
//

import Foundation

public class LaplaceSmoothing<Symbol: Hashable> : SimpleSmoothing<Symbol>{
    
    private var delta: Double
    
    public init(delta : Double = 1.0){
        self.delta = delta
    }
    
    /**
    Wrapper function to set the N-gram probabilities with laplace smoothing.

    - Parameters:
        - nGram : N-Gram for which the probabilities will be set.
        - level : height for NGram. if level = 1, If level = 1, N-Gram is treated as UniGram, if level = 2, N-Gram is treated
        as Bigram, etc.
    */
    public override func setProbabilities(nGram: NGram<Symbol>, level: Int){
        nGram.setProbabilityWithPseudoCount(pseudoCount: self.delta, height: level)
    }

}
