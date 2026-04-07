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
            publicHeadersPath: "include",
            cxxSettings: [
                // Include paths so Plaits headers resolve correctly:
                // "plaits/dsp/voice.h" resolves from Sources/Plaits/
                // "stmlib/stmlib.h" resolves from Sources/Plaits/
                .headerSearchPath("."),
                // Define TEST to use mock flash/user_data (no STM32 hardware)
                .define("TEST"),
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
