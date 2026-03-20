# Getting Started with SwiftUI Indie Stack

Welcome to SwiftUI Indie Stack, a production-ready iOS app template designed for indie developers building subscription-based apps. This guide walks you through setting up the template and running it for the first time.

## Prerequisites

Before you begin, make sure you have the following installed:

- **macOS 14 (Sonoma)** or later
- **Xcode 15** or later (Xcode 16 recommended)
- **An Apple Developer account** (free tier works for simulator testing)
- **Git** for version control

## Step 1: Clone the Repository

Clone the SwiftUI Indie Stack repository to your local machine:

```bash
git clone https://github.com/cliffordh/swiftui-indie-stack.git
cd swiftui-indie-stack
```

## Step 2: Open in Xcode

Open the Xcode project file located in the `ios/` directory:

```bash
open ios/MyApp.xcodeproj
```

Xcode will automatically resolve Swift Package Manager dependencies. This may take a few minutes the first time.

## Step 3: Run in the Simulator

Select an iPhone simulator (iPhone 15 Pro or later recommended) from the device dropdown in Xcode's toolbar. Press **Cmd+R** to build and run. The app should launch with the onboarding flow on first run.

## Step 4: Explore the Features

The template includes several features out of the box:

- **Onboarding**: A 3-screen introduction flow shown on first launch
- **Home Dashboard**: Displays streak status, daily goals, and quick actions
- **Library**: A GitHub-hosted CMS for markdown articles with categories and search
- **Settings**: Account management, appearance preferences, and subscription controls
- **Widgets**: Home screen and lock screen widgets showing streak progress

## Step 5: Configure Your App

Open `ios/Sources/App/AppConfiguration.swift` to review the feature flags. By default, Firebase is disabled and the app runs in local-only mode. You can enable features one at a time as you set up the corresponding services.

Key flags to review:

- `useFirebase` -- Set to `true` after adding `GoogleService-Info.plist`
- `useRevenueCat` -- Already `true`; replace the API key with yours
- `useTelemetryDeck` -- Already `true`; replace the app ID with yours

## Next Steps

Check out the **Customization Guide** to learn how to rebrand the template for your own app, and the **Deployment Guide** when you are ready to submit to the App Store. For a complete checklist of everything you need to change, see `CUSTOMIZATION_CHECKLIST.md` in the project root.
