import XCTest
@testable import NGram

final class NGramTest: CorpusTest {
    
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
    
    func testGetCountSimple(){
        XCTAssertEqual(5, self.simpleUniGram.getCount(symbols: ["<s>"]))
        XCTAssertEqual(0, self.simpleUniGram.getCount(symbols: ["mahmut"]))
        XCTAssertEqual(1, self.simpleUniGram.getCount(symbols: ["kitabı"]))
        XCTAssertEqual(4, self.simpleBiGram.getCount(symbols: ["<s>", "ali"]))
        XCTAssertEqual(0, self.simpleBiGram.getCount(symbols: ["ayşe", "ali"]))
        XCTAssertEqual(0, self.simpleBiGram.getCount(symbols: ["mahmut", "ali"]))
        XCTAssertEqual(2, self.simpleBiGram.getCount(symbols: ["at", "mehmet"]))
        XCTAssertEqual(1, self.simpleTriGram.getCount(symbols: ["<s>", "ali", "top"]))
        XCTAssertEqual(0, self.simpleTriGram.getCount(symbols: ["ayşe", "kitabı", "at"]))
        XCTAssertEqual(0, self.simpleTriGram.getCount(symbols: ["ayşe", "topu", "at"]))
        XCTAssertEqual(0, self.simpleTriGram.getCount(symbols: ["mahmut", "evde", "kal"]))
        XCTAssertEqual(2, self.simpleTriGram.getCount(symbols: ["ali", "topu", "at"]))
    }

    func testGetCountComplex(){
        XCTAssertEqual(20000, self.complexUniGram.getCount(symbols: ["<s>"]))
        XCTAssertEqual(50, self.complexUniGram.getCount(symbols: ["atatürk"]))
        XCTAssertEqual(11, self.complexBiGram.getCount(symbols: ["<s>", "mustafa"]))
        XCTAssertEqual(3, self.complexBiGram.getCount(symbols: ["mustafa", "kemal"]))
        XCTAssertEqual(1, self.complexTriGram.getCount(symbols: ["<s>", "mustafa", "kemal"]))
        XCTAssertEqual(1, self.complexTriGram.getCount(symbols: ["mustafa", "kemal", "atatürk"]))
    }

    func testVocabularySizeSimple(){
        XCTAssertEqual(15, self.simpleUniGram.vocabularySize())
    }

    func testVocabularySizeComplex(){
        XCTAssertEqual(57625, self.complexUniGram.vocabularySize())
        self.complexUniGram = NGram(N: 1, corpus: self.testCorpus)
        XCTAssertEqual(55485, self.complexUniGram.vocabularySize())
        self.complexUniGram = NGram(N: 1, corpus: self.validationCorpus)
        XCTAssertEqual(35663, self.complexUniGram.vocabularySize())
    }

    func testMerge(){
        self.simpleUniGram = NGram(fileName: "simple1a.txt")
        self.simpleUniGram.merge(toBeMerged: NGram(fileName: "simple1b.txt"))
        XCTAssertEqual(18, self.simpleUniGram.vocabularySize())
        self.simpleBiGram = NGram(fileName: "simple2a.txt")
        self.simpleBiGram.merge(toBeMerged: NGram(fileName: "simple2b.txt"))
        self.simpleBiGram.merge(toBeMerged: NGram(fileName: "simple2c.txt"))
        self.simpleBiGram.merge(toBeMerged: NGram(fileName: "simple2d.txt"))
        XCTAssertEqual(21, self.simpleBiGram.vocabularySize())
        self.simpleTriGram = NGram(fileName: "simple3a.txt")
        self.simpleTriGram.merge(toBeMerged: NGram(fileName: "simple3b.txt"))
        self.simpleTriGram.merge(toBeMerged: NGram(fileName: "simple3c.txt"))
        XCTAssertEqual(20, self.simpleTriGram.vocabularySize())
    }

    static var allTests = [
        ("testExample1", testGetCountSimple),
        ("testExample2", testGetCountComplex),
        ("testExample3", testVocabularySizeSimple),
        ("testExample4", testVocabularySizeComplex),
        ("testExample5", testMerge)
    ]
}
