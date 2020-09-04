import XCTest
@testable import NGram
//
//  File 2.swift
//
//
//  Created by Olcay Taner YILDIZ on 4.09.2020.
//

final class InterpolatedSmoothingTest: SimpleSmoothingTest {
    
    override func setUp(){
        super.setUp()
        let interpolatedSmoothing = InterpolatedSmoothing<String>()
        self.complexBiGram.calculateNGramProbabilitiesTrained(corpus: self.validationCorpus, trainedSmoothing: interpolatedSmoothing)
        self.complexTriGram.calculateNGramProbabilitiesTrained(corpus: self.validationCorpus, trainedSmoothing: interpolatedSmoothing)
    }
    
    func testPerplexityComplex(){
        XCTAssertEqual(917.214864, self.complexBiGram.getPerplexity(corpus: self.testCorpus), accuracy: 0.0001)
        XCTAssertEqual(3000.451177, self.complexTriGram.getPerplexity(corpus: self.testCorpus), accuracy: 0.0001)
    }

    func testCalculateNGramProbabilitiesComplex(){
        XCTAssertEqual(0.000418, self.complexBiGram.getProbability("<s>", "mustafa"), accuracy: 0.0001)
        XCTAssertEqual(0.005555, self.complexBiGram.getProbability("mustafa", "kemal"), accuracy: 0.0001)
        XCTAssertEqual(0.014406, self.complexTriGram.getProbability("<s>", "mustafa", "kemal"), accuracy: 0.0001)
        XCTAssertEqual(0.058765, self.complexTriGram.getProbability("mustafa", "kemal", "atatürk"), accuracy: 0.0001)
    }

    static var allTests = [
        ("testExample1", testPerplexityComplex),
        ("testExample2", testCalculateNGramProbabilitiesComplex),
    ]
}
