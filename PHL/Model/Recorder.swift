//
//  Recorder.swift
//  Motif
//
//

import Foundation
import Combine
import CoreMotion // for accelerator and gyroscope
import CoreHaptics // for vibration
import AudioToolbox.AudioServices


class Recorder: ObservableObject {
    
    struct RecordSetting {
        var samplingRate: Double = 100
        var maxData: Int = 200
    }
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let manager = CMMotionManager()
    private var engine: CHHapticEngine?
    private let haveStarted = false // boolean for vibration check
    private var timerSubscription: AnyCancellable? = nil
    var samplingInterval: Double { 1.0 / setting.samplingRate }
    
    @Published var setting = RecordSetting()
    @Published var isRecording = false {
        willSet {
            newValue ? startRecording() : stopRecording()
        }
    }
    @Published var currentDataEntry = MotionDataEntry()
    private(set) var currentDataRecord: MotionDataSample?
    @Published var samples = [MotionDataSample]() {
        didSet {
            saveSampleListToDisk()
        }
    }
    
    @Published var accelerometerDataX: [Double] = []
    @Published var accelerometerDataY: [Double] = []
    @Published var accelerometerDataZ: [Double] = []
    
    @Published var gyroscopeDataX: [Double] = []
    @Published var gyroscopeDataY: [Double] = []
    @Published var gyroscopeDataZ: [Double] = []
    
    private let sampleListFileName = "sampleList.json"
    private var sampleListFileURL: URL {
        FileManager.default.documentDirectoryURL(appending: sampleListFileName)
    }
    
    // MARK: - Initializer
    
    init() {
        loadSampleListFromDisk()
        self.initHaptic()
    }
    
    // MARK: - De-Initializer
    deinit {
        self.destroyHaptics()
    }

    // MARK: - Methods
    
    private func startRecording() {
        guard manager.isDeviceAvailable == true else { return }
        
        // Vibrate the device
        self.startHaptics()
        // How strong the haptic is (0 - 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        // supposed to be infinite, but I think the max is 10 seconds
        let hapticCustom = CHHapticEvent(eventType: .hapticContinuous, parameters: [ sharpness], relativeTime: 0, duration: .infinity)
        self.playHaptic(event: hapticCustom)
        
        // Set sampling intervals
        manager.accelerometerUpdateInterval = samplingInterval
        manager.gyroUpdateInterval          = samplingInterval
        
        // Start data updates
        manager.startAccelerometerUpdates()
        manager.startGyroUpdates()
        
        // Initialize data storage
        currentDataRecord = MotionDataSample(startTime: Date(), samplingRate: setting.samplingRate)
        
        // Activate timer
        timerSubscription = Timer.publish(every: samplingInterval, on: .main, in: .common)
            .autoconnect()
            .sink { date in
                guard let accelerometerData = self.manager.accelerometerData,
                    let gyroData = self.manager.gyroData
                    else { return }
                
                // Save motion data to entry and record
                self.currentDataEntry = MotionDataEntry(
                    accelerometerData: accelerometerData,
                    gyroData: gyroData
                )
                self.currentDataRecord?.addEntry(self.currentDataEntry)
                
                self.updateData(accelerometerData:accelerometerData, gyroData:gyroData)
                
                
        }
        
    }
    
    private func stopRecording() {
        
        guard manager.isDeviceAvailable == true else { return }
        
        // Invalidate timer
        timerSubscription?.cancel()
        
        // Stop data updates
        manager.stopAccelerometerUpdates()
        manager.stopGyroUpdates()
        
        // cancel the vibratino
        self.stopHaptics()
        
        // Add new record to record list
        guard let record = currentDataRecord else { return }
        samples.append(record)
        
        #if DEBUG
        print("Appended sample to samples. Samples count: \(samples.count)")
        
        #endif
        
        // Clear motion data
        currentDataEntry = MotionDataEntry()
        currentDataRecord = nil
    }
    
    private func updateData(accelerometerData: CMAccelerometerData, gyroData: CMGyroData) -> Void {
        // add accelerometer data to the array
        self.accelerometerDataX.append(accelerometerData.acceleration.x)
        self.accelerometerDataY.append(accelerometerData.acceleration.y)
        self.accelerometerDataZ.append(accelerometerData.acceleration.z)
        
        // add gyroscope data to the array
        self.gyroscopeDataX.append(gyroData.rotationRate.x)
        self.gyroscopeDataY.append(gyroData.rotationRate.y)
        self.gyroscopeDataZ.append(gyroData.rotationRate.z)
        
        // remove first element to limit the size of array
        if (self.accelerometerDataX.count > self.setting.maxData || self.accelerometerDataY.count > self.setting.maxData || self.accelerometerDataZ.count > self.setting.maxData) {
            self.accelerometerDataX.removeFirst()
            self.accelerometerDataY.removeFirst()
            self.accelerometerDataZ.removeFirst()
        }
        if (self.gyroscopeDataX.count > self.setting.maxData || self.gyroscopeDataY.count > self.setting.maxData || self.gyroscopeDataZ.count > self.setting.maxData) {
            self.gyroscopeDataX.removeFirst()
            self.gyroscopeDataY.removeFirst()
            self.gyroscopeDataZ.removeFirst()
        }
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
    
    public func clearAccelerometerArray() {
        if (!self.accelerometerDataX.isEmpty) {
            self.accelerometerDataX.removeAll()
        }
        if (!accelerometerDataY.isEmpty) {
            self.accelerometerDataY.removeAll()
        }
        if (!accelerometerDataZ.isEmpty) {
            self.accelerometerDataZ.removeAll()
        }
    }
    
    public func clearGyroscopeArray() {
        if (!self.gyroscopeDataX.isEmpty) {
            self.gyroscopeDataX.removeAll()
        }
        if (!gyroscopeDataY.isEmpty) {
            self.gyroscopeDataY.removeAll()
        }
        if (!gyroscopeDataZ.isEmpty) {
            self.gyroscopeDataZ.removeAll()
        }
    }
    
    // MARK: - Vibration Methods
    func initHaptic() {
        // check device support
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    func startHaptics() {
        do {
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    func stopHaptics() {
        engine?.stop()
    }

    func destroyHaptics() {
        // The engine stopped; print out why
        engine?.stoppedHandler = { reason in
            print("The engine stopped: \(reason)")
        }

        // If something goes wrong, attempt to restart the engine immediately
        engine?.resetHandler = { [weak self] in
            print("The engine reset")

            do {
                try self?.engine?.start()
            } catch {
                print("Failed to restart the engine: \(error)")
            }
        }
    }
    
    func playHaptic(event: CHHapticEvent) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    
}

extension CMMotionManager {
    
    var isDeviceAvailable: Bool {
        return isAccelerometerAvailable
            && isGyroAvailable
    }
}
