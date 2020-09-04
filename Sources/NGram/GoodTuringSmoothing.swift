//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 3.09.2020.
//

import Foundation
import Math

class GoodTuringSmoothing<Symbol : Hashable> : SimpleSmoothing<Symbol>{
    
    /**
    Given counts of counts, this function will calculate the estimated counts of counts c$^*$ with
    Good-Turing smoothing. First, the algorithm filters the non-zero counts from counts of counts array and constructs
    c and r arrays. Then it constructs Z_n array with Z_n = (2C_n / (r_{n+1} - r_{n-1})). The algorithm then uses
    simple linear regression on Z_n values to estimate w_1 and w_0, where log(N[i]) = w_1log(i) + w_0

    - Parameter countsOfCounts : Counts of counts. countsOfCounts[1] is the number of words occurred once in the corpus. countsOfCounts[i] is
        the number of words occurred i times in the corpus.

    - Returns: Estimated counts of counts array. N[1] is the estimated count for out of vocabulary words.
    */
    private func linearRegressionOnCountsOfCounts(countsOfCounts: [Int]) -> [Double]{
        var N : [Double] = Array(repeating: 0.0, count: countsOfCounts.count)
        var r : [Int] = []
        var c : [Int] = []
        for i in 1..<countsOfCounts.count{
            if countsOfCounts[i] != 0{
                r.append(i)
                c.append(countsOfCounts[i])
            }
        }
        let A = Matrix(row: 2, col: 2)
        let y = Vector(size: 2, x: 0)
        for i in 0..<r.count{
            let xt = log(Double(r[i]))
            var rt: Double
            if i == 0{
                rt = log(Double(c[i]))
            } else {
                if i == r.count - 1{
                    rt = log((1.0 * Double(c[i])) / Double(r[i] - r[i - 1]))
                } else {
                    rt = log((2.0 * Double(c[i])) / Double(r[i + 1] - r[i - 1]))
                }
            }
            A.addValue(rowNo: 0, colNo: 0, value: 1.0)
            A.addValue(rowNo: 0, colNo: 1, value: xt)
            A.addValue(rowNo: 1, colNo: 0, value: xt)
            A.addValue(rowNo: 1, colNo: 1, value: xt * xt)
            y.addValue(index: 0, value: rt)
            y.addValue(index: 1, value: rt * xt)
        }
        A.inverse()
        let w = A.multiplyWithVectorFromRight(v: y)
        let w0 = w.getValue(index: 0)
        let w1 = w.getValue(index: 1)
        for i in 1..<countsOfCounts.count{
            N[i] = exp(log(Double(i)) * w1 + w0)
        }
        return N
    }

    /**
    Wrapper function to set the N-gram probabilities with Good-Turing smoothing. N[1] / sum_{i=1}^infinity N_i is
    the out of vocabulary probability.

    - Parameters:
        - nGram : N-Gram for which the probabilities will be set.
        - level : Level for which N-Gram probabilities will be set. Probabilities for different levels of the N-gram can be
        set with this function. If level = 1, N-Gram is treated as UniGram, if level = 2, N-Gram is treated as
        Bigram, etc.
    */
    public override func setProbabilities(nGram: NGram<Symbol>, level: Int){
        let countsOfCounts = nGram.calculateCountsOfCounts(height: level)
        let N = self.linearRegressionOnCountsOfCounts(countsOfCounts: countsOfCounts)
        var total : Double = 0.0
        for r in 1..<countsOfCounts.count{
            total += Double(countsOfCounts[r]) * Double(r)
        }
        nGram.setAdjustedProbability(countsOfCounts: N, height: level, pZero: N[1] / total)
    }

}
