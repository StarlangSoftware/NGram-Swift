import XCTest
@testable import NGram
//
//  File 2.swift
//  
//
//  Created by Olcay Taner YILDIZ on 4.09.2020.
//

final class NoSmoothingTest: SimpleSmoothingTest {
    
    override func setUp(){
        super.setUp()
        let simpleSmoothing = NoSmoothing<String>()
        self.simpleUniGram.calculateNGramProbabilitiesSimple(simpleSmoothing: simpleSmoothing)
        self.simpleBiGram.calculateNGramProbabilitiesSimple(simpleSmoothing: simpleSmoothing)
        self.simpleTriGram.calculateNGramProbabilitiesSimple(simpleSmoothing: simpleSmoothing)
        self.complexUniGram.calculateNGramProbabilitiesSimple(simpleSmoothing: simpleSmoothing)
        self.complexBiGram.calculateNGramProbabilitiesSimple(simpleSmoothing: simpleSmoothing)
        self.complexTriGram.calculateNGramProbabilitiesSimple(simpleSmoothing: simpleSmoothing)
    }
    
    func testPerplexitySimple(){
        XCTAssertEqual(12.318362, self.simpleUniGram.getPerplexity(corpus: self.simpleCorpus), accuracy: 0.0001)
        XCTAssertEqual(1.573148, self.simpleBiGram.getPerplexity(corpus: self.simpleCorpus), accuracy: 0.0001)
        XCTAssertEqual(1.248330, self.simpleTriGram.getPerplexity(corpus: self.simpleCorpus), accuracy: 0.0001)
    }

    func testPerplexityComplex(){
        XCTAssertEqual(3220.299369, self.complexUniGram.getPerplexity(corpus: self.trainCorpus), accuracy: 0.0001)
        XCTAssertEqual(32.362912, self.complexBiGram.getPerplexity(corpus: self.trainCorpus), accuracy: 0.0001)
        XCTAssertEqual(2.025259, self.complexTriGram.getPerplexity(corpus: self.trainCorpus), accuracy: 0.0001)
    }

    func testCalculateNGramProbabilitiesSimple(){
        XCTAssertEqual(5 / 35.0, self.simpleUniGram.getProbability("<s>"))
        XCTAssertEqual(0.0, self.simpleUniGram.getProbability("mahmut"))
        XCTAssertEqual(1.0 / 35.0, self.simpleUniGram.getProbability("kitabı"))
        XCTAssertEqual(4 / 5.0, self.simpleBiGram.getProbability("<s>", "ali"))
        XCTAssertEqual(0 / 2.0, self.simpleBiGram.getProbability("ayşe", "ali"))
        XCTAssertEqual(0.0, self.simpleBiGram.getProbability("mahmut", "ali"))
        XCTAssertEqual(2 / 4.0, self.simpleBiGram.getProbability("at", "mehmet"))
        XCTAssertEqual(1 / 4.0, self.simpleTriGram.getProbability("<s>", "ali", "top"))
        XCTAssertEqual(0 / 1.0, self.simpleTriGram.getProbability("ayşe", "kitabı", "at"))
        XCTAssertEqual(0.0, self.simpleTriGram.getProbability("ayşe", "topu", "at"))
        XCTAssertEqual(0.0, self.simpleTriGram.getProbability("mahmut", "evde", "kal"))
        XCTAssertEqual(2 / 3.0, self.simpleTriGram.getProbability("ali", "topu", "at"))
    }

    func testCalculateNGramProbabilitiesComplex(){
        XCTAssertEqual(20000 / 376019.0, self.complexUniGram.getProbability("<s>"))
        XCTAssertEqual(50 / 376019.0, self.complexUniGram.getProbability("atatürk"))
        XCTAssertEqual(11 / 20000.0, self.complexBiGram.getProbability("<s>", "mustafa"))
        XCTAssertEqual(3 / 138.0, self.complexBiGram.getProbability("mustafa", "kemal"))
        XCTAssertEqual(1 / 11.0, self.complexTriGram.getProbability("<s>", "mustafa", "kemal"))
        XCTAssertEqual(1 / 3.0, self.complexTriGram.getProbability("mustafa", "kemal", "atatürk"))
    }

    static var allTests = [
        ("testExample1", testPerplexitySimple),
        ("testExample2", testPerplexityComplex),
        ("testExample3", testCalculateNGramProbabilitiesSimple),
        ("testExample4", testCalculateNGramProbabilitiesComplex),
    ]
}
