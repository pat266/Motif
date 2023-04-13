//
//  LinearRegression.swift
//  PHL
//
//  Created by Tran Pat on 4/1/23.
//  Copyright © 2023 PAN Weiheng. All rights reserved.
//

import Foundation

class LinearRegression {
    
    var intercept: Double = 0.0
    var slope: Double = 0.0
    
    func predict(_ xPred: Double) -> Double {
        return intercept + slope * xPred
    }
    
    func fit(x: [Double], y: [Double]) {
        if x.count == y.count {
            let n = Double(x.count)
            let xMean = x.reduce(0.0, +) / n
            let yMean = y.reduce(0.0, +) / n
            var numerator: Double = 0.0
            var denominator: Double = 0.0
            for i in 0..<x.count {
                numerator += (x[i] - xMean) * (y[i] - yMean)
                denominator += pow((x[i] - xMean), 2)
            }
            slope = numerator / denominator
            intercept = yMean - slope * xMean
        }
    }
    
    func fit(data: [(x: Double, y: Double)]) {
        let xData = data.map { $0.x }
        let yData = data.map { $0.y }
        fit(x: xData, y: yData)
    }
    
    func clear() {
        intercept = 0.0
        slope = 0.0
    }
}
