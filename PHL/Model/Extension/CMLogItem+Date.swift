import CoreMotion
import QuartzCore

extension CMLogItem {
    var date: Date {
        Date(timeIntervalSinceBoot: timestamp)
    }
}

extension Date {
    init(timeIntervalSinceBoot: TimeInterval) {
        let timeIntervalSinceBootUntilNow = CACurrentMediaTime() as TimeInterval
        let difference = timeIntervalSinceBoot - timeIntervalSinceBootUntilNow
        self.init(timeIntervalSinceNow: difference)
    }
}
