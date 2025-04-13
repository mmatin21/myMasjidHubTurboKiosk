//
//  SessionManager.swift
//  TurboKiosk
//
//  Created by Osman Matin on 4/1/25.
//

import Foundation
import WebKit
import Turbo
import Combine

class SessionManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var currentURL: URL
    @Published var isProcessingPayment = false
    @Published var paymentAmount: Double = 0
    @Published var paymentFundraiserId: String = ""
    
    // MARK: - Private Properties
    private let session: Session
    private var sessionTimeoutTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Properties
    var navigationDelegate: WKNavigationDelegate? {
        return session.webView.navigationDelegate
    }
    
    var webViewConfiguration: WKWebViewConfiguration {
        return session.webView.configuration
    }
    
    // MARK: - Initialization
    override init() {
        
        // Get base URL from settings or use default
        let baseURLString = UserDefaultsManager.getServerURL()
        let baseURL = URL(string: baseURLString)!
        
        // Initialize with the base URL + kiosk endpoint
        self.currentURL = baseURL.appendingPathComponent(AppConstants.kioskEndpoint)
        
        // Initialize Turbo session
        self.session = Session()
        
        super.init()
        
        // Configure session
        session.delegate = self
        configureWebView()
        
        // Check for existing authentication
        checkExistingAuthentication()
        
        // Set up the JavaScript handler
        setupJavaScriptBridge()
        
        // Start activity monitoring for session timeouts
        startSessionTimeoutMonitoring()
        print("DEBUG: Using server URL: \(currentURL.absoluteString)")


    }
    
    // MARK: - Public Methods
    func loadFundraisers() {
        let baseURLString = UserDefaultsManager.getServerURL()
        let fundraisersURL = URL(string: baseURLString)!.appendingPathComponent("\(AppConstants.kioskEndpoint)/fundraisers")
        self.currentURL = fundraisersURL
    }
    
    func logout() {
        UserDefaultsManager.clearAuthToken()
        isAuthenticated = false
        currentURL = URL(string: UserDefaultsManager.getServerURL())!.appendingPathComponent(AppConstants.kioskEndpoint)
    }
    
    func resetSessionTimeout() {
        // Cancel the current timer
        sessionTimeoutTimer?.invalidate()
        
        // Start a new timer
        sessionTimeoutTimer = Timer.scheduledTimer(
            timeInterval: AppConstants.sessionTimeout,
            target: self,
            selector: #selector(sessionTimedOut),
            userInfo: nil,
            repeats: false
        )
    }
    
    func handlePaymentSuccess() {
        // Reload the current page to show updated fundraising totals
        loadFundraisers()
    }
    
    func handlePaymentFailure() {
        // Handle payment failure if needed
    }
    
    // MARK: - Private Methods
    private func configureWebView() {
        // Set up user agent
        session.webView.customUserAgent = "MasjidKiosk/1.0"
        
        // Disable features not needed for kiosk
        let preferences = session.webView.configuration.preferences
        preferences.javaScriptCanOpenWindowsAutomatically = false
    }
    
    private func checkExistingAuthentication() {
        if let token = UserDefaultsManager.getAuthToken(), !token.isEmpty {
            isAuthenticated = true
            loadFundraisers()
        }
    }
    
    private func setupJavaScriptBridge() {
        // Get the JavaScript bridge code
        let bridgeScript = ScriptInjector.getBridgeScript()
        
        // Create a user script to inject the bridge
        let userScript = WKUserScript(
            source: bridgeScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        
        // Add the script to the web view configuration
        session.webView.configuration.userContentController.addUserScript(userScript)
        
        // Register as a message handler
        session.webView.configuration.userContentController.add(self, name: "kiosk")
    }
    
    private func startSessionTimeoutMonitoring() {
        // Start the initial timer
        resetSessionTimeout()
        
        // Monitor app state changes
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.sessionTimeoutTimer?.invalidate()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.resetSessionTimeout()
            }
            .store(in: &cancellables)
    }
    
    @objc private func sessionTimedOut() {
        // Post notification that session timed out
        NotificationCenter.default.post(
            name: Notification.Name(AppConstants.didTimeoutNotification),
            object: nil
        )
    }
}

// MARK: - SessionDelegate
extension SessionManager: SessionDelegate {
    func sessionWebViewProcessDidTerminate(_ session: Session) {
        // Implement your logic for when the web view process terminates
        print("Web view process terminated.")
    }

    func session(_ session: Session, didProposeVisit proposal: VisitProposal) {
        currentURL = proposal.url
        print("Proposed visit to \(proposal.url)")
    }

    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {
        // Handle failed visits
        if let error = error as? TurboError, case .http(let statusCode) = error {
            if statusCode == 401 {
                // Unauthorized - clear token and go back to login
                logout()
            }
        }
        print("Failed to visit \(String(describing: visitable.visitableURL)) with error: \(error)")
    }
}

// MARK: - WKScriptMessageHandler
extension SessionManager: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "kiosk" else { return }
        
        // Handle messages from JavaScript
        guard let dict = message.body as? [String: Any] else { return }
        guard let action = dict["action"] as? String else { return }
        
        switch action {
        case "authenticate":
            if let token = dict["token"] as? String {
                UserDefaultsManager.saveAuthToken(token)
                isAuthenticated = true
                loadFundraisers()
            }
            
        case "processPayment":
            if let paymentData = dict["paymentData"] as? [String: Any],
               let amount = paymentData["amount"] as? String,
               let fundraiserId = paymentData["fundraiserId"] as? String,
               let doubleAmount = Double(amount) {
                
                paymentAmount = doubleAmount
                paymentFundraiserId = fundraiserId
                isProcessingPayment = true
            }
            
        default:
            print("Unknown action received: \(action)")
        }
    }
}
