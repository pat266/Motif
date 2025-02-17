import CoreMotion

struct GyroData: Codable, Equatable, Hashable {
    
    var timestamp: Date
    var timeSinceBoot: TimeInterval
    var rotationRate: SIMD3<Double>
    
    init(fromData data: CMGyroData) {
        timestamp = data.date
        timeSinceBoot = data.timestamp
        rotationRate = [data.rotationRate.x, data.rotationRate.y, data.rotationRate.z]
    }
}
