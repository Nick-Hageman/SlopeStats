import SwiftUI
import SceneKit

struct ContentView: View {
    @State private var currentIndex: Int = 0

    var body: some View {
        NavigationView { // Add NavigationView
            ZStack {
                Image("snowyMountain")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    TabView(selection: $currentIndex) {
                        ForEach(activityItems) { activity in
                            VStack {
                                Text(activity.title)
                                    .font(.headline)
                                    .foregroundColor(.white)

                                SceneView(
                                    scene: createRotatingScene(for: activity.fileName),
                                    options: [.autoenablesDefaultLighting]
                                )
                                .frame(width: 50, height: 50)

                                if activity.title == "Activity Tracker" {
                                    NavigationLink(destination: CountdownView()) {
                                        Text(activity.buttonText)
                                            .font(.subheadline)
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 10)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                } else {
                                    Button(action: {
                                        // Handle other actions
                                    }) {
                                        Text(activity.buttonText)
                                            .font(.subheadline)
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 10)
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding()
                            .frame(width: 150, height: 150)
                            .background(Color.black)
                            .cornerRadius(15)
                            .padding(.horizontal)
                            .shadow(radius: 10)
                            .tag(activityItems.firstIndex(where: { $0.id == activity.id }) ?? 0)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                    HStack(spacing: 8) {
                        ForEach(activityItems.indices, id: \.self) { index in
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundColor(currentIndex == index ? .blue : .gray)
                                .onTapGesture {
                                    currentIndex = index
                                }
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
    
    func createRotatingScene(for fileName: String) -> SCNScene {
        let scene = SCNScene(named: fileName) ?? SCNScene()
        let rootNode = scene.rootNode
        let rotationAction = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 10)
        let repeatAction = SCNAction.repeatForever(rotationAction)
        rootNode.runAction(repeatAction)
        return scene
    }
}

struct ActivityItem: Identifiable {
    let id = UUID()
    let title: String
    let fileName: String
    let buttonText: String
}

let activityItems: [ActivityItem] = [
    ActivityItem(title: "Activity Tracker", fileName: "skier.usdz", buttonText: "Start Run"),
    ActivityItem(title: "Speed Mode", fileName: "olympicRings.usdz", buttonText: "Start Run"),
    ActivityItem(title: "Resort info", fileName: "cabin.usdz", buttonText: "View Info"),
    ActivityItem(title: "Weather", fileName: "earth.usdz", buttonText: "View Info")
]

#Preview {
    ContentView()
}
