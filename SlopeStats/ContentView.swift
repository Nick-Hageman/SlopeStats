import SwiftUI
import CoreData
import WatchConnectivity
import UIKit

// Function to show an alert
func showAlert(message: String) {
    // Create an alert controller
    let alertController = UIAlertController(title: "Debugging Alert",
                                            message: message,
                                            preferredStyle: .alert)
    
    // Add an "OK" action to dismiss the alert
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(okAction)
    
    // Get the topmost view controller and present the alert
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        if let topController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            topController.present(alertController, animated: true, completion: nil)
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: SkiingDataEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SkiingDataEntity.timestamp, ascending: false)],
        animation: .default
    ) private var skiingDataEntities: FetchedResults<SkiingDataEntity>

    @StateObject private var wcSessionDelegate = WCSessionDelegateImpl()
    @State private var selectedTab: Tab = .navigation

    private enum Tab {
        case navigation, weather, resort
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Title/Nav bar
                HStack {
                    Image(systemName: "snowflake") // Placeholder logo
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.leading, 16)
                    Spacer()
                    Text("App Title")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "ellipsis") // Placeholder icon on right
                        .resizable()
                        .frame(width: 20, height: 20)
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
                        .onAppear {
                            if !WCSession.default.isReachable {
                                showAlert(message: "WCSession is not reachable")
                            }
                        }

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

    var body: some View {
        VStack(alignment: .leading) {
            Text("Duration: \(formatTime(skiingData.duration))")
                .font(.headline)
            Divider()
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
