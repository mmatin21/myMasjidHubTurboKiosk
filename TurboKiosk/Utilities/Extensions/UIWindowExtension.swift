//
//  UIWindowExtension.swift
//  TurboKiosk
//
//  Created by Osman Matin on 4/13/25.
//
import UIKit

extension UIWindow {
    static var key: UIWindow? {
        // iOS 15+ way (preferred)
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return nil
        }
        return window
    }
    
    static var keyViewController: UIViewController? {
        return Self.key?.rootViewController
    }
}
