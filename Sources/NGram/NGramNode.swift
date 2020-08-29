//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 28.08.2020.
//

import Foundation

class NGramNode<Symbol : Hashable>{
    
    var __children: [Symbol : NGramNode<Symbol>] = [:]
    var __symbol: Symbol? = nil
    var __count: Int
    var __probability: Double = 0.0
    var __probabilityOfUnseen: Double = 0.0
    var __unknown: NGramNode<Symbol>? = nil

    /**
     * Constructor of {@link NGramNode}
     *
     * - Parameter symbol: symbol to be kept in this node.
     */
    public init(symbol: Symbol) {
        self.__symbol = symbol
        self.__count = 0
    }
    
    public init(isRootNode: Bool, lines: inout [String]){
        if !isRootNode{
            self.__symbol = (lines.removeFirst() as! Symbol)
        }
        let line = lines.removeFirst()
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

}
