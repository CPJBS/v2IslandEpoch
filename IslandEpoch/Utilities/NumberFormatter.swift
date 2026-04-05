//
//  NumberFormatter.swift
//  IslandEpoch
//

import SwiftUI

/// Formats numbers for display, with optional compact notation (1.2K, 3.5M, etc.)
struct GameNumberFormatter {
    static func format(_ value: Int, compact: Bool) -> String {
        guard compact else { return "\(value)" }

        let absValue = abs(value)
        let sign = value < 0 ? "-" : ""

        switch absValue {
        case 0..<1_000:
            return "\(value)"
        case 1_000..<1_000_000:
            let k = Double(absValue) / 1_000.0
            return k >= 100 ? "\(sign)\(Int(k))K" : "\(sign)\(String(format: "%.1f", k))K"
        case 1_000_000..<1_000_000_000:
            let m = Double(absValue) / 1_000_000.0
            return m >= 100 ? "\(sign)\(Int(m))M" : "\(sign)\(String(format: "%.1f", m))M"
        default:
            let b = Double(absValue) / 1_000_000_000.0
            return b >= 100 ? "\(sign)\(Int(b))B" : "\(sign)\(String(format: "%.1f", b))B"
        }
    }
}

/// Environment key for compact numbers setting
private struct CompactNumbersKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var compactNumbers: Bool {
        get { self[CompactNumbersKey.self] }
        set { self[CompactNumbersKey.self] = newValue }
    }
}

extension View {
    func compactNumbers(_ enabled: Bool) -> some View {
        environment(\.compactNumbers, enabled)
    }
}
