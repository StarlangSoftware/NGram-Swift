import XCTest
@testable import NGram
//
//  File 2.swift
//
//
//  Created by Olcay Taner YILDIZ on 4.09.2020.
//

final class GoodTuringsSmoothingTest: SimpleSmoothingTest {
    
    override func setUp(){
        super.setUp()
        let simpleSmoothing = GoodTuringSmoothing<String>()
        self.simpleUniGram.calculateNGramProbabilitiesSimple(simpleSmoothing: simpleSmoothing)
        self.simpleBiGram.calculateNGramProbabilitiesSimple(simpleSmoothing: simpleSmoothing)
        self.simpleTriGram.calculateNGramProbabilitiesSimple(simpleSmoothing: simpleSmoothing)
        self.complexUniGram.calculateNGramProbabilitiesSimple(simpleSmoothing: simpleSmoothing)
        self.complexBiGram.calculateNGramProbabilitiesSimple(simpleSmoothing: simpleSmoothing)
        self.complexTriGram.calculateNGramProbabilitiesSimple(simpleSmoothing: simpleSmoothing)
    }
    
    func testPerplexitySimple(){
        XCTAssertEqual(14.500734, self.simpleUniGram.getPerplexity(corpus: self.simpleCorpus), accuracy: 0.0001)
        XCTAssertEqual(2.762526, self.simpleBiGram.getPerplexity(corpus: self.simpleCorpus), accuracy: 0.0001)
        XCTAssertEqual(3.685001, self.simpleTriGram.getPerplexity(corpus: self.simpleCorpus), accuracy: 0.0001)
    }

    func testPerplexityComplex(){
        XCTAssertEqual(1290.97916, self.complexUniGram.getPerplexity(corpus: self.testCorpus), accuracy: 0.0001)
        XCTAssertEqual(8331.518540, self.complexBiGram.getPerplexity(corpus: self.testCorpus), accuracy: 0.0001)
        XCTAssertEqual(39184.430078, self.complexTriGram.getPerplexity(corpus: self.testCorpus), accuracy: 0.0001)
    }

    func testCalculateNGramProbabilitiesSimple(){
        XCTAssertEqual(0.116607, simpleUniGram.getProbability("<s>"), accuracy: 0.0001);
        XCTAssertEqual(0.149464, simpleUniGram.getProbability("mahmut"), accuracy: 0.0001);
        XCTAssertEqual(0.026599, simpleUniGram.getProbability("kitabı"), accuracy: 0.0001);
        XCTAssertEqual(0.492147, simpleBiGram.getProbability("<s>", "ali"), accuracy: 0.0001);
        XCTAssertEqual(0.030523, simpleBiGram.getProbability("ayşe", "ali"), accuracy: 0.0001);
        XCTAssertEqual(0.0625, simpleBiGram.getProbability("mahmut", "ali"), accuracy: 0.0001);
        XCTAssertEqual(0.323281, simpleBiGram.getProbability("at", "mehmet"), accuracy: 0.0001);
        XCTAssertEqual(0.049190, simpleTriGram.getProbability("<s>", "ali", "top"), accuracy: 0.0001);
        XCTAssertEqual(0.043874, simpleTriGram.getProbability("ayşe", "kitabı", "at"), accuracy: 0.0001);
        XCTAssertEqual(0.0625, simpleTriGram.getProbability("ayşe", "topu", "at"), accuracy: 0.0001);
        XCTAssertEqual(0.0625, simpleTriGram.getProbability("mahmut", "evde", "kal"), accuracy: 0.0001);
        XCTAssertEqual(0.261463, simpleTriGram.getProbability("ali", "topu", "at"), accuracy: 0.0001);
    }

    func testCalculateNGramProbabilitiesComplex(){
        XCTAssertEqual(0.050745, complexUniGram.getProbability("<s>"), accuracy: 0.0001);
        XCTAssertEqual(0.000126, complexUniGram.getProbability("atatürk"), accuracy: 0.0001);
        XCTAssertEqual(0.000497, complexBiGram.getProbability("<s>", "mustafa"), accuracy: 0.0001);
        XCTAssertEqual(0.014000, complexBiGram.getProbability("mustafa", "kemal"), accuracy: 0.0001);
        XCTAssertEqual(0.061028, complexTriGram.getProbability("<s>", "mustafa", "kemal"), accuracy: 0.0001);
        XCTAssertEqual(0.283532, complexTriGram.getProbability("mustafa", "kemal", "atatürk"), accuracy: 0.0001);
    }

    static var allTests = [
        ("testExample1", testPerplexitySimple),
        ("testExample2", testPerplexityComplex),
        ("testExample3", testCalculateNGramProbabilitiesSimple),
        ("testExample4", testCalculateNGramProbabilitiesComplex),
    ]
}
