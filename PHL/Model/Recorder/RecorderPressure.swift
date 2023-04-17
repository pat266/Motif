import Foundation
import Combine
import CoreMotion // for accelerator and gyroscope
import CoreHaptics // for vibration
import AudioToolbox.AudioServices


class RecorderPressure: ObservableObject {
    
    internal struct RecordSetting {
        var samplingRate: Double = 200
        var maxData: Int = 200
    }
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let manager = CMMotionManager()
    private let vibrator = Vibrator()
    
    private let haveStarted: Bool = false // boolean for vibration check
    private var timerUpdate: AnyCancellable? = nil // timer to update data
    private var timerCountDown: AnyCancellable? = nil // timer to count down before calibrate
    private var timerVibrate: AnyCancellable? = nil // timer to calibrate
    
    var samplingInterval: Double { 1.0 / setting.samplingRate }
    
    @Published var setting: RecorderPressure.RecordSetting = RecordSetting()
    @Published var isCalibrating: Bool = false {
        willSet {
            newValue ? startCalibrating() : stopCalibrating()
        }
    }
    
    @Published var accelerometerVectorData: [Double] = []
    @Published var gyroscopeDataY: [Double] = []
    
    @Published var intensityStr: String = ""
    
    
    private let sampleListFileName: String = "sampleList.json"
    private var sampleListFileURL: URL {
        FileManager.default.documentDirectoryURL(appending: sampleListFileName)
    }
    
    // actual values (intensity, weight) - hard coded
    
    private let iphoneSE_data: [(x: Double, y: Double)] =
        [
            (0.00105870573629251, 0),
            (0.000848538797201339, 102),
            (0.000426434131039099, 240),
            (0.000526392537816919, 379),
            (0.000487689069711278, 658),
            (0.000474837641938552, 818)
        ]
    
    private let iphone13_data: [(x: Double, y: Double)] =
        [
            (0.00111204040732095, 0),
            (0.00064452523043304, 102),
            (0.000645269724364158, 240),
            (0.000601944611116786, 379),
            (0.000737111879930166, 658),
            (0.000588855628250445, 818)
        ]
    
    private let model: LinearRegression = LinearRegression()
    
    // MARK: - Initializer
    
    init() {
        // loadSampleListFromDisk()
        
        // fit the hard-coded data
        self.model.fit(data: self.iphoneSE_data)
        print("Intercept: " + String(self.model.intercept))
        print("Slope: " + String(self.model.slope))
    }
    
    // MARK: - De-Initializer
    deinit {
        
    }

    // MARK: - Methods
    
    internal func startCalibrating() {
        guard manager.isDeviceAvailable == true else { return }
        
        self.intensityStr = "Starting in 3"
        
        // start vibrating
        vibrator.vibrateInSeconds(duration: 30)
        
        // Set sampling intervals
        manager.accelerometerUpdateInterval = samplingInterval
        manager.gyroUpdateInterval          = samplingInterval
        
        // Start data updates
        manager.startAccelerometerUpdates()
        manager.startGyroUpdates()
         
        self.startCountingDownTimer()
        
    }
    
    private func startCountingDownTimer() {
        // activate timer for counting down
        var elapsedSeconds = 0
        timerCountDown = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { date in
                elapsedSeconds += 1
                if elapsedSeconds > 3 {
                    self.intensityStr = ""
                    self.startMeasuringTimer()
                    self.timerCountDown?.cancel()
                } else {
                    self.intensityStr = "Starting in " + String(3 - elapsedSeconds)
                }
            
        }
    }
    
    private func startMeasuringTimer() {
        // Activate timer
        timerUpdate = Timer.publish(every: samplingInterval, on: .main, in: .common)
            .autoconnect()
            .sink { date in
                guard let accelerometerData = self.manager.accelerometerData,
                    let gyroData = self.manager.gyroData
                    else { return }
                
                self.updateData(accelerometerData:accelerometerData, gyroData:gyroData)

        }
        
        // activate timer for calibration
        var elapsedSeconds = 0
        timerVibrate = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { date in
                elapsedSeconds += 1
                if elapsedSeconds > 5 {
                     let intensity = String(self.getIntensity())
                    print("Intensity: " + intensity)
                    // self.intensityStr = "Intensity: " + intensity
                    let weight = self.model.predict(self.getIntensity())
                    self.intensityStr = "Predicted weight: " + String(weight)
                    self.isCalibrating = false
                    self.timerVibrate?.cancel()
                } else {
                    self.intensityStr = "Remaining time: " + String(5 - elapsedSeconds)
                }
            
        }
    }
    
    
    
    internal func stopCalibrating() {
        
        guard manager.isDeviceAvailable == true else { return }
        
        // Invalidate timer
        self.timerUpdate?.cancel()
        self.timerVibrate?.cancel()
        self.timerCountDown?.cancel()
        
        // Stop data updates
        manager.stopAccelerometerUpdates()
        manager.stopGyroUpdates()
        
        self.clearAccelerometerArray()
        self.clearGyroscopeArray()
        
        // cancel the vibration
        vibrator.stopHaptics()
    }
    
    private func updateData(accelerometerData: CMAccelerometerData, gyroData: CMGyroData) -> Void {
        // add accelerometer data to the array
        let currAccelerometerData = sqrt(pow(accelerometerData.acceleration.x, 2) + pow(accelerometerData.acceleration.y, 2) +
             pow(accelerometerData.acceleration.z, 2))
        self.accelerometerVectorData.append(currAccelerometerData)
        
        // add gyroscope data to the array
        // self.gyroscopeDataY.append(gyroData.rotationRate.y)
        
    }
    
    private func getIntensity() -> Double {
        let smoothedAccelerometer = Pressure.calculateSmoothedAverage(values: self.accelerometerVectorData, windowSize: 2)
        return Pressure.calculateIntensity(accelerometer: self.accelerometerVectorData)
    }
    
    // MARK: - Clear the data
    
    public func clearAccelerometerArray() {
        if (!accelerometerVectorData.isEmpty) {
            self.accelerometerVectorData.removeAll()
        }
    }
    
    public func clearGyroscopeArray() {
        if (!gyroscopeDataY.isEmpty) {
            self.gyroscopeDataY.removeAll()
        }
    }
    
    // MARK: - Get DataPoint
    func getDatapoint(sensorData: [Double]) -> Double {
        var squaredDifferences: [Double]
        squaredDifferences = Pressure.calculateSmoothedAverage(values: sensorData, windowSize: 2)
        for i in 0..<squaredDifferences.count {
            squaredDifferences[i] = squaredDifferences[i] - sensorData[i]
            squaredDifferences[i] = squaredDifferences[i] * squaredDifferences[i]
        }
        
        let average = squaredDifferences.reduce(0, +) / Double(squaredDifferences.count)
        let standardDeviation = sqrt(average)
        return standardDeviation
    }
}

private extension CMMotionManager {
    
    var isDeviceAvailable: Bool {
        return isAccelerometerAvailable
            && isGyroAvailable
    }
}
