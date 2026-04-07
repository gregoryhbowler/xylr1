// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AudioEngine",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AudioEngine", targets: ["AudioEngine"]),
    ],
    targets: [
        .target(
            name: "AudioEngine",
            dependencies: ["PlaitsLib"],
            path: "Sources",
            exclude: ["Plaits"],
            sources: ["AudioEngine", "DSP", "Effects", "Revise"]
        ),
        .target(
            name: "PlaitsLib",
            path: "Sources/Plaits",
            sources: ["plaits_bridge.cpp"],
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("."),
                .define("PLAITS_STANDALONE", to: "1"),
            ]
        ),
        .testTarget(
            name: "AudioEngineTests",
            dependencies: ["AudioEngine"],
            path: "Tests"
        ),
    ],
    cxxLanguageStandard: .cxx17
)
