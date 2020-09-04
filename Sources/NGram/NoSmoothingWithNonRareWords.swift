//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 3.09.2020.
//

import Foundation

class NoSmoothingWithNonRareWords<Symbol : Hashable>: NoSmoothing<Symbol>{
    
    private var dictionary: Set<Symbol> = []
    private var probability: Double
    
    /**
    Constructor of NoSmoothingWithNonRareWords

    - Parameter probability : float
    */
    public init(probability: Double){
        self.probability = probability
    }
    
    /**
    Wrapper function to set the N-gram probabilities with no smoothing and replacing unknown words not found in
    nonrare words.

    - Parameters:
        - nGram : N-Gram for which the probabilities will be set.
        - level : Level for which N-Gram probabilities will be set. Probabilities for different levels of the N-gram can be
        set with this function. If level = 1, N-Gram is treated as UniGram, if level = 2, N-Gram is treated as
        Bigram, etc.
    */
    public override func setProbabilities(nGram: NGram<Symbol>, level: Int){
        self.dictionary = nGram.constructDictionaryWithNonRareWords(level: level, probability: self.probability)
        nGram.replaceUnknownWords(dictionary: self.dictionary)
        super.setProbabilities(nGram: nGram, level: level)
    }

}
