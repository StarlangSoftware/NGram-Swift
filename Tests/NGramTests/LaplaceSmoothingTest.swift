import XCTest
@testable import NGram
//
//  File 2.swift
//
//
//  Created by Olcay Taner YILDIZ on 4.09.2020.
//

final class LaplaceSmoothingTest: SimpleSmoothingTest {
    
    override func setUp(){
        super.setUp()
        let simpleSmoothing = LaplaceSmoothing<String>()
        self.simpleUniGram.calculateNGramProbabilitiesSimple(simpleSmoothing: simpleSmoothing)
        self.simpleBiGram.calculateNGramProbabilitiesSimple(simpleSmoothing: simpleSmoothing)
        self.simpleTriGram.calculateNGramProbabilitiesSimple(simpleSmoothing: simpleSmoothing)
        self.complexUniGram.calculateNGramProbabilitiesSimple(simpleSmoothing: simpleSmoothing)
        self.complexBiGram.calculateNGramProbabilitiesSimple(simpleSmoothing: simpleSmoothing)
        self.complexTriGram.calculateNGramProbabilitiesSimple(simpleSmoothing: simpleSmoothing)
    }
    
    func testPerplexitySimple(){
        XCTAssertEqual(12.809502, self.simpleUniGram.getPerplexity(corpus: self.simpleCorpus), accuracy: 0.0001)
        XCTAssertEqual(6.914532, self.simpleBiGram.getPerplexity(corpus: self.simpleCorpus), accuracy: 0.0001)
        XCTAssertEqual(7.694528, self.simpleTriGram.getPerplexity(corpus: self.simpleCorpus), accuracy: 0.0001)
    }

    func testPerplexityComplex(){
        XCTAssertEqual(4085.763010, self.complexUniGram.getPerplexity(corpus: self.testCorpus), accuracy: 0.0001)
        XCTAssertEqual(24763.660225, self.complexBiGram.getPerplexity(corpus: self.testCorpus), accuracy: 0.0001)
        XCTAssertEqual(49579.187475, self.complexTriGram.getPerplexity(corpus: self.testCorpus), accuracy: 0.0001)
    }

    func testCalculateNGramProbabilitiesSimple(){
        XCTAssertEqual((5 + 1) / (35 + self.simpleUniGram.vocabularySize() + 1), self.simpleUniGram.getProbability("<s>"))
        XCTAssertEqual((0 + 1) / (35 + self.simpleUniGram.vocabularySize() + 1), self.simpleUniGram.getProbability("mahmut"))
        XCTAssertEqual((1 + 1) / (35 + self.simpleUniGram.vocabularySize() + 1), self.simpleUniGram.getProbability("kitabı"))
        XCTAssertEqual((4 + 1) / (5 + self.simpleBiGram.vocabularySize() + 1), self.simpleBiGram.getProbability("<s>", "ali"))
        XCTAssertEqual((0 + 1) / (2 + self.simpleBiGram.vocabularySize() + 1), self.simpleBiGram.getProbability("ayşe", "ali"))
        XCTAssertEqual(1 / (self.simpleBiGram.vocabularySize() + 1), self.simpleBiGram.getProbability("mahmut", "ali"))
        XCTAssertEqual((2 + 1) / (4 + self.simpleBiGram.vocabularySize() + 1), self.simpleBiGram.getProbability("at", "mehmet"))
        XCTAssertEqual((1 + 1) / (4.0 + self.simpleTriGram.vocabularySize() + 1), self.simpleTriGram.getProbability("<s>", "ali", "top"))
        XCTAssertEqual((0 + 1) / (1.0 + self.simpleTriGram.vocabularySize() + 1), self.simpleTriGram.getProbability("ayşe", "kitabı", "at"))
        XCTAssertEqual(1 / (self.simpleTriGram.vocabularySize() + 1), self.simpleTriGram.getProbability("ayşe", "topu", "at"))
        XCTAssertEqual(1 / (self.simpleTriGram.vocabularySize() + 1), self.simpleTriGram.getProbability("mahmut", "evde", "kal"))
        XCTAssertEqual((2 + 1) / (3.0 + self.simpleTriGram.vocabularySize() + 1), self.simpleTriGram.getProbability("ali", "topu", "at"))
    }

    func testCalculateNGramProbabilitiesComplex(){
        XCTAssertEqual((20000 + 1) / (376019.0 + self.complexUniGram.vocabularySize() + 1), self.complexUniGram.getProbability("<s>"))
        XCTAssertEqual((50 + 1) / (376019.0 + self.complexUniGram.vocabularySize() + 1), self.complexUniGram.getProbability("atatürk"))
        XCTAssertEqual((11 + 1) / (20000.0 + self.complexBiGram.vocabularySize() + 1), self.complexBiGram.getProbability("<s>", "mustafa"))
        XCTAssertEqual((3 + 1) / (138.0 + self.complexBiGram.vocabularySize() + 1), self.complexBiGram.getProbability("mustafa", "kemal"))
        XCTAssertEqual((1 + 1) / (11.0 + self.complexTriGram.vocabularySize() + 1), self.complexTriGram.getProbability("<s>", "mustafa", "kemal"))
        XCTAssertEqual((1 + 1) / (3.0 + self.complexTriGram.vocabularySize() + 1), self.complexTriGram.getProbability("mustafa", "kemal", "atatürk"))
    }

    static var allTests = [
        ("testExample1", testPerplexitySimple),
        ("testExample2", testPerplexityComplex),
        ("testExample3", testCalculateNGramProbabilitiesSimple),
        ("testExample4", testCalculateNGramProbabilitiesComplex),
    ]
}
