//
//  LoginView.swift
//  TurboKiosk
//
//  Created by Osman Matin on 4/1/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var kiosk: KioskStateManager
    
    @State private var masjidId: String = ""
    @State private var password: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    // Tap counter for accessing config screen
    @State private var configTapCount = 0
    @State private var lastTapTime: Date? = nil
    
    var body: some View {
        VStack(spacing: 30) {
            // Logo and title
            Image(systemName: "building.columns.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .onTapGesture {
                    // Check if tap is within 2 seconds of last tap
                    if let lastTime = lastTapTime, Date().timeIntervalSince(lastTime) < 2.0 {
                        configTapCount += 1
                        
                        // After 5 quick taps, show config screen
                        if configTapCount >= 5 {
                            kiosk.isConfiguring = true
                            configTapCount = 0
                        }
                    } else {
                        // Reset counter if taps are too far apart
                        configTapCount = 1
                    }
                    lastTapTime = Date()
                }
            
            Text("Masjid Donation Kiosk")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Error message if authentication fails
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            // Login form
            VStack(spacing: 20) {
                TextField("Masjid ID", text: $masjidId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title3)
                    .padding(.horizontal)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title3)
                    .padding(.horizontal)
                
                Button(action: {
                    authenticateMasjid()
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    } else {
                        Text("Sign In")
                            .fontWeight(.semibold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(isLoading || masjidId.isEmpty || password.isEmpty)
            }
            .padding(.horizontal, 50)
        }
        .padding()
    }
    
    private func authenticateMasjid() {
        isLoading = true
        errorMessage = nil
        
        // Call the authentication service
        AuthService.authenticate(masjidId: masjidId, password: password) { result in
            isLoading = false
            
            switch result {
            case .success(let token):
                // Store the token and set authenticated state
                UserDefaultsManager.saveAuthToken(token)
                UserDefaultsManager.saveMasjidId(masjidId)
                sessionManager.isAuthenticated = true
                sessionManager.loadFundraisers()
                
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(SessionManager())
            .environmentObject(KioskStateManager())
    }
}
