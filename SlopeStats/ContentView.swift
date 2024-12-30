import SwiftUI
import CoreData
import WatchConnectivity
import UIKit
import CoreLocation

class PhoneSessionDelegate: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = PhoneSessionDelegate()
    @Published var lastReceivedData: SkiingDataEntity? // For broadcasting updates

    private override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Access the Core Data context from the PersistenceController directly
        let context = PersistenceController.shared.container.viewContext

        // Parse the message
        if let _duration = message["duration"] as? TimeInterval,
           let _timestamp = message["timestamp"] as? Date,
           let _altitude = message["altitude"] as? [Double],
           let _heartRate = message["heartRate"] as? [Int],
           let _speed = message["speed"] as? [Double],
           let _topSpeed = message["topSpeed"] as? Double {

            // Save the data into Core Data
            let skiingDataEntity = SkiingDataEntity(context: context)
            skiingDataEntity.duration = _duration

            // Create an instance of the ArrayToDataTransformer
            let transformer = ArrayToDataTransformer()

            // Use the transformedValue method on the instance
            skiingDataEntity.altitude = transformer.transformedValue(_altitude) as? NSData
            skiingDataEntity.speed = transformer.transformedValue(_speed) as? NSData
            skiingDataEntity.heartRate = transformer.transformedValue(_heartRate) as? NSData

            skiingDataEntity.topSpeed = _topSpeed
            skiingDataEntity.timestamp = Date()

            // Save the context
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.lastReceivedData = skiingDataEntity // Notify view
                }
            } catch {
                print("Failed to save skiing data: \(error)")
            }
        }

        DispatchQueue.main.async {
            if let _duration = message["duration"] as? TimeInterval,
               let _timestamp = message["timestamp"] as? Date,
               let _altitude = message["altitude"] as? [Double],
               let _heartRate = message["heartRate"] as? [Int],
               let _speed = message["speed"] as? [Double],
               let _topSpeed = message["topSpeed"] as? Double
            {
//                self.showAlert(duration: _duration, timestamp: _timestamp, altitude: _altitude, heartRate: _heartRate, speed: _speed, topSpeed: _topSpeed)
                let alert = UIAlertController(title: "Stopwatch Data Received✅", message: "Click OK to return to the menu", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))

                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = scene.windows.first,
                   let rootVC = window.rootViewController {
                    rootVC.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    func showAlert(duration: TimeInterval, timestamp: Date, altitude: [Double], heartRate: [Int], speed: [Double], topSpeed: Double) {
        let alert = UIAlertController(title: "Stopwatch Data Received", message: "duration: \(duration)\nTimestamp: \(timestamp)\nAltitude:\(altitude)\nHeart Rate:\(heartRate)\nSpeed:\(speed)\nTop Speed:\(topSpeed)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(alert, animated: true, completion: nil)
        }
    }

    // Required WCSessionDelegate methods
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    func sessionWatchStateDidChange(_ session: WCSession) {}

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}

struct ContentView: View {
    init() {
        _ = PhoneSessionDelegate.shared
    }

    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: SkiingDataEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SkiingDataEntity.timestamp, ascending: false)],
        animation: .default
    ) private var skiingDataEntities: FetchedResults<SkiingDataEntity>

    @State private var selectedTab: Tab = .navigation

    private enum Tab {
        case navigation, weather, resort
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Image("slopeStatsBanner")
                        .resizable()
                        .frame(width: 400, height: 50)
                        .padding(.trailing, 16)
                }
                .padding()
                .background(Color.gray.opacity(0.2))

                HStack {
                    Spacer()
                    Button(action: { selectedTab = .navigation }) {
                        VStack {
                            Image(systemName: "list.bullet")
                                .foregroundColor(selectedTab == .navigation ? .blue : .gray)
                            Text("Nav")
                                .font(.footnote)
                                .foregroundColor(selectedTab == .navigation ? .blue : .gray)
                        }
                    }
                    Spacer()
                    Button(action: { selectedTab = .weather }) {
                        VStack {
                            Image(systemName: "cloud.sun")
                                .foregroundColor(selectedTab == .weather ? .blue : .gray)
                            Text("Weather")
                                .font(.footnote)
                                .foregroundColor(selectedTab == .weather ? .blue : .gray)
                        }
                    }
                    Spacer()
                    Button(action: { selectedTab = .resort }) {
                        VStack {
                            Image(systemName: "mountain.2")
                                .foregroundColor(selectedTab == .resort ? .blue : .gray)
                            Text("Resort")
                                .font(.footnote)
                                .foregroundColor(selectedTab == .resort ? .blue : .gray)
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(Color.gray.opacity(0.2))

                Group {
                    switch selectedTab {
                    case .navigation:
                        List {
                            ForEach(skiingDataEntities) { skiingData in
                                SkiingDataRow(skiingData: skiingData)
                            }
                        }
                        .background(Color.black.edgesIgnoringSafeArea(.all))
                        .foregroundColor(.white)
                    case .weather:
                        WeatherView()
                    case .resort:
                        ResortView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct SkiingDataRow: View {
    var skiingData: SkiingDataEntity

    @State private var showDetails = false
    
    var formattedTimestamp: String {
        guard let timestamp = skiingData.timestamp else { return "No date available" }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium  // You can choose different styles or formats
        formatter.timeStyle = .short  // For a time format like "03:08 AM"
        
        return formatter.string(from: timestamp)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "figure.skiing.downhill")
                    .foregroundColor(.cyan)
                Text("Date: \(formattedTimestamp)")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                Button(action: {
                    showDetails.toggle()
                }) {
                    Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                        .foregroundColor(.black)
                        .rotationEffect(showDetails ? .degrees(180) : .degrees(0))
                }
            }
            Divider()
            if showDetails {
                VStack(alignment: .leading, spacing: 16) {
                    if let altitudeData = skiingData.altitude as? Data,
                       let altitudeArray = try? JSONSerialization.jsonObject(with: altitudeData, options: []) as? [Double] {
                        Chart(data: altitudeArray, title: "Altitude", color: Color.blue, icon: "mountain.2")
                    } else {
                        Text("Altitude: Not Available")
                            .foregroundColor(.black)
                    }

                    if let heartRateData = skiingData.heartRate as? Data {
                        let heartRateArray = try? JSONSerialization.jsonObject(with: heartRateData, options: []) as? [Int]
                        if let heartRateArray = heartRateArray {
                            Chart(data: heartRateArray.map { Double($0) }, title: "Heart Rate", color: .red, icon: "heart")
                        } else {
                            Text("Heart Rate: Not Available")
                                .foregroundColor(.black)
                        }
                    }

                    if let speedData = skiingData.speed as? Data {
                        let speedArray = try? JSONSerialization.jsonObject(with: speedData, options: []) as? [Double]
                        if let speedArray = speedArray {
                            Chart(data: speedArray, title: "Speed", color: .green, icon: "hare")
                        } else {
                            Text("Speed: Not Available")
                                .foregroundColor(.black)
                        }
                    }

                    Text("Run Duration: \(formatTime(Double(skiingData.duration ?? 0)))")
                        .foregroundColor(.black)

                    Text("Top Speed: \(skiingData.topSpeed ?? 0.0)")
                        .foregroundColor(.black)
                }
                .padding()
            }
        }
        .padding()
    }

    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    ContentView()
}
