public enum WebSocketEvent {
    case connected
    case text(String)
    case closed
    case error(any Error)
}
