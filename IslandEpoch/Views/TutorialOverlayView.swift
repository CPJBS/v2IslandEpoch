//
//  TutorialOverlayView.swift
//  IslandEpoch
//

import SwiftUI

struct TutorialOverlayView: View {
    @EnvironmentObject var vm: GameViewModel
    @Binding var tutorialStep: Int

    var body: some View {
        ZStack {
            // Semi-transparent background — lighter during action steps so the map is visible
            // During action steps, allow taps to pass through to the game
            Color.black.opacity(isActionStep ? 0.3 : 0.6)
                .ignoresSafeArea()
                .allowsHitTesting(!isActionStep)

            VStack(spacing: 20) {
                Spacer()

                // Tutorial card
                VStack(spacing: 16) {
                    // Step indicator
                    Text("Step \(tutorialStep) of 10")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    // Step content
                    Text(stepTitle)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)

                    Text(stepDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    // Action button
                    if isActionStep {
                        Text("Tap the highlighted area")
                            .font(.callout)
                            .foregroundColor(.orange)
                    } else {
                        Button(stepButtonText) {
                            advanceStep()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(24)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .padding(.horizontal, 32)
                .allowsHitTesting(!isActionStep)

                // Skip button
                Button("Skip Tutorial") {
                    vm.awardGems(5, source: "tutorial_skip")
                    tutorialStep = -1
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 40)
            }
        }
        .animation(.easeInOut, value: tutorialStep)
    }

    var stepTitle: String {
        switch tutorialStep {
        case 1: return "Welcome to Island Epoch!"
        case 2: return "Your Island"
        case 3: return "Build a Forager"
        case 4: return "Assign Workers"
        case 5: return "Watch Production"
        case 6: return "Build a Forester"
        case 7: return "Research"
        case 8: return "Construction Timers"
        case 9: return "Storage Limits"
        case 10: return "You're Ready!"
        default: return ""
        }
    }

    var stepDescription: String {
        switch tutorialStep {
        case 1: return "You lead a small band of settlers on an uncharted island. Build a thriving civilization across the ages!"
        case 2: return "This is your island. Each slot can hold one building. Tap an empty slot to start building."
        case 3: return "Build a Forager to gather berries. Your people need food to stay productive!"
        case 4: return "Assign workers to your buildings. More workers means higher productivity."
        case 5: return "Resources are produced every second. Watch your berries grow!"
        case 6: return "Build a Forester to gather wood. You'll need it for research."
        case 7: return "Research new technologies to unlock buildings and advance through epochs."
        case 8: return "Buildings take time to construct. Check back when they're ready, or speed them up with gems."
        case 9: return "Resources are limited by storage. Upgrade storage to hold more and earn while you're away."
        case 10: return "Explore, build, research, and lead your people through 10 epochs of history!"
        default: return ""
        }
    }

    var isActionStep: Bool {
        [3, 4, 6, 7].contains(tutorialStep)
    }

    var stepButtonText: String {
        tutorialStep == 10 ? "Start Playing!" : "Next"
    }

    func advanceStep() {
        if tutorialStep >= 10 {
            vm.awardGems(10, source: "tutorial_complete")
            tutorialStep = -1
        } else {
            tutorialStep += 1
        }
    }
}
