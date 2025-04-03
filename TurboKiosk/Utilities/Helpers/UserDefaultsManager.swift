//
//  UserDefaultsManager.swift
//  TurboKiosk
//
//  Created by Osman Matin on 4/1/25.
//

import Foundation

class UserDefaultsManager {
    private static let defaults = UserDefaults.standard
    
    private enum Keys {
        static let authToken = "authToken"
        static let masjidId = "masjidId"
        static let serverURL = "serverURL"
        static let isFirstLaunch = "isFirstLaunch"
    }
    
    // MARK: - Auth Token
    
    static func saveAuthToken(_ token: String) {
        defaults.set(token, forKey: Keys.authToken)
    }
    
    static func getAuthToken() -> String? {
        return defaults.string(forKey: Keys.authToken)
    }
    
    static func clearAuthToken() {
        defaults.removeObject(forKey: Keys.authToken)
    }
    
    // MARK: - Masjid ID
    
    static func saveMasjidId(_ id: String) {
        defaults.set(id, forKey: Keys.masjidId)
    }
    
    static func getMasjidId() -> String? {
        return defaults.string(forKey: Keys.masjidId)
    }
    
    // MARK: - Server URL
    
    static func saveServerURL(_ url: String) {
        defaults.set(url, forKey: Keys.serverURL)
    }
    
    static func getServerURL() -> String {
        return defaults.string(forKey: Keys.serverURL) ?? AppConstants.baseURL
    }
    
    // MARK: - First Launch
    
    static func isFirstLaunch() -> Bool {
        return !defaults.bool(forKey: Keys.isFirstLaunch)
    }
    
    static func setFirstLaunchComplete() {
        defaults.set(true, forKey: Keys.isFirstLaunch)
    }
    
    // MARK: - Reset All
    
    static func resetAllSettings() {
        let preserveKeys = [Keys.isFirstLaunch]
        
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            if !preserveKeys.contains(key) {
                defaults.removeObject(forKey: key)
            }
        }
        
        // Set default values
        defaults.set(AppConstants.baseURL, forKey: Keys.serverURL)
    }
}
