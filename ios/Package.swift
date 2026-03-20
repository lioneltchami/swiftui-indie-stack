// swift-tools-version: 5.9
// This file is for reference only - add these packages via Xcode SPM
//
// Static Linking Notes:
// - The MyApp library product uses .static linking for faster app launch times.
// - RevenueCat and TelemetryDeck support static linking.
// - IMPORTANT: Firebase SDK MUST remain dynamically linked due to its method
//   swizzling behavior. Do not add .type(.static) to Firebase products.
// - In Xcode Build Settings, set MACH_O_TYPE = staticlib for SPM packages
//   where applicable to reduce dynamic library load time at launch.

/*
 Add these packages to your Xcode project via:
 File > Add Package Dependencies...

 Required packages:
 - https://github.com/gonzalezreal/swift-markdown-ui (2.4.0)
 - https://github.com/simibac/ConfettiSwiftUI (1.1.0)
 - https://github.com/markiv/SwiftUI-Shimmer (1.5.0)

 Optional packages (based on AppConfiguration):

 If useRevenueCat = true:
 - https://github.com/RevenueCat/purchases-ios (5.66.0)  // latest as of March 2026

 If useTelemetryDeck = true:
 - https://github.com/TelemetryDeck/SwiftSDK (2.11.0)  // latest as of March 2026

 If useFirebase = true:
 - https://github.com/firebase/firebase-ios-sdk (12.11.0)  // major version bump; requires Xcode 16.2+
 - https://github.com/google/GoogleSignIn-iOS (9.1.0)  // latest as of March 2026

 NOTE: NetworkImage dependency removed -- it is unused in the template.
 NOTE: Firebase 12.x is a major version change from 11.x. Review migration guide before upgrading.
*/

import PackageDescription

let package = Package(
    name: "MyApp",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MyApp",
            type: .static,
            targets: ["MyApp"]
        ),
    ],
    dependencies: [
        // Required
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.4.0"),
        .package(url: "https://github.com/simibac/ConfettiSwiftUI", from: "1.1.0"),
        .package(url: "https://github.com/markiv/SwiftUI-Shimmer", from: "1.5.0"),
        // NetworkImage removed -- unused in template

        // Optional - RevenueCat (latest: 5.66.0)
        .package(url: "https://github.com/RevenueCat/purchases-ios", from: "5.31.0"),

        // Optional - TelemetryDeck (latest: 2.11.0)
        .package(url: "https://github.com/TelemetryDeck/SwiftSDK", from: "2.9.0"),

        // Testing - Snapshot Testing
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.15.0"),

        // Optional - Firebase (uncomment if useFirebase = true)
        // latest: firebase-ios-sdk 12.11.0 (major version -- requires Xcode 16.2+), GoogleSignIn-iOS 9.1.0
        // .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "12.11.0"),
        // .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "9.1.0"),
    ],
    targets: [
        .target(
            name: "MyApp",
            dependencies: [
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
                .product(name: "ConfettiSwiftUI", package: "ConfettiSwiftUI"),
                .product(name: "Shimmer", package: "SwiftUI-Shimmer"),
                // NetworkImage removed -- unused
                .product(name: "RevenueCat", package: "purchases-ios"),
                .product(name: "RevenueCatUI", package: "purchases-ios"),
                .product(name: "TelemetryDeck", package: "SwiftSDK"),
                // Uncomment if useFirebase = true:
                // .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                // .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                // .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                // .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
            ]
        ),
    ]
)
