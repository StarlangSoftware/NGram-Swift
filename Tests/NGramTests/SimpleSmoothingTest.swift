import XCTest
@testable import NGram
//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 3.09.2020.
//

class SimpleSmoothingTest: CorpusTest {
    
    var simpleUniGram: NGram<String> = NGram(N: 1)
    var simpleBiGram: NGram<String> = NGram(N: 1)
    var simpleTriGram: NGram<String> = NGram(N: 1)
    var complexUniGram: NGram<String> = NGram(N: 1)
    var complexBiGram: NGram<String> = NGram(N: 1)
    var complexTriGram: NGram<String> = NGram(N: 1)
    var simpleCorpus : [[String]] = []
    var trainCorpus: [[String]] = []
    var testCorpus: [[String]] = []
    var validationCorpus: [[String]] = []

    override func setUp(){
        self.simpleCorpus = [["<s>", "ali", "topu", "at", "mehmet", "ayşeye", "gitti", "</s>"],
                             ["<s>", "ali", "top", "at", "ayşe", "eve", "gitti", "</s>"],
                             ["<s>", "ayşe", "kitabı", "ver", "</s>"],
                             ["<s>", "ali", "topu", "mehmete", "at", "</s>"],
                             ["<s>", "ali", "topu", "at", "mehmet", "ayşeyle", "gitti", "</s>"]]
        self.simpleUniGram = NGram(N: 1, corpus: self.simpleCorpus)
        self.simpleBiGram = NGram(N: 2, corpus: self.simpleCorpus)
        self.simpleTriGram = NGram(N: 3, corpus: self.simpleCorpus)
        self.trainCorpus = self.readCorpus(fileName: "train.txt")
        self.complexUniGram = NGram(N: 1, corpus: self.trainCorpus)
        self.complexBiGram = NGram(N: 2, corpus: self.trainCorpus)
        self.complexTriGram = NGram(N: 3, corpus: self.trainCorpus)
        self.testCorpus = self.readCorpus(fileName: "test.txt")
        self.validationCorpus = self.readCorpus(fileName: "validation.txt")
    }
    
}
