import SwiftUI
import CoreData
import WatchConnectivity
import UIKit

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
                self.showAlert(duration: _duration, timestamp: _timestamp, altitude: _altitude, heartRate: _heartRate, speed: _speed, topSpeed: _topSpeed)
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

//    @StateObject private var wcSessionDelegate = WCSessionDelegateImpl()
    @State private var selectedTab: Tab = .navigation

    private enum Tab {
        case navigation, weather, resort
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Title/Nav bar
                HStack {
                    Image("slopeStatsBanner")
                        .resizable()
                        .frame(width: 400, height: 50)
                        .padding(.trailing, 16)
                }
                .padding()
                .background(Color.gray.opacity(0.2))

                // Tab bar
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
                            Image(systemName: "mountain")
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

                // Content area
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

    var body: some View {
        VStack(alignment: .leading) {
            Text("Date: \(skiingData.timestamp)")
                .font(.headline)
                .foregroundColor(.black)
            Divider()
            Button(action: {
                showDetails.toggle()
            }) {
                Text("Show Details")
                    .foregroundColor(.black)
                Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                    .rotationEffect(showDetails ? .degrees(180) : .degrees(0))
            }
            if showDetails {
                VStack(alignment: .leading) {
                    if let altitudeData = skiingData.altitude as? Data {
                        let altitudeArray = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(altitudeData) as? [Double]
                        Text("Altitude: \(altitudeArray?.description ?? "Not Available")")
                            .foregroundColor(.black)
                        // Graph for altitude using SwiftUI
                        // ... (replace with SwiftUI code to graph altitude data)
                    } else {
                        Text("Altitude: Not Available")
                            .foregroundColor(.black)
                    }

                    Text("Duration: \(formatTime(Double(skiingData.duration ?? 0)))")
                        .foregroundColor(.black)
                    // Graph for duration using SwiftUI
                    // ... (replace with SwiftUI code to graph duration data)

                    if let heartRateData = skiingData.heartRate as? Data {
                        let heartRateArray = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(heartRateData) as? [Int]
                        Text("Heart Rate: \(heartRateArray?.description ?? "Not Available")")
                            .foregroundColor(.black)
                        // Graph for heartRate using SwiftUI
                        // ... (replace with SwiftUI code to graph heartRate data)
                    } else {
                        Text("Heart Rate: Not Available")
                    }

                    if let speedData = skiingData.speed as? Data {
                        let speedArray = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(speedData) as? [Double]
                        Text("Speed: \(speedArray?.description ?? "Not Available")")
                            .foregroundColor(.black)
                        // Graph for speed using SwiftUI
                        // ... (replace with SwiftUI code to graph speed data)
                    } else {
                        Text("Speed: Not Available")
                            .foregroundColor(.black)
                    }

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

struct WeatherView: View {
    var body: some View {
        Text("Weather View")
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.blue.opacity(0.1))
    }
}

struct ResortView: View {
    var body: some View {
        Text("Resort View")
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.green.opacity(0.1))
    }
}

#Preview {
    ContentView()
}
