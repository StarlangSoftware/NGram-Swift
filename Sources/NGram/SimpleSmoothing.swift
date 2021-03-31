//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 3.09.2020.
//

import Foundation

public class SimpleSmoothing<Symbol : Hashable>{
    
    public func setProbabilities(nGram: NGram<Symbol>, level: Int){
        
    }
    
    public func setProbabilitiesGeneral(nGram: NGram<Symbol>){
        self.setProbabilities(nGram: nGram, level: nGram.getN())
    }
}
