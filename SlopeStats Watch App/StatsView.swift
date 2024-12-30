import SwiftUI
import CoreMotion
import HealthKit
import WatchConnectivity

// ViewModel to handle WCSession and SkiingData logic
class StatsViewModel: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = StatsViewModel()

    var skiingData: SkiingData = SkiingData()

    private override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
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
    
    let altitudeExample = [
        3400.5, 3380.3, 3365.7, 3365.7, 3365.7, 3365.7, 3365.7, 3365.7, 3365.7, 3270.5,
        3250.2, 3235.3, 3220.8, 3205.5, 3190.4, 3180.3, 3170.9, 3160.7, 3150.2, 3140.6,
        3130.5, 3120.3, 3110.4, 3105.2, 3095.1, 3085.0, 3075.7, 3065.8, 3055.2, 3050.4,
        3040.1, 3030.6, 3020.8, 3020.8, 3020.8, 3020.8, 3020.8, 3020.8, 2965.4, 2965.4,
        2965.4, 2965.4, 2965.4, 2915.4, 2915.4, 2915.4, 2885.6, 2875.2, 2865.5, 2855.4,
        2845.2, 2835.1, 2825.3, 2815.2, 2805.5, 2795.1, 2785.3, 2775.4, 2765.3, 2755.2,
        2745.5, 2735.6, 2725.4, 2715.5, 2705.3, 2695.7, 2685.6, 2675.4, 2665.3, 2655.2,
        2645.4, 2635.6, 2625.3, 2615.4, 2605.2, 2595.3, 2585.2, 2575.1, 2565.2, 2555.3,
        2545.4, 2535.2, 2525.4, 2515.1, 2505.3, 2505.3, 2505.3, 2505.3, 2505.3, 2505.3,
        2505.3, 2505.3, 2505.3, 2415.1, 2405.0
    ];

    let heartRateExample = [
        87, 89, 92, 90, 93, 91, 88, 90, 94, 91,
        89, 88, 92, 90, 87, 86, 90, 92, 91, 90,
        93, 89, 88, 90, 92, 93, 94, 95, 93, 91,
        89, 88, 87, 90, 92, 91, 90, 89, 88, 87,
        89, 91, 92, 90, 88, 90, 89, 91, 94, 93,
        92, 91, 89, 88, 90, 91, 92, 90, 89, 88,
        87, 90, 92, 91, 90, 92, 93, 91, 90, 89,
        88, 90, 91, 92, 90, 89, 88, 87, 90, 91,
        92, 90, 88, 89, 90, 91, 92, 93, 91, 90
    ];

    let speedExample = [
        12.5, 13.3, 14.2, 15.1, 16.8, 17.9, 19.1, 20.2, 21.4, 22.6,
        23.7, 24.9, 26.0, 27.2, 28.4, 29.6, 30.7, 31.9, 33.0, 34.1,
        35.3, 36.5, 37.7, 38.8, 38.8, 38.8, 38.8, 38.8, 38.8, 45.9,
        47.1, 48.2, 49.3, 50.5, 51.7, 52.8, 54.0, 55.1, 56.2, 57.3,
        58.5, 59.6, 60.8, 61.9, 63.1, 64.2, 65.3, 66.4, 67.5, 68.6,
        69.7, 70.8, 71.9, 72.8, 73.7, 74.5, 75.3, 76.0, 76.7, 77.4,
        77.9, 78.5, 79.1, 79.5, 80.0, 80.3, 80.6, 80.9, 81.1, 81.3,
        81.5, 81.7, 81.9, 82.0, 82.1, 82.2, 82.3, 82.4, 82.5, 82.6,
        82.7, 82.8, 82.9, 83.0, 82.9, 82.8, 82.7, 82.5, 82.4, 82.3,
        82.1, 81.9, 81.7, 81.5, 81.3, 81.1, 80.9, 80.7, 80.5, 80.3
    ];
    
    // Method to send data to iPhone
    func transmitDataToPhone(skiingData: SkiingData, completion: @escaping () -> Void) {
        if WCSession.default.isReachable {
            print("Session reachable, sending data")
            WCSession.default.sendMessage(["duration": skiingData.duration,
                                           "timestamp": Date(),
                                           "altitude": altitudeExample, // skiingData.altitude
                                           "heartRate": heartRateExample, // skiingData.heartRate
                                           "speed": speedExample, // skiingData.speed
                                           "topSpeed": skiingData.topSpeed,
                                          ], replyHandler: nil, errorHandler: nil)
        } else {
            print("Session not reachable")
            completion()
        }
    }
}


// StatsView to display skiing stats and manage the session
struct StatsView: View {
    @Environment(\.presentationMode) var presentationMode
//    @StateObject private var viewModel = StatsViewModel()

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
        StatsViewModel.shared.transmitDataToPhone(skiingData: StatsViewModel.shared.skiingData) {
            isTransmitting = false
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            skiingTime += 1
            StatsViewModel.shared.skiingData.duration = skiingTime
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
                    StatsViewModel.shared.skiingData.altitude.append(currentAltitude)
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
                    StatsViewModel.shared.skiingData.speed.append(simulatedSpeed)
                    self.topSpeed = max(self.topSpeed, simulatedSpeed)
                    StatsViewModel.shared.skiingData.topSpeed = self.topSpeed
                }
            }
        }

        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { _, samples, _, _, _ in
            if let samples = samples as? [HKQuantitySample] {
                if let latestHeartRate = samples.last?.quantity.doubleValue(for: .count().unitDivided(by: .minute())) {
                    let currentHeartRate = Int(latestHeartRate)
                    self.heartRate = currentHeartRate
                    StatsViewModel.shared.skiingData.heartRate.append(currentHeartRate)
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
