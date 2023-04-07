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
}

// actual values (intensity, weight)
let data: [(x: Double, y: Double)] =
    [
        (0.0009405085245768233, 55), // fitbit (sliding)
        (0.0011902782016330294, 0),
        (0.0010968004014756943, 105), // headphone + case (sliding)
        (0.0004814394632975258, 287),
        (0.0004429361979166672, 266) // phone
    ]
