// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacStorageTracker",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "storage-tracker", targets: ["StorageTrackerApp"]),
        .library(name: "StorageTrackerCore", targets: ["StorageTrackerCore"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "StorageTrackerCore",
            dependencies: []
        ),
        .executableTarget(
            name: "StorageTrackerApp",
            dependencies: ["StorageTrackerCore"]
        ),
        .testTarget(
            name: "StorageTrackerTests",
            dependencies: ["StorageTrackerCore"]
        ),
    ]
)
