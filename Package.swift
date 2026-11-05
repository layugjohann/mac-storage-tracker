// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacStorageTracker",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "storage-tracker", targets: ["StorageTrackerApp"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "StorageTrackerCore",
            dependencies: []
        ),
        .executableTarget(
            name: "StorageTrackerApp",
            dependencies: ["StorageTrackerCore"],
            exclude: ["Info.plist"],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Sources/StorageTrackerApp/Info.plist"
                ])
            ]
        ),
        .testTarget(
            name: "StorageTrackerTests",
            dependencies: ["StorageTrackerCore"]
        ),
    ]
)
