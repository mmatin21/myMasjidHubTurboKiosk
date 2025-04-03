//
//  FormatterHelper.swift
//  TurboKiosk
//
//  Created by Osman Matin on 4/1/25.
//

import Foundation

class CurrencyFormatter {
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    static func format(_ amount: Double) -> String {
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}
