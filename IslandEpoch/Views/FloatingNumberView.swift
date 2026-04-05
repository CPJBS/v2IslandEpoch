//
//  FloatingNumberView.swift
//  IslandEpoch
//
//  Animated "+X" numbers that float upward and fade out when resources change.
//

import SwiftUI
import Combine

struct FloatingNumber: Identifiable {
    let id = UUID()
    let text: String
    let color: Color
    let startTime: Date
}

struct FloatingNumberOverlay: View {
    let numbers: [FloatingNumber]

    var body: some View {
        ZStack {
            ForEach(numbers) { number in
                FloatingNumberBubble(number: number)
            }
        }
    }
}

private struct FloatingNumberBubble: View {
    let number: FloatingNumber
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1.0

    var body: some View {
        Text(number.text)
            .font(.caption.bold())
            .foregroundColor(number.color)
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) {
                    offset = -40
                    opacity = 0
                }
            }
    }
}

/// Tracks resource changes between ticks and emits floating numbers
@MainActor
class ResourceChangeTracker: ObservableObject {
    @Published var floatingNumbers: [FloatingNumber] = []
    private var previousGold: Int = 0
    private var previousInventory: [ResourceType: Int] = [:]
    private var isFirstTick = true

    func update(gold: Int, inventory: [ResourceType: Int]) {
        // Skip the first tick to avoid showing initial values as changes
        guard !isFirstTick else {
            previousGold = gold
            previousInventory = inventory
            isFirstTick = false
            return
        }

        var newNumbers: [FloatingNumber] = []

        // Gold change
        let goldDiff = gold - previousGold
        if goldDiff > 0 {
            newNumbers.append(FloatingNumber(text: "+\(goldDiff) gold", color: .yellow, startTime: Date()))
        }

        // Resource changes (only show positive gains to avoid clutter)
        for (resource, amount) in inventory {
            let prev = previousInventory[resource] ?? 0
            let diff = amount - prev
            if diff > 0 {
                newNumbers.append(FloatingNumber(text: "+\(diff) \(resource.displayName)", color: resourceColor(for: resource), startTime: Date()))
            }
        }

        previousGold = gold
        previousInventory = inventory

        if !newNumbers.isEmpty {
            floatingNumbers.append(contentsOf: newNumbers)
            // Clean up old numbers after animation completes
            let ids = newNumbers.map { $0.id }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.floatingNumbers.removeAll { ids.contains($0.id) }
            }
        }
    }

    private func resourceColor(for resource: ResourceType) -> Color {
        switch resource.category {
        case .food: return .green
        case .material: return .brown
        case .ore: return .gray
        case .knowledge: return .purple
        }
    }
}
