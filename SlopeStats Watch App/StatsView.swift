import SwiftUI
import CoreMotion
import HealthKit
import WatchConnectivity

// ViewModel to handle WCSession and SkiingData logic
class StatsViewModel: NSObject, WCSessionDelegate, ObservableObject {
    @Published var skiingData: SkiingData = SkiingData()

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    // Required WCSessionDelegate methods:
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            print("WCSession activated")
        case .inactive:
            print("WCSession inactive")
        case .notActivated:
            print("WCSession not activated: \(String(describing: error))")
        @unknown default:
            print("Unknown WCSession activation state")
        }
    }

    // Called when an error occurs with WCSession
    func session(_ session: WCSession, didFailWithError error: Error) {
        print("WCSession failed with error: \(error)")
    }

    // Called when a message is received from the iPhone
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle the received message here
        print("Received message: \(message)")
    }
    
    // Method to send data to iPhone
    func transmitDataToPhone(skiingData: SkiingData, completion: @escaping () -> Void) {
        if WCSession.default.isReachable {
            let data: [String: Any] = [
                "duration": skiingData.duration,
                "altitude": skiingData.altitude,
                "heartRate": skiingData.heartRate,
                "speed": skiingData.speed,
                "topSpeed": skiingData.topSpeed,
                "timestamp": Date()
            ]
            print("Session reachable, sending data:")
            print(data)

            WCSession.default.sendMessage(data, replyHandler: { _ in
                completion()
            }, errorHandler: { _ in
                completion()
            })
        } else {
            print("Session not reachable")
            completion()
        }
    }
}


// StatsView to display skiing stats and manage the session
struct StatsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = StatsViewModel()

    @State private var skiingTime: TimeInterval = 0
    @State private var timer: Timer?
    
    @State private var altitude: Double = 0.0
    @State private var heartRate: Int = 0
    @State private var speed: Double = 0.0
    @State private var topSpeed: Double = 0.0

    @State private var isTransmitting: Bool = false
    
    private var healthStore = HKHealthStore()
    private let motionManager = CMMotionManager()
    private var altimeter = CMAltimeter()
    
    var body: some View {
        ScrollView {
            VStack {
                Text(formatTime(skiingTime))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .onAppear {
                        startSkiingSession()
                    }

                VStack(alignment: .leading, spacing: 0) {
                    StatRowView(iconName: "mountain.2", label: "Altitude", value: String(format: "%.1f", altitude), unit: "m", iconColor: .blue, fontColor: .blue)
                    StatRowView(iconName: "heart", label: "Heart Rate", value: "\(heartRate)", unit: "bpm", iconColor: .red, fontColor: .red)
                    StatRowView(iconName: "speedometer", label: "Speed", value: String(format: "%.1f", speed), unit: "km/h", iconColor: .yellow, fontColor: .yellow)
                    StatRowView(iconName: "hare", label: "Top Speed", value: String(format: "%.1f", topSpeed), unit: "km/h", iconColor: .white, fontColor: .white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.8))
                .cornerRadius(15)
                .padding(.horizontal)

                Spacer()

                Button(action: endSkiingSession) {
                    Text(isTransmitting ? "Sending Data..." : "End Run")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isTransmitting ? Color.gray : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .disabled(isTransmitting)
                .padding(.bottom)
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func startSkiingSession() {
        // Ensure WCSession is activated
        if WCSession.default.isReachable {
            print("WCSession is reachable")
        } else {
            print("WCSession is not reachable")
        }
        startTimer()
        startSensorUpdates()
    }

    private func endSkiingSession() {
        stopTimer()
        stopSensorUpdates()

        isTransmitting = true
        viewModel.transmitDataToPhone(skiingData: viewModel.skiingData) {
            isTransmitting = false
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            skiingTime += 1
            viewModel.skiingData.duration = skiingTime
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func startSensorUpdates() {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: .main) { data, error in
                if let altitudeData = data {
                    let currentAltitude = altitudeData.relativeAltitude.doubleValue
                    self.altitude = currentAltitude
                    viewModel.skiingData.altitude.append(currentAltitude)
                }
            }
        }

        if motionManager.isAccelerometerAvailable {
            motionManager.startAccelerometerUpdates(to: .main) { data, error in
                if let speedData = data {
                    let simulatedSpeed = sqrt(pow(speedData.acceleration.x, 2) +
                                              pow(speedData.acceleration.y, 2) +
                                              pow(speedData.acceleration.z, 2)) * 10
                    self.speed = simulatedSpeed
                    viewModel.skiingData.speed.append(simulatedSpeed)
                    self.topSpeed = max(self.topSpeed, simulatedSpeed)
                    viewModel.skiingData.topSpeed = self.topSpeed
                }
            }
        }

        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { _, samples, _, _, _ in
            if let samples = samples as? [HKQuantitySample] {
                if let latestHeartRate = samples.last?.quantity.doubleValue(for: .count().unitDivided(by: .minute())) {
                    let currentHeartRate = Int(latestHeartRate)
                    self.heartRate = currentHeartRate
                    viewModel.skiingData.heartRate.append(currentHeartRate)
                }
            }
        }
        healthStore.execute(query)
    }

    private func stopSensorUpdates() {
        altimeter.stopRelativeAltitudeUpdates()
        motionManager.stopAccelerometerUpdates()
    }
}

// SkiingData model to hold skiing statistics
struct SkiingData {
    var duration: TimeInterval = 0
    var altitude: [Double] = []
    var heartRate: [Int] = []
    var speed: [Double] = []
    var topSpeed: Double = 0.0
}

// Reusable stat row view with customizable colors
struct StatRowView: View {
    let iconName: String
    let label: String
    let value: String
    let unit: String
    let iconColor: Color
    let fontColor: Color

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(iconColor)
            Text(label)
                .font(.headline)
                .foregroundColor(fontColor)
            Spacer()
            Text("\(value) \(unit)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    StatsView()
}
