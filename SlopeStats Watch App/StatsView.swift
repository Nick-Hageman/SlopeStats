import SwiftUI

struct StatsView: View {
    @Environment(\.presentationMode) var presentationMode // For dismissing the view
    @State private var skiingTime: TimeInterval = 0
    @State private var timer: Timer?

    var body: some View {
        VStack {
            Text(formatTime(skiingTime))
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .onAppear {
                    startTimer()
                }
            
            VStack(alignment: .leading, spacing: 0) {
                StatRowView(iconName: "mountain.2", label: "Altitude", value: "1500", unit: "m", iconColor: .blue, fontColor: .blue)
                StatRowView(iconName: "heart", label: "Heart Rate", value: "120", unit: "bpm", iconColor: .red, fontColor: .red)
                StatRowView(iconName: "speedometer", label: "Speed", value: "25", unit: "km/h", iconColor: .yellow, fontColor: .yellow)
                StatRowView(iconName: "hare", label: "Top Speed", value: "45", unit: "km/h", iconColor: .white, fontColor: .white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black.opacity(0.8))
            .cornerRadius(15)
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                stopTimer()
                presentationMode.wrappedValue.dismiss() // Return to ContentView
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
            .padding(.bottom)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    // Format time as mm:ss
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Start the skiing timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            skiingTime += 1
        }
    }
    
    // Stop the skiing timer
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
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
