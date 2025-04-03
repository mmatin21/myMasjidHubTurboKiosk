//
//  KioskStateManager.swift
//  TurboKiosk
//
//  Created by Osman Matin on 4/1/25.
//

import Foundation
import Combine
import UIKit

class KioskStateManager: ObservableObject {
    @Published var isConfiguring = false
    @Published var lastActivityTime = Date()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Check if app is running for the first time
        if UserDefaultsManager.isFirstLaunch() {
            isConfiguring = true
            UserDefaultsManager.setFirstLaunchComplete()
        }
        
        // Setup app activity monitoring
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.lastActivityTime = Date()
            }
            .store(in: &cancellables)
    }
}
