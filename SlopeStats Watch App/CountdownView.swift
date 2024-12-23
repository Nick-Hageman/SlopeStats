import SwiftUI

struct CountdownView: View {
    @State private var countdown: Int = 3
    @State private var navigateToStats: Bool = false // Flag for navigation

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if navigateToStats {
                StatsView()
            } else {
                Text("\(countdown)")
                    .font(.system(size: 100, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .onAppear {
                        startCountdown()
                    }
            }
        }
    }
    
    // Countdown logic
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
                navigateToStats = true // Navigate to StatsView
            }
        }
    }
}

#Preview {
    CountdownView()
}
