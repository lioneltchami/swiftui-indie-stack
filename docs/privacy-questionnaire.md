# App Store Connect Privacy Questionnaire Guide

This document maps the template's data practices to App Store Connect's privacy questions.

## Data Types Collected

### Analytics Data (Product Interaction)

- **What**: Screen views, button taps, feature usage, streak milestones
- **Provider**: TelemetryDeck (privacy-preserving, no PII)
- **Linked to identity**: No
- **Used for tracking**: No
- **App Store Connect answer**: "Product Interaction" > "Analytics"

### Device Identifiers

- **What**: identifierForVendor (stored in Keychain as localUserId)
- **Purpose**: RevenueCat subscription identity, TelemetryDeck user pseudonym
- **Linked to identity**: No (pseudonymous)
- **Used for tracking**: No
- **App Store Connect answer**: "Device ID" > "Analytics" and "App Functionality"

### Purchase History

- **What**: Subscription status, entitlements
- **Provider**: RevenueCat
- **Linked to identity**: Yes (tied to Apple ID via StoreKit)
- **Used for tracking**: No
- **App Store Connect answer**: "Purchase History" > "App Functionality"

### User Content (if Firebase enabled)

- **What**: Streak data, settings, activity logs
- **Provider**: Firebase Firestore
- **Linked to identity**: Yes (tied to Firebase UID)
- **Used for tracking**: No
- **App Store Connect answer**: "Other User Content" > "App Functionality"

## Required Reason APIs Declared

| API Category   | Reason Code | Why                                            |
| -------------- | ----------- | ---------------------------------------------- |
| UserDefaults   | CA92.1      | App preferences, streak data, onboarding state |
| File Timestamp | C617.1      | Library content cache freshness checks         |
| Disk Space     | E174.1      | CachedAsyncImage URLCache management           |

## Third-Party SDK Privacy Manifests

| SDK                     | Ships Own Manifest? | Notes                              |
| ----------------------- | ------------------- | ---------------------------------- |
| RevenueCat              | Yes (5.31+)         | Declares purchase data collection  |
| TelemetryDeck           | Yes (2.9+)          | Declares analytics data collection |
| Firebase (optional)     | Yes (11.0+)         | Declares crash data, analytics     |
| GoogleSignIn (optional) | Yes (8.0+)          | Declares auth data                 |

Run "Product > Generate Privacy Report" in Xcode before submission to verify all manifests are aggregated correctly.
