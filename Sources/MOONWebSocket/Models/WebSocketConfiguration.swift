import Vapor

public struct WebSocketConfiguration {
    public let url: String
    public let headers: HTTPHeaders?

    public init(
        url: String,
        headers: HTTPHeaders? = nil
    ) {
        self.url = url
        self.headers = headers
    }
}
