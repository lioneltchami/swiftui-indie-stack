# Customizing Your App

This guide covers how to transform the SwiftUI Indie Stack template into your own branded application. Every placeholder value is designed to be easy to find and replace.

## Project Identity

Start by updating the core identity of your app:

1. **Rename the Xcode project** from `MyApp` to your app name using Xcode's project navigator (click the project name at the top of the file tree and rename it).
2. **Update the Bundle Identifier** in the project settings under Signing & Capabilities. Use your reverse-domain format, such as `com.yourcompany.yourapp`.
3. **Replace the app icon** in `Assets.xcassets` with your own 1024x1024 icon. Xcode will generate all required sizes automatically.

## Configuration File

The central configuration file is `AppConfiguration.swift`, located at `ios/Sources/App/`. Open it and update these values:

- `appName` -- Your app's display name
- `appStoreID` -- Your App Store listing ID (found in App Store Connect)
- `supportEmail` -- Your support contact email
- `revenueCatAPIKey` -- Your RevenueCat API key from the RevenueCat dashboard
- `telemetryDeckAppID` -- Your TelemetryDeck app ID from the TelemetryDeck dashboard
- `libraryIndexURL` -- URL to your own content index (or keep the default for testing)
- `termsOfServiceURL` -- Link to your Terms of Service page
- `privacyPolicyURL` -- Link to your Privacy Policy page

## Theming

The visual identity of your app is controlled by two files in `ios/Sources/UI/Theme/`:

- **AppColors.swift** -- Define your brand colors. The template uses a primary accent color throughout the app. Change it here and every button, highlight, and icon tint updates automatically.
- **AppFonts.swift** -- Customize the typography. The template uses the system SF font by default, but you can swap in custom fonts here.

Both files support light and dark mode. Test your color choices in both modes using the preview canvas or the Settings appearance toggle.

## Onboarding

The onboarding flow in `OnboardingView.swift` has three screens. Each screen has a title, description, and SF Symbol icon. Replace the placeholder text and icons with content that introduces your app's value proposition. Keep it to 3 screens maximum -- research shows that shorter onboarding flows have higher completion rates.

## Content

The Library feature loads articles from a JSON index file hosted on GitHub. To use your own content:

1. Create markdown articles in a `content/articles/` directory in your repository
2. Update `content/index.json` with metadata for each article
3. Point `AppConfiguration.libraryIndexURL` to your raw GitHub content URL

Articles support standard markdown formatting and are rendered using the MarkdownUI package.

## Widget Customization

Widgets require an App Group identifier that matches between the main app target and the widget extension target. Create an App Group in the Apple Developer Portal and update the identifier in both Xcode targets under Signing & Capabilities. Update the hardcoded group string in `WidgetHelper.swift` and `WidgetDataModels.swift` to match.
