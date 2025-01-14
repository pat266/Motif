import CoreMotion

struct AccelerometerData: Codable, Equatable, Hashable {

    var timestamp: Date
    var timeSinceBoot: TimeInterval
    var acceleration: SIMD3<Double>
    
    init(fromData data: CMAccelerometerData) {
        timestamp = data.date
        timeSinceBoot = data.timestamp
        acceleration = [data.acceleration.x, data.acceleration.y, data.acceleration.z]
    }
}
