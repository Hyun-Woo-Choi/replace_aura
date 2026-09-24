import Foundation
import WatchConnectivity

/// Thin wrapper around `WCSession`, used by both the iPhone and the watch app.
@MainActor
final class ConnectivityManager: NSObject, ObservableObject {
    static let shared = ConnectivityManager()

    /// Most recent message received from the counterpart device.
    @Published private(set) var lastMessage: WatchMessage?

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    /// Queues a message for delivery; delivered even if the counterpart isn't reachable.
    func send(_ message: WatchMessage) {
        guard WCSession.default.activationState == .activated,
              let data = try? encoder.encode(message) else { return }
        WCSession.default.transferUserInfo(["payload": data])
    }

    fileprivate func handle(_ userInfo: [String: Any]) {
        guard let data = userInfo["payload"] as? Data,
              let message = try? decoder.decode(WatchMessage.self, from: data) else { return }
        lastMessage = message
        // TODO: route feedback/self-reports to storage and the bandit policy (iOS side).
    }
}

extension ConnectivityManager: WCSessionDelegate {
    nonisolated func session(_ session: WCSession,
                             activationDidCompleteWith activationState: WCSessionActivationState,
                             error: Error?) {}

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        let payload = userInfo["payload"] as? Data
        Task { @MainActor in
            if let payload { self.handle(["payload": payload]) }
        }
    }

    #if os(iOS)
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}
