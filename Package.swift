// swift-tools-version:5.7
import PackageDescription

var dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-system", from: "1.0.0"),
    .package(url: "https://github.com/jpsim/Yams", from: "5.0.0"),
    .package(url: "https://github.com/tadija/AEXML", from: "4.0.0"),
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    .package(url: "https://github.com/ileitch/swift-indexstore", from: "9.0.0"),
    .package(url: "https://github.com/peripheryapp/swift-syntax", exact: "1.0.2"),
    .package(url: "https://github.com/ileitch/swift-filename-matcher", from: "0.0.0"),
]

#if os(macOS)
dependencies.append(
    .package(
        url: "https://github.com/tuist/xcodeproj",
        from: "8.0.0"
    )
)
#endif

var frontendDependencies: [PackageDescription.Target.Dependency] = [
    .target(name: "Shared"),
    .target(name: "PeripheryKit"),
    .product(name: "ArgumentParser", package: "swift-argument-parser"),
    .product(name: "FilenameMatcher", package: "swift-filename-matcher")
]

#if os(macOS)
frontendDependencies.append(.target(name: "XcodeSupport"))
#endif

var targets: [PackageDescription.Target] = [
    .executableTarget(
        name: "Frontend",
        dependencies: frontendDependencies
    ),
    .plugin(
        name: "PeripheryCommandPlugin",
        capability: .command(
            intent: .custom(verb: "periphery", description: "Detect unused code"),
            permissions: []
        ),
        dependencies: [
            .target(name: "PeripheryBinary", condition: .when(platforms: [.macOS])),
        ]
    ),
    .target(
        name: "PeripheryKit",
        dependencies: [
            .target(name: "Shared"),
            .product(name: "SystemPackage", package: "swift-system"),
            .product(name: "AEXML", package: "AEXML"),
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftParser", package: "swift-syntax"),
            .product(name: "SwiftIndexStore", package: "swift-indexstore"),
            .product(name: "FilenameMatcher", package: "swift-filename-matcher")
        ]
    ),
    .target(
        name: "Shared",
        dependencies: [
            .product(name: "Yams", package: "Yams"),
            .product(name: "SystemPackage", package: "swift-system"),
            .product(name: "FilenameMatcher", package: "swift-filename-matcher")
        ]
    ),
    .target(
        name: "TestShared",
        dependencies: [
            .target(name: "PeripheryKit")
        ],
        path: "Tests/Shared"
    ),
    .target(
        name: "ExternalModuleFixtures",
        path: "Tests/Fixtures/ExternalModuleFixtures"
    ),
    .target(
        name: "CrossModuleRetentionFixtures",
        dependencies: [
            .target(name: "CrossModuleRetentionSupportFixtures")
        ],
        path: "Tests/Fixtures/CrossModuleRetentionFixtures"
    ),
    .target(
        name: "CrossModuleRetentionSupportFixtures",
        path: "Tests/Fixtures/CrossModuleRetentionSupportFixtures"
    ),
    .target(
        name: "RetentionFixtures",
        dependencies: [
            .target(name: "ExternalModuleFixtures")
        ],
        path: "Tests/Fixtures/RetentionFixtures"
    ),
    .target(
        name: "UnusedParameterFixtures",
        path: "Tests/Fixtures/UnusedParameterFixtures"
    ),
    .target(
        name: "TypeSyntaxInspectorFixtures",
        path: "Tests/Fixtures/TypeSyntaxInspectorFixtures"
    ),
    .target(
        name: "DeclarationVisitorFixtures",
        path: "Tests/Fixtures/DeclarationVisitorFixtures"
    ),
    .testTarget(
        name: "PeripheryTests",
        dependencies: [
            .target(name: "TestShared"),
            .target(name: "PeripheryKit")
        ]
    ),
    .testTarget(
        name: "SPMTests",
        dependencies: [
            .target(name: "TestShared"),
            .target(name: "PeripheryKit")
        ],
        exclude: ["SPMProject"]
    ),
    .testTarget(
        name: "AccessibilityTests",
        dependencies: [
            .target(name: "TestShared"),
            .target(name: "PeripheryKit")
        ],
        exclude: ["AccessibilityProject"]
    ),
   .binaryTarget(
       name: "PeripheryBinary",
       url: "https://github.com/peripheryapp/Periphery/releases/download/2.14.0/periphery-2.14.0-macos.artifactbundle.zip",
       checksum: "c45678908c7ff793d72f63f1dd5736847962c2e16fb60598feb822d26ef08d7f"
   ),
]

#if os(macOS)
targets.append(contentsOf: [
    .target(
        name: "XcodeSupport",
        dependencies: [
            .target(name: "Shared"),
            .target(name: "PeripheryKit"),
            .product(name: "XcodeProj", package: "XcodeProj"),
        ]
    ),
    .target(
        name: "ObjcAccessibleRetentionFixtures",
        path: "Tests/Fixtures/ObjcAccessibleRetentionFixtures"
    ),
    .target(
        name: "ObjcAnnotatedRetentionFixtures",
        path: "Tests/Fixtures/ObjcAnnotatedRetentionFixtures"
    ),
    .testTarget(
        name: "XcodeTests",
        dependencies: [
            .target(name: "TestShared"),
            .target(name: "PeripheryKit"),
            .target(name: "XcodeSupport")
        ],
        exclude: ["UIKitProject", "SwiftUIProject"]
    )
])
#endif

let package = Package(
    name: "Periphery",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "periphery", targets: ["Frontend"]),
        .plugin(name: "PeripheryCommandPlugin", targets: ["PeripheryCommandPlugin"]),
    ],
    dependencies: dependencies,
    targets: targets,
    swiftLanguageVersions: [.v5]
)
