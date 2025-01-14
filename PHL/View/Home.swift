import SwiftUI

struct Home: View {
    
    @EnvironmentObject var recorder: Recorder
    
    var body: some View {
        TabView {
            CalibrateView().tabItem {
                Image(systemName: "iphone.gen1.radiowaves.left.and.right")
                Text("Calibrate")
            }
            
            PressureView().tabItem {
                Image(systemName: "scalemass")
                Text("Weigh")
            }
            
            AngleView().tabItem {
                Image(systemName: "angle")
                Text("Angle")
            }
            
            RecorderView().tabItem {
                Image(systemName: "waveform")
                Text("Record")
            }
            
            SampleListView().tabItem {
                Image(systemName: "list.bullet")
                Text("Samples")
            }
            
            Text("First View")
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "iphone.gen1.radiowaves.left.and.right")
                        Text("second")
                    }
                }
            
            Text("Second View")
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "iphone.gen1.radiowaves.left.and.right")
                        Text("second")
                    }
                }
            
            Text("Third View")
                .font(.title)
                .tabItem {
                    VStack {
                        Image(systemName: "iphone.gen1.radiowaves.left.and.right")
                        Text("third")
                    }
                }
            
        }.accentColor(recorder.isRecording ? .red : .blue)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home().environmentObject(Recorder())
    }
}
