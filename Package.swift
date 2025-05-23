// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MastodonClient",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(
            name: "MastodonClient",
            targets: ["MastodonClient"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MastodonClient",
            dependencies: [],
            path: "MastodonClient"
        )
    ]
)