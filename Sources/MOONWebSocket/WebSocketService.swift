import NIOConcurrencyHelpers
import Vapor

public protocol WebSocketService: Sendable {
    func connect(using configuration: WebSocketConfiguration)
    func send(_ text: String)
    func disconnect()

    var onEvent: (@Sendable (WebSocketEvent) -> Void)? { get set }
}

public final class DefaultWebSocketService: @unchecked Sendable {
    private let eventLoopGroup: any EventLoopGroup
    private let socketBox = NIOLockedValueBox<WebSocket?>(nil)
    private let startedBox = NIOLockedValueBox<Bool>(false)

    public var onEvent: (@Sendable (WebSocketEvent) -> Void)?

    public init(eventLoopGroup: any EventLoopGroup) {
        self.eventLoopGroup = eventLoopGroup
    }
}

// MARK: - Methods

extension DefaultWebSocketService: WebSocketService {
    public func connect(using configuration: WebSocketConfiguration) {
        let wasStarted = startedBox.withLockedValue { started -> Bool in
            if started { return true }
            started = true
            return false
        }
        if wasStarted { return }

        let future: EventLoopFuture<Void> = WebSocket.connect(
            to: configuration.url,
            headers: configuration.headers ?? [:],
            on: eventLoopGroup
        ) { [weak self] socket in
            guard let self else { return }

            socketBox.withLockedValue { $0 = socket }

            onEvent?(.connected)

            socket.onText { [weak self] _, text in
                self?.onEvent?(.text(text))
            }

            socket.onClose.whenComplete { [weak self] result in
                guard let self else { return }

                socketBox.withLockedValue { $0 = nil }
                startedBox.withLockedValue { $0 = false }

                switch result {
                case .success: onEvent?(.closed)
                case let .failure(error): onEvent?(.error(error))
                }
            }
        }

        future.whenFailure { [weak self] error in
            guard let self else { return }

            startedBox.withLockedValue { $0 = false }
            onEvent?(.error(error))
        }
    }

    public func send(_ text: String) {
        socketBox.withLockedValue { $0?.send(text) }
    }

    public func disconnect() {
        let ws = socketBox.withLockedValue { box -> WebSocket? in
            let current = box
            box = nil
            return current
        }

        _ = ws?.close()
        startedBox.withLockedValue { $0 = false }
    }
}
