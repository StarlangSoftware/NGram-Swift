//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 3.09.2020.
//

import Foundation

class NoSmoothing<Symbol : Hashable> : SimpleSmoothing<Symbol>{
    
    override public func setProbabilities(nGram: NGram<Symbol>, level: Int){
        nGram.setProbabilityWithPseudoCount(pseudoCount: 0.0, height: level)
    }

}
