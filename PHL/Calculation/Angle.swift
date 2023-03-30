//
//  Angle.swift
//  PHL
//
//  Created by Tran Pat on 3/28/23.
//  Copyright © 2023 PAN Weiheng. All rights reserved.
//

import Foundation
import Swift

class Angle {
    static func calculatePhoneAngle(x_accelerometer: Double,
                                    y_accelerometer: Double,
                                    z_accelerometer: Double) -> Double {
        let angle_radians = atan(sqrt(pow(x_accelerometer, 2) + pow(y_accelerometer, 2)) / z_accelerometer)
        var angle_degrees = angle_radians * (180 / Double.pi)
        angle_degrees *= -1 // cause first and fourth quadrant is positive
        if (angle_degrees < 0) {
            angle_degrees = 180 + angle_degrees // make the angle to have 180 degree maximum
        }
        return angle_degrees
    }
}
