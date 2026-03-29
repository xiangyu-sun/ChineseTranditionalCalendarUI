// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ChineseTranditionalCalendarUI",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "ChineseTranditionalCalendarUI",
            targets: ["ChineseTranditionalCalendarUI"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/xiangyu-sun/ChineseAstrologyCalendar.git",
            branch: "master"
        ),
    ],
    targets: [
        .target(
            name: "ChineseTranditionalCalendarUI",
            dependencies: ["ChineseAstrologyCalendar"]
        ),
        .testTarget(
            name: "ChineseTranditionalCalendarUITests",
            dependencies: ["ChineseTranditionalCalendarUI"]
        ),
    ]
)
