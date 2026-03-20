//
//  MetricKitSubscriber.swift
//  MyApp
//
//  MetricKit subscriber for production crash, hang, and performance diagnostics.
//

import MetricKit

final class AppMetricSubscriber: NSObject, MXMetricManagerSubscriber {
    static let shared = AppMetricSubscriber()

    private override init() {
        super.init()
    }

    func register() {
        MXMetricManager.shared.add(self)
    }

    func unregister() {
        MXMetricManager.shared.remove(self)
    }

    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            if let launchMetrics = payload.applicationLaunchMetrics {
                let resumeTime = launchMetrics.histogrammedResumeTime.bucketEnumerator
                Analytics.track(event: "metric.launch", parameters: [
                    "type": "periodic",
                    "resume_buckets": "\(resumeTime)"
                ])
            }

            if let hangMetrics = payload.applicationResponsivenessMetrics {
                Analytics.track(event: "metric.hangs", parameters: [
                    "hang_time": "\(hangMetrics.histogrammedApplicationHangTime)"
                ])
            }
        }
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            if let crashDiagnostics = payload.crashDiagnostics {
                for crash in crashDiagnostics {
                    Analytics.track(event: "metric.crash", parameters: [
                        "signal": "\(crash.signal)",
                        "exception_type": "\(crash.exceptionType ?? 0)"
                    ])
                }
            }

            if let hangDiagnostics = payload.hangDiagnostics {
                Analytics.track(event: "metric.hang_diagnostic", parameters: [
                    "count": "\(hangDiagnostics.count)"
                ])
            }
        }
    }
}
