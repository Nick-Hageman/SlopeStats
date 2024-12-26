import WatchConnectivity
import CoreData
import Combine

class WCSessionDelegateImpl: NSObject, WCSessionDelegate, ObservableObject {
    @Published var lastReceivedData: SkiingDataEntity? // For broadcasting updates

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        // Check if there was an error during activation
        if let error = error {
            // Handle the error (e.g., log it or alert the user)
            print("WCSession activation failed with error: \(error.localizedDescription)")
            return
        }

        // Handle different activation states
        switch activationState {
        case .activated:
            print("WCSession activated successfully.")
            // You can now send and receive messages with the watch
            if WCSession.default.isReachable {
                // Example: Send a message to the watch
                WCSession.default.sendMessage(["key": "value"], replyHandler: { response in
                    print("Received response from watch: \(response)")
                }, errorHandler: { error in
                    print("Error sending message: \(error.localizedDescription)")
                })
            }
            
        case .inactive:
            print("WCSession is inactive.")
            // Handle the inactive state (e.g., perform cleanup or pause communication)

        case .notActivated:
            print("WCSession is not activated.")
            // You can inform the user or attempt to activate the session again if needed

        @unknown default:
            print("Unknown WCSession activation state.")
        }
    }

    // This method is called when a message is received from the watchOS app
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Access the Core Data context from the PersistenceController directly
        let context = PersistenceController.shared.container.viewContext
        
        // Parse the message
        if let duration = message["duration"] as? TimeInterval,
           let altitude = message["altitude"] as? [Double],
           let heartRate = message["heartRate"] as? [Int],
           let speed = message["speed"] as? [Double],
           let topSpeed = message["topSpeed"] as? Double {
            
            // Save the data into Core Data
            let skiingDataEntity = SkiingDataEntity(context: context)
            skiingDataEntity.duration = duration

            // Create an instance of the ArrayToDataTransformer
            let transformer = ArrayToDataTransformer()

            // Use the transformedValue method on the instance
            skiingDataEntity.altitude = transformer.transformedValue(altitude) as? NSData
            skiingDataEntity.speed = transformer.transformedValue(speed) as? NSData
            skiingDataEntity.heartRate = transformer.transformedValue(heartRate) as? NSData

            skiingDataEntity.topSpeed = topSpeed
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
    }

    // This method is required by WCSessionDelegate, even if you don't use it
    func sessionDidBecomeInactive(_ session: WCSession) {
        // You can implement any additional logic here if needed
        print("WCSession did become inactive")
    }
    
    // This method is required by WCSessionDelegate, even if you don't use it
    func sessionDidDeactivate(_ session: WCSession) {
        // You can implement any additional logic here if needed
        print("WCSession did deactivate")
    }
    
    // This method is required by WCSessionDelegate, even if you don't use it
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        // You can implement logic here to handle application context if needed
        print("Received application context: \(applicationContext)")
    }
}
