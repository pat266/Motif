//
//  Pressure.swift
//  PHL
//
//  Created by Tran Pat on 4/1/23.
//  Following the VibroScale paper
//

import Foundation

class Pressure {
    static func calculateIntensity(y_accelerometer: [Double]) -> Double {
        // subtracting all the values from the input array by the average
        let average = Double(y_accelerometer.reduce(0, +)) / Double(y_accelerometer.count)
        var new_y_accelerometer : [Double] = []
        for i in 0..<y_accelerometer.count {
            new_y_accelerometer.append(y_accelerometer[i] - average)
        }
        // take the absolute value for all values
        new_y_accelerometer = new_y_accelerometer.map(abs)
        // the mean of this abs array is the intensity
        let intensity = Double(new_y_accelerometer.reduce(0, +)) / Double(new_y_accelerometer.count)
        return intensity;
    }
}
