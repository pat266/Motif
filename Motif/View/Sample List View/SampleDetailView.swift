//
//  SampleDetailView.swift
//  Motif
//
//  Created by Pan Weiheng on 2020/4/9.
//

import SwiftUI

struct SampleDetailView: View {
    var sample: MotionDataSample
    
    @State var isShowingShareActionSheet = false
    @State var isShowingShareActivitySheet = false
    @State var shareActivitySheetFileFormat: ShareSampleActivityView.FileFormat = .csv
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        return formatter
    }()
    let dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    var dateString: String { dateFormatter.string(from: sample.firstTimestamp!) }
    
    var body: some View {
        List {
            
            Section(header: Text("Metadata").font(.subheadline).bold()) {
                ItemRow(name: "Start time",
                        value: self.dateString)
                ItemRow(name: "Duration",
                        value: dateComponentsFormatter.string(from: sample.duration!)!)
                ItemRow(name: "Sampling rate",
                        value: "\(Int(sample.samplingRate)) Hz")
                ItemRow(name: "No. of entries",
                        value: "\(sample.entries.count)")
            }
            
            Section(header: Text("Raw Acceleration").font(.subheadline).bold()) {
                
                HStack {
                    Text("x").font(.headline)
                    LineChart(
                        data: sample.entries.map { ($0.accelerometerData.timeSinceBoot, $0.accelerometerData.acceleration.x) })
                        .frame(height: 100)
                }.padding()
                HStack {
                    Text("y").font(.headline)
                    LineChart(
                        data: sample.entries.map { ($0.accelerometerData.timeSinceBoot, $0.accelerometerData.acceleration.y) })
                        .frame(height: 100)
                }.padding()
                HStack {
                    Text("z").font(.headline)
                    LineChart(
                        data: sample.entries.map { ($0.accelerometerData.timeSinceBoot, $0.accelerometerData.acceleration.z) })
                        .frame(height: 100)
                }.padding()
                
            }
            
            Section(header: Text("Raw Gyroscope").font(.subheadline).bold()) {
                
                HStack {
                    Text("x").font(.headline)
                    LineChart(
                        data: sample.entries.map { ($0.gyroData.timeSinceBoot, $0.gyroData.rotationRate.x) })
                        .frame(height: 100)
                }.padding()
                HStack {
                    Text("y").font(.headline)
                    LineChart(
                        data: sample.entries.map { ($0.gyroData.timeSinceBoot, $0.gyroData.rotationRate.y) })
                        .frame(height: 100)
                }.padding()
                HStack {
                    Text("z").font(.headline)
                    LineChart(
                        data: sample.entries.map { ($0.gyroData.timeSinceBoot, $0.gyroData.rotationRate.z) })
                        .frame(height: 100)
                }.padding()
                
            }
            
            
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(Text(self.dateString), displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action: {
                self.isShowingShareActionSheet.toggle()
            }) {
                Image(systemName: "square.and.arrow.up")
                .actionSheet(isPresented: $isShowingShareActionSheet, content: { self.shareActionSheet })
        })
        .sheet(isPresented: $isShowingShareActivitySheet, content: {
            ShareSampleActivityView(fileFormat: self.shareActivitySheetFileFormat, samples: [self.sample])
        })
    }
    
    private var shareActionSheet: ActionSheet {
        ActionSheet(title: Text("Share sample as..."), message: nil, buttons: [
            .default(Text("CSV")) {
                self.isShowingShareActivitySheet.toggle()
                self.shareActivitySheetFileFormat = .csv
            },
            .default(Text("JSON")) {
                self.isShowingShareActivitySheet.toggle()
                self.shareActivitySheetFileFormat = .json
            },
            .cancel()
        ])
    }

}

struct SampleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SampleDetailView(sample: MotionDataSample.previewSamples[2])
            SampleDetailView(sample: MotionDataSample.previewSamples[2])
                .colorScheme(.dark)
        }
    }
}
