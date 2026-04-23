// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "moon-web-socket",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "MOONWebSocket",
            targets: ["MOONWebSocket"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.121.4"),
    ],
    targets: [
        .target(
            name: "MOONWebSocket",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        ),
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }
