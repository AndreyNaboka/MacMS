// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacMS",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "MacMS", targets: ["MacMS"])
    ],
    targets: [
        .executableTarget(
            name: "MacMS",
            path: "Sources/MacMS",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("ServiceManagement")
            ]
        )
    ]
)
