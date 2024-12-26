import WatchConnectivity
import WatchKit
import Foundation

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    var session: WCSession?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        // Only activate session once
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    // WCSessionDelegate methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
            return
        }

        print("WCSession activated with state: \(activationState)")
        
        // Once activated, check if it's reachable and send a message
        if session.isReachable {
            print("Watch is reachable by iPhone")
            // Example: Send a message to the iPhone app
            sendMessageToiPhone()
        } else {
            print("Watch is not reachable")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle incoming messages from the iPhone
        print("Received message from iPhone: \(message)")
    }

    private func sendMessageToiPhone() {
        // Ensure WCSession is activated and reachable before sending messages
        guard let session = session else { return }
        if session.isReachable {
            session.sendMessage(["key": "value"], replyHandler: { response in
                print("Received response from iPhone: \(response)")
            }, errorHandler: { error in
                print("Error sending message to iPhone: \(error.localizedDescription)")
            })
        } else {
            print("iPhone is not reachable")
        }
    }
}
