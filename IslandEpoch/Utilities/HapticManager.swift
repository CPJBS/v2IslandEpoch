//
//  HapticManager.swift
//  IslandEpoch
//

#if canImport(UIKit)
import UIKit
#endif

struct HapticManager {
    static func success() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }

    static func warning() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        #endif
    }

    static func error() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
    }

    static func selection() {
        #if canImport(UIKit)
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        #endif
    }

    static func impact(style: String = "medium") {
        #if canImport(UIKit)
        let uiStyle: UIImpactFeedbackGenerator.FeedbackStyle
        switch style {
        case "light": uiStyle = .light
        case "heavy": uiStyle = .heavy
        default: uiStyle = .medium
        }
        let generator = UIImpactFeedbackGenerator(style: uiStyle)
        generator.impactOccurred()
        #endif
    }
}
