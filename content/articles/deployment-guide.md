# Deploying to the App Store

This guide walks you through the process of building, testing, and submitting your app to the App Store. The SwiftUI Indie Stack template includes CI/CD workflows and Fastlane configuration to automate most of this process.

## Prerequisites

Before you begin, make sure you have:

- An **Apple Developer Program** membership ($99/year)
- An **App Store Connect** listing created for your app
- **Fastlane** installed (`gem install fastlane`)
- Your app fully customized (see the Customization Guide)

## Step 1: Configure Code Signing

The template uses Fastlane Match for code signing, which stores certificates and provisioning profiles in a private Git repository.

1. Create a private repository for your certificates (e.g., `your-org/certificates`)
2. Update `ios/fastlane/Matchfile` with your repository URL
3. Run `cd ios && fastlane certificates` to generate and store signing assets

## Step 2: Set Up RevenueCat Products

If your app uses subscriptions:

1. Create subscription products in **App Store Connect** under your app's In-App Purchases section
2. Create matching products in the **RevenueCat dashboard** and link them to your App Store Connect products
3. Update `AppConfiguration.revenueCatAPIKey` with your production API key
4. Test purchases using the Xcode StoreKit testing environment or a sandbox Apple ID

## Step 3: Test Locally

Before submitting, run a full test pass:

```bash
# Run all unit tests
cd ios && xcodebuild test -project MyApp.xcodeproj -scheme MyApp -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16'

# Lint the codebase
swiftlint lint

# Build a release archive
cd ios && xcodebuild archive -project MyApp.xcodeproj -scheme MyApp -archivePath build/MyApp.xcarchive
```

Test on a physical device to verify code signing, push notifications, and widget functionality. Simulator testing does not cover these scenarios.

## Step 4: Deploy to TestFlight

The template supports two deployment methods:

**Automated (recommended):** Push a version tag to trigger the GitHub Actions workflow:

```bash
git tag v1.0.0
git push origin v1.0.0
```

The `deploy-testflight.yml` workflow will build the app, sign it, and upload it to TestFlight automatically.

**Manual:** Use Fastlane from your local machine:

```bash
cd ios && fastlane beta
```

## Step 5: Submit for Review

Once your TestFlight build is tested and ready:

1. Open **App Store Connect** and navigate to your app
2. Create a new version and select your TestFlight build
3. Fill in the app description, keywords, and screenshots (5.5" and 6.5" required)
4. Complete the **App Privacy** section based on your actual data collection
5. Submit the `PrivacyInfo.xcprivacy` manifest with accurate API declarations
6. Submit for review

Apple typically reviews apps within 24-48 hours. Common rejection reasons include missing privacy descriptions, placeholder content left in the app, and subscription pricing that does not match App Store Connect.

## CI/CD Secrets

For the GitHub Actions workflows to run, add these secrets to your repository settings:

- `ASC_KEY_ID` -- App Store Connect API Key ID
- `ASC_ISSUER_ID` -- App Store Connect API Issuer ID
- `ASC_KEY` -- App Store Connect private key (base64 encoded)
- `MATCH_PASSWORD` -- Encryption password for your certificates repository
- `MATCH_GIT_URL` -- URL of your private certificates repository
- `CODECOV_TOKEN` -- Codecov upload token (optional, for coverage reporting)
