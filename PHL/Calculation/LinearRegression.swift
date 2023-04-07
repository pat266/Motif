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
    
    // iterative variables
    let numberOfIterations = 100
    let alpha = 0.0001
    
    func predict(_ xPred: Double) -> Double {
        return intercept + slope * xPred
    }
    
    func fit(x: [Double], y: [Double]) {
        if x.count == y.count {
            for _ in 1...numberOfIterations {
                for i in 0..<y.count {
                    let difference = y[i] - predict(x[i])
                    intercept += alpha * difference
                    slope += alpha * difference * x[i]
                }
            }
        }
    }
    
    func fit(data: [(x: Double, y: Double)]) {
        for _ in 1...numberOfIterations {
            for i in 0..<data.count {
                let difference = data[i].y - predict(data[i].x)
                intercept += alpha * difference
                slope += alpha * difference * data[i].x
            }
        }
    }
    
    func clear() {
        intercept = 0.0
        slope = 0.0
    }
}
