// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Hideout",
    defaultLocalization: "ko",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "Hideout",
            targets: ["Hideout"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/kingslay/KSPlayer.git", from: "2.3.0")
    ],
    targets: [
        .target(
            name: "Hideout",
            dependencies: [
                .product(name: "KSPlayer", package: "KSPlayer")
            ],
            path: "Hideout"
        )
    ]
)
