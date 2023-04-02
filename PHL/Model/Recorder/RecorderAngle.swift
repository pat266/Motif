import Foundation
import Combine
import CoreMotion // for accelerator and gyroscope
import AudioToolbox.AudioServices


class RecorderAngle: ObservableObject {
    
    internal struct RecordSetting {
        var samplingRate: Double = 100
        var maxData: Int = 200
    }
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let manager = CMMotionManager()
    
    private var timerUpdate: AnyCancellable? = nil // timer to update data
    
    var samplingInterval: Double { 1.0 / setting.samplingRate }
    
    @Published var setting: RecorderAngle.RecordSetting = RecordSetting()
    @Published var isRecording: Bool = false {
        willSet {
            newValue ? startRecording() : stopRecording()
        }
    }
    @Published var currentDataEntry = MotionDataEntry()
    private(set) var currentDataRecord: MotionDataSample?
    @Published var samples = [MotionDataSample]()
//    {
//        didSet {
//            saveSampleListToDisk()
//        }
//    }
    
    @Published var angle_degree: Double = 0
    
    private let sampleListFileName: String = "sampleList.json"
    private var sampleListFileURL: URL {
        FileManager.default.documentDirectoryURL(appending: sampleListFileName)
    }
    
    // MARK: - Initializer
    
    init() {
        loadSampleListFromDisk()
    }
    
    // MARK: - De-Initializer
    deinit {
        
    }

    // MARK: - Methods
    
    internal func startRecording() {
        guard manager.isDeviceAvailable == true else { return }
        
        // Set sampling intervals
        manager.accelerometerUpdateInterval = samplingInterval
        manager.gyroUpdateInterval          = samplingInterval
        
        // Start data updates
        manager.startAccelerometerUpdates()
        manager.startGyroUpdates()
        
        // Initialize data storage
//        currentDataRecord = MotionDataSample(startTime: Date(), samplingRate: setting.samplingRate)
        
        // Activate timer
        timerUpdate = Timer.publish(every: samplingInterval, on: .main, in: .common)
            .autoconnect()
            .sink { date in
                guard let accelerometerData = self.manager.accelerometerData,
                    let gyroData = self.manager.gyroData
                    else { return }
                
//                // Save motion data to entry and record
//                self.currentDataEntry = MotionDataEntry(
//                    accelerometerData: accelerometerData,
//                    gyroData: gyroData
//                )
//                self.currentDataRecord?.addEntry(self.currentDataEntry)
                
                self.updateData(accelerometerData:accelerometerData, gyroData:gyroData)

        }
        
    }
    
    internal func stopRecording() {
        
        guard manager.isDeviceAvailable == true else { return }
        
        // Invalidate timer
        timerUpdate?.cancel()
        
        // Stop data updates
        manager.stopAccelerometerUpdates()
        manager.stopGyroUpdates()
        
//        // Add new record to record list
//        guard let record = currentDataRecord else { return }
//        samples.append(record)
        
        #if DEBUG
//        print("Appended sample to samples. Samples count: \(samples.count)")
        
        #endif
        
        // Clear motion data
        currentDataEntry = MotionDataEntry()
        currentDataRecord = nil
    }
    
    private func updateData(accelerometerData: CMAccelerometerData, gyroData: CMGyroData) -> Void {
        angle_degree = Angle.calculatePhoneAngle(x_accelerometer: accelerometerData.acceleration.x,
                                                 y_accelerometer: accelerometerData.acceleration.y,
                                                 z_accelerometer: accelerometerData.acceleration.z)
    }

    private func saveSampleListToDisk() {
        
        // Encode samples to JSON data
        var data: Data
        do {
            data = try encoder.encode(samples)
        } catch {
            print("Failed to encode recordList.")
            return
        }
        
        // Write data to disk
        do {
            try data.write(to: sampleListFileURL)
        } catch {
            print("Failed to write recordList data to URL.")
        }
        
        #if DEBUG
        print("Sample list saved to disk with \(samples.count) samples")
        #endif

    }
    
    private func loadSampleListFromDisk() {
        
        // Read data from disk
        var data: Data
        do {
            data = try Data(contentsOf: sampleListFileURL)
        } catch {
            #if DEBUG
            print("Failed to read recordList data from disk.")
            #endif
            return
        }
        
        // Decode JSON data
        var list: [MotionDataSample]
        do {
            list = try decoder.decode([MotionDataSample].self, from: data)
        } catch {
            print("Failed to decode recordList data.")
            return
        }
        
        // Restore list
        samples = list
    }
}

private extension CMMotionManager {
    
    var isDeviceAvailable: Bool {
        return isAccelerometerAvailable
            && isGyroAvailable
    }
}