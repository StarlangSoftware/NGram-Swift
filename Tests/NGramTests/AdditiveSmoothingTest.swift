import XCTest
@testable import NGram
//
//  File 2.swift
//
//
//  Created by Olcay Taner YILDIZ on 4.09.2020.
//

final class AdditiveSmoothingTest: SimpleSmoothingTest {
    
    var delta1 : Double = 0.0
    var delta2 : Double = 0.0
    var delta3 : Double = 0.0

    override func setUp(){
        super.setUp()
        let additiveSmoothing = AdditiveSmoothing<String>()
        self.complexUniGram.calculateNGramProbabilitiesTrained(corpus: self.validationCorpus, trainedSmoothing: additiveSmoothing)
        self.delta1 = additiveSmoothing.getDelta()
        self.complexBiGram.calculateNGramProbabilitiesTrained(corpus: self.validationCorpus, trainedSmoothing: additiveSmoothing)
        self.delta2 = additiveSmoothing.getDelta()
        self.complexTriGram.calculateNGramProbabilitiesTrained(corpus: self.validationCorpus, trainedSmoothing: additiveSmoothing)
        self.delta3 = additiveSmoothing.getDelta()
    }
    
    func testPerplexityComplex(){
        XCTAssertEqual(4043.947022, self.complexUniGram.getPerplexity(corpus: self.testCorpus), accuracy: 0.0001)
        XCTAssertEqual(9220.218871, self.complexBiGram.getPerplexity(corpus: self.testCorpus), accuracy: 0.0001)
        XCTAssertEqual(30695.701941, self.complexTriGram.getPerplexity(corpus: self.testCorpus), accuracy: 0.0001)
    }

    func testCalculateNGramProbabilitiesComplex(){
        XCTAssertEqual((20000 + self.delta1) / (376019.0 + self.delta1 * (self.complexUniGram.vocabularySize() + 1)), self.complexUniGram.getProbability("<s>"))
        XCTAssertEqual((50 + self.delta1) / (376019.0 + self.delta1 * (self.complexUniGram.vocabularySize() + 1)), self.complexUniGram.getProbability("atatürk"))
        XCTAssertEqual((11 + self.delta2) / (20000.0 + self.delta2 * (self.complexBiGram.vocabularySize() + 1)), self.complexBiGram.getProbability("<s>", "mustafa"))
        XCTAssertEqual((3 + self.delta2) / (138.0 + self.delta2 * (self.complexBiGram.vocabularySize() + 1)), self.complexBiGram.getProbability("mustafa", "kemal"))
        XCTAssertEqual((1 + self.delta3) / (11.0 + self.delta3 * (self.complexTriGram.vocabularySize() + 1)), self.complexTriGram.getProbability("<s>", "mustafa", "kemal"))
        XCTAssertEqual((1 + self.delta3) / (3.0 + self.delta3 * (self.complexTriGram.vocabularySize() + 1)), self.complexTriGram.getProbability("mustafa", "kemal", "atatürk"))
    }

    static var allTests = [
        ("testExample1", testPerplexityComplex),
        ("testExample2", testCalculateNGramProbabilitiesComplex),
    ]
}
