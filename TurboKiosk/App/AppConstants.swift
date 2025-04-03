//
//  AppConstants.swift
//  TurboKiosk
//
//  Created by Osman Matin on 4/1/25.
//
import Foundation

enum AppConstants {
    // API and backend configuration
    static let baseURL = "http://localhost:3000"
    static let kioskEndpoint = "/kiosk"
    
    // Authentication
    static let tokenStorageKey = "kioskToken"
    static let masjidIdStorageKey = "masjidId"
    
    // Timeouts
    static let sessionTimeout = 300.0 // 5 minutes of inactivity before returning to login
    static let paymentTimeout = 120.0 // 2 minutes to complete payment
    
    // Stripe
    static let stripePublishableKey = "pk_test_51QulGJ08IOmeL0SEp5Gyogr6u5DVs0oxmk6ShFUqd4W19uhQuINLrLaKZOo0XDzA42DtnHwpf56n601R7yzrd4wF004lfWd8Pn"
    
    // Feature flags
    static let enableDebugLogging = true
    static let allowCardEntryFallback = true
    
    // Notification Names
    static let didAuthenticateNotification = "com.masjidkiosk.didAuthenticate"
    static let didTimeoutNotification = "com.masjidkiosk.didTimeout"
    static let didProcessPaymentNotification = "com.masjidkiosk.didProcessPayment"
}
