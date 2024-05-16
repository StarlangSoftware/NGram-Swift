//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 3.09.2020.
//

import Foundation

public class NoSmoothing<Symbol : Hashable> : SimpleSmoothing<Symbol>{
    
    /// Calculates the N-Gram probabilities with no smoothing
    /// - Parameters:
    ///   - nGram: N-Gram for which no smoothing is done.
    ///   - level: Height of the NGram node.
    override public func setProbabilities(nGram: NGram<Symbol>, level: Int){
        nGram.setProbabilityWithPseudoCount(pseudoCount: 0.0, height: level)
    }

}
