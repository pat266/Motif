//
//  MotionDataEntry.swift
//  Motif
//
//  Created by Pan Weiheng on 2020/4/1.
//

import CoreMotion

struct MotionDataEntry: Codable, Equatable, Hashable, Identifiable {
    
    var id = UUID()
    var accelerometerData: AccelerometerData! = nil
    var gyroData:          GyroData!          = nil

    static let keyPathsAndTitles: [(PartialKeyPath<MotionDataEntry>, String)] = [
        
        /* Accelerometer */
        
        (\MotionDataEntry.accelerometerData?.timestamp,                             "accelerometerTimestamp"),
        (\MotionDataEntry.accelerometerData?.timeSinceBoot,                         "accelerometerTimeSinceBoot"),
        
        (\MotionDataEntry.accelerometerData?.acceleration.x,                        "rawAccelerationX"),
        (\MotionDataEntry.accelerometerData?.acceleration.y,                        "rawAccelerationY"),
        (\MotionDataEntry.accelerometerData?.acceleration.z,                        "rawAccelerationZ"),
        
        /* Gyroscope */
        
        (\MotionDataEntry.gyroData?.timestamp,                                      "gyroscopeTimestamp"),
        (\MotionDataEntry.gyroData?.timeSinceBoot,                                  "gyroscopeTimeSinceBoot"),
        
        (\MotionDataEntry.gyroData?.rotationRate.x,                                 "rawRotationRateX"),
        (\MotionDataEntry.gyroData?.rotationRate.y,                                 "rawRotationRateY"),
        (\MotionDataEntry.gyroData?.rotationRate.z,                                 "rawRotationRateZ"),
        
    ]
    
    init(accelerometerData: CMAccelerometerData, gyroData: CMGyroData) {
        
        self.accelerometerData = AccelerometerData(fromData: accelerometerData)
        self.gyroData = GyroData(fromData: gyroData)
        
    }
    
    init() {}
    
}
