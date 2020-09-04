import XCTest
//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 3.09.2020.
//

import Foundation

class CorpusTest : XCTestCase{
    
    public func readCorpus(fileName: String) -> [[String]]{
        var corpus : [[String]] = []
        let thisSourceFile = URL(fileURLWithPath: #file)
        let thisDirectory = thisSourceFile.deletingLastPathComponent()
        let url = thisDirectory.appendingPathComponent(fileName)
        do{
            let fileContent = try String(contentsOf: url, encoding: .utf8)
            let lines = fileContent.split(whereSeparator: \.isNewline)
            for line in lines{
                let items = line.components(separatedBy: " ")
                corpus.append(items)
            }
        } catch {
        }
        return corpus
    }
}
