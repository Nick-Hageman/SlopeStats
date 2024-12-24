import SwiftUI

struct SpeedModeCountdownView: View {
    let hours: Int
    let minutes: Int
    let seconds: Int

    @State private var timeRemaining: Int
    @State private var timer: Timer?
    @State private var isTimeUp: Bool = false

    init(hours: Int, minutes: Int, seconds: Int) {
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
        self._timeRemaining = State(initialValue: (hours * 3600) + (minutes * 60) + seconds)
    }

    var body: some View {
        VStack {
            if isTimeUp {
                VStack {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.red)

                    Text("Time limit exceeded")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    StatRowView(iconName: "timer", label: "Time", value: timeString(from: timeRemaining), unit: "", iconColor: .white, fontColor: .white)
                    StatRowView(iconName: "speedometer", label: "Speed", value: "120", unit: "km/h", iconColor: .yellow, fontColor: .yellow)
                    StatRowView(iconName: "gearshape", label: "Avg Speed", value: "25", unit: "km/h", iconColor: .orange, fontColor: .orange)
                    StatRowView(iconName: "flame", label: "Top Speed", value: "45", unit: "km/h", iconColor: .red, fontColor: .red)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(15)
                .padding(.horizontal)

                Button(action: {
                    stopTimer()
                }) {
                    Text("End Run")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
                isTimeUp = true
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func timeString(from seconds: Int) -> String {
        let hrs = seconds / 3600
        let mins = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d:%02d", hrs, mins, secs)
    }
}
