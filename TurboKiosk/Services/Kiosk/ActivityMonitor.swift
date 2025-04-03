//
//  ActivityMonitor.swift
//  TurboKiosk
//
//  Created by Osman Matin on 4/1/25.
//

import Foundation
import UIKit
import Combine

class ActivityMonitor {
    static let shared = ActivityMonitor()
    
    private var timer: Timer?
    private var lastActivity = Date()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupMonitoring()
    }
    
    private func setupMonitoring() {
        // Track app becoming active
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.recordActivity()
            }
            .store(in: &cancellables)
        
        // Start the timer
        startTimer()
    }
    
    func recordActivity() {
        lastActivity = Date()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.checkInactivity()
        }
    }
    
    private func checkInactivity() {
        let timeElapsed = Date().timeIntervalSince(lastActivity)
        if timeElapsed > AppConstants.sessionTimeout {
            // Post timeout notification
            NotificationCenter.default.post(
                name: Notification.Name(AppConstants.didTimeoutNotification),
                object: nil
            )
        }
    }
}
