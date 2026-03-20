//
//  MyApp.swift
//  MyApp
//
//  Main app entry point with conditional Firebase, RevenueCat, and TelemetryDeck initialization.
//

import AppIntents
import SwiftUI
import TipKit
import WidgetKit

#if canImport(RevenueCat)
import RevenueCat
#endif

#if canImport(TelemetryDeck)
import TelemetryDeck
#endif

#if canImport(Firebase)
import Firebase
import FirebaseCrashlytics
#endif

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @AppStorage(StorageKeys.isOnboardingDone) private var isOnboardingDone = false
    @State private var authManager = AuthManager.shared
    @State private var router = AppRouter()
    @State private var errorHandler = ErrorHandler()

    var body: some Scene {
        WindowGroup {
            Group {
                if isOnboardingDone {
                    MainTabView()
                        .modifier(DarkModeViewModifier())
                } else {
                    OnboardingFlowView(isOnboardingDone: $isOnboardingDone)
                }
            }
            .environment(authManager)
            .environment(router)
            .environment(errorHandler)
            .withErrorHandling()
            .task {
                // Deferred initialization - does not block first frame
                guard !ProcessInfo.processInfo.isPreview else { return }

                // Configure TipKit for contextual tips
                try? Tips.configure([
                    .displayFrequency(.weekly),
                    .datastoreLocation(.applicationDefault)
                ])

                // Initialize TelemetryDeck (deferred from didFinishLaunchingWithOptions)
                if AppConfiguration.useTelemetryDeck {
                    #if canImport(TelemetryDeck)
                    let config = TelemetryDeck.Config(appID: AppConfiguration.telemetryDeckAppID)
                    TelemetryDeck.initialize(config: config)
                    TelemetryDeck.signal(AnalyticsEvents.appLaunch, parameters: ["launch_type": "cold"])
                    #endif
                }

                // Initialize auth (Firebase or local depending on config)
                if AppConfiguration.useFirebase {
                    await authManager.handleInitialAuthentication()
                }

                // Configure RevenueCat (deferred from init)
                if AppConfiguration.useRevenueCat {
                    #if canImport(RevenueCat)
                    Purchases.logLevel = .info
                    Purchases.configure(withAPIKey: AppConfiguration.revenueCatAPIKey)
                    PaywallManager.shared.configure()

                    // Set TelemetryDeck attributes in RevenueCat for integration
                    if AppConfiguration.useTelemetryDeck {
                        let defaultUserID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown_user"
                        Purchases.shared.attribution.setAttributes([
                            "$telemetryDeckUserId": defaultUserID,
                            "$telemetryDeckAppId": AppConfiguration.telemetryDeckAppID
                        ])
                    }
                    #endif
                }

                // Register MetricKit subscriber for production diagnostics
                AppMetricSubscriber.shared.register()

                // Register App Shortcuts with the system
                AppShortcuts.updateAppShortcutParameters()
            }
        }
        .commands {
            AppCommands()
        }

        // Multi-window: Article in separate window (iPad)
        WindowGroup("Article", id: "article", for: String.self) { $articleId in
            if let articleId {
                Text("Article: \(articleId)")
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Skip initialization in SwiftUI previews
        guard !ProcessInfo.processInfo.isPreview else {
            return true
        }

        // Initialize Firebase (if enabled) - must stay here for method swizzling
        if AppConfiguration.useFirebase {
            #if canImport(Firebase)
            FirebaseApp.configure()

            #if DEBUG
            Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
            #else
            Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
            let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
            Crashlytics.crashlytics().setCustomValue(deviceId, forKey: "device_id")
            Crashlytics.crashlytics().log("App launched successfully")
            #endif
            #endif
        }

        // Setup notification handling
        UNUserNotificationCenter.current().delegate = self

        return true
    }

    // MARK: - Notification Handling

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let notificationIdentifier = response.notification.request.identifier

        Analytics.track(event: AnalyticsEvents.notificationOpened, parameters: ["type": notificationIdentifier])

        // Handle specific notification types here
        // Example:
        // let userInfo = response.notification.request.content.userInfo
        // if let action = userInfo["action"] as? String { ... }

        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
}

// MARK: - ProcessInfo Preview Detection

extension ProcessInfo {
    /// Convenience property to detect SwiftUI preview environment
    var isPreview: Bool {
        environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
