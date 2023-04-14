//
//  Pressure.swift
//  PHL
//
//  Created by Tran Pat on 4/1/23.
//  Following the VibroScale paper
//

import Foundation

class Pressure {
    static func calculateIntensity(accelerometer: [Double]) -> Double {
        // subtracting all the values from the input array by the average
        let average = Double(accelerometer.reduce(0, +)) / Double(accelerometer.count)
        var new_accelerometer : [Double] = []
        for i in 0..<accelerometer.count {
            new_accelerometer.append(accelerometer[i] - average)
        }
        // take the absolute value for all values
        new_accelerometer = new_accelerometer.map(abs)
        // the mean of this abs array is the intensity
        let intensity = Double(new_accelerometer.reduce(0, +)) / Double(new_accelerometer.count)
        return intensity;
    }
    
    static func calculateSmoothedAverage(values: [Double], windowSize: Int) -> [Double] {
        var smoothedAverages = Array(repeating: Double(), count: values.count)
        let n = values.count
        if n == 0 || windowSize <= 1 {
            return values
        }
        var windowSize = windowSize
        if windowSize > n {
            windowSize = n
        }
        let paddingSizeLeft = (windowSize - 1) / 2
        let paddingSizeRight = windowSize - 1 - paddingSizeLeft
        var windowSum = 0.0
        for i in 0..<windowSize {
            windowSum += values[i]
        }
        for i in 0...paddingSizeLeft {
            smoothedAverages[i] = windowSum / Double(windowSize)
        }
        for i in windowSize..<n {
            windowSum += values[i] - values[i - windowSize]
            smoothedAverages[i - windowSize + paddingSizeLeft + 1] = windowSum / Double(windowSize)
        }
        for i in n - paddingSizeRight..<n {
            smoothedAverages[i] = windowSum / Double(windowSize)
        }
        return smoothedAverages
    }
}
