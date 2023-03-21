//
//  MotionDataSample.swift
//
//  Created by Pan Weiheng on 2020/4/2.
//

import UIKit
import CoreMotion

/// A struct representing the sampled data of a single record session.
struct MotionDataSample: Codable, Equatable, Hashable, Identifiable {
    
    // MARK: - Metadata
    var startTime: Date
    var samplingRate: Double
    var deviceModel: String = UIDevice.model
    
    // MARK: - Data
    var id = UUID()
    private(set) var entries: [MotionDataEntry] = []
    
    // MARK: - Static Properties
    static let keyPathsAndTitles: [(PartialKeyPath<MotionDataSample>, String)] = [
        (\MotionDataSample.samplingRate,    "samplingRate"),
        (\MotionDataSample.deviceModel,     "deviceModel")
    ]
    static let metadataKeyPaths: [PartialKeyPath<MotionDataSample>] = Self.keyPathsAndTitles.map { $0.0 }
    static let metadataTitles: [String] = Self.keyPathsAndTitles.map { $0.1 }
    static let dataKeyPaths = MotionDataEntry.keyPathsAndTitles.map { $0.0 }
    static let dataTitles = MotionDataEntry.keyPathsAndTitles.map { $0.1 }
    
    // MARK: - Computed Properties
    var accelerometerDataFirstTimestamp: Date? { entries.first?.accelerometerData?.timestamp }
    var gyroDataFirstTimestamp:          Date? { entries.first?.gyroData?.timestamp }
    var firstTimestamp: Date? {
        let timestamps = [accelerometerDataFirstTimestamp, gyroDataFirstTimestamp]
        return timestamps.compactMap { $0 }.min()
    }
    
    var accelerometerDataLastTimestamp:  Date? { entries.last?.accelerometerData?.timestamp }
    var gyroDataLastTimestamp:           Date? { entries.last?.gyroData?.timestamp }
    var lastTimestamp: Date? {
        let timestamps = [accelerometerDataLastTimestamp, gyroDataLastTimestamp]
        return timestamps.compactMap { $0 }.max()
    }
    
    var duration: TimeInterval? {
        guard let start = firstTimestamp, let end = lastTimestamp else { return nil }
        let dateDifference = DateInterval(start: start, end: end)
        return dateDifference.duration
    }

    // MARK: - Methods
    mutating func addEntry(_ entry: MotionDataEntry) {
        entries.append(entry)
    }
    
    func encodeToCSV() -> String {
        let delimiter: String = ","
        let titles = ["No"] + Self.metadataTitles + Self.dataTitles
        let container = CSVContainer(titles: titles, delimiter: delimiter)
        
        for (index, data) in entries.enumerated() {
            var row: [String] = [String]()
            
            row.append(String(index + 1))
            for keyPath: PartialKeyPath<MotionDataSample> in Self.metadataKeyPaths {
                row.append(stringFlatten(self[keyPath: keyPath]))
            }
            for keyPath in Self.dataKeyPaths {
                row.append(stringFlatten(data[keyPath: keyPath]))
            }
            
            try! container.addRow(row)
        }
        
        return container.text
    }
    
    private func stringFlatten(_ input: Any) -> String {
        var string: String = String(describing: input)
        
        // Remove "Optional()"
        let prefix: String = "Optional(", suffix: String = ")"
        if string.hasPrefix(prefix) && string.hasSuffix(suffix) {
            string.removeFirst(prefix.count)
            string.removeLast(suffix.count)
        }
        
        // Add quotes if string contains comma
        if string.contains(",") {
            string = "\"" + string + "\""
        }
        
        return string
    }
    
}
