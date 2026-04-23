import Vapor

extension Application {
    private struct WebSocketServiceKey: StorageKey {
        typealias Value = WebSocketService
    }

    var webSocketService: any WebSocketService {
        get { storage[WebSocketServiceKey.self]! }
        set { storage[WebSocketServiceKey.self] = newValue }
    }
}
