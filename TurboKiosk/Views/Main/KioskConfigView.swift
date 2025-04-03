//
//  KioskConfigView.swift
//  TurboKiosk
//
//  Created by Osman Matin on 4/1/25.
//

import SwiftUI

struct KioskConfigView: View {
    @EnvironmentObject var kiosk: KioskStateManager
    @State private var serverURL: String = UserDefaultsManager.getServerURL()
    @State private var showAdvancedSettings = false
    @State private var resetInProgress = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Kiosk Configuration")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Form {
                Section(header: Text("Server Settings")) {
                    TextField("Server URL", text: $serverURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text("Application Settings")) {
                    Toggle("Show Advanced Settings", isOn: $showAdvancedSettings)
                    
                    if showAdvancedSettings {
                        Button("Clear Authentication") {
                            UserDefaultsManager.clearAuthToken()
                        }
                        .foregroundColor(.red)
                        
                        Button("Reset All Settings") {
                            resetInProgress = true
                        }
                        .foregroundColor(.red)
                        .alert(isPresented: $resetInProgress) {
                            Alert(
                                title: Text("Reset All Settings"),
                                message: Text("This will clear all settings and return to login screen. Are you sure?"),
                                primaryButton: .destructive(Text("Reset")) {
                                    UserDefaultsManager.resetAllSettings()
                                    kiosk.isConfiguring = false
                                },
                                secondaryButton: .cancel {
                                    resetInProgress = false
                                }
                            )
                        }
                    }
                }
                
                Section {
                    Button("Save Configuration") {
                        saveConfiguration()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    
                    Button("Cancel") {
                        kiosk.isConfiguring = false
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
            }
        }
        .padding()
    }
    
    private func saveConfiguration() {
        UserDefaultsManager.saveServerURL(serverURL)
        kiosk.isConfiguring = false
    }
}

struct KioskConfigView_Previews: PreviewProvider {
    static var previews: some View {
        KioskConfigView()
            .environmentObject(KioskStateManager())
    }
}
