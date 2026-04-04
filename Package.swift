// swift-tools-version: 6.0

//
//  Project.swift
//  Navigation
//
//  Created by jch on 2/11/26.
//

import PackageDescription

let package = Package(
    name: "Navigation",
    
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Navigation",
            targets: ["Navigation"]
        )
    ],
    
    targets: [
        .target(
            name: "Navigation",
            dependencies: [],
            path: "Sources/Navigation"
        ),
        .testTarget(
            name: "NavigationTests",
            dependencies: ["Navigation"],
            path: "Tests/NavigationTests"
        )
    ]
)
