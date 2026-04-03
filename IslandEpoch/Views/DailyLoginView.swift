//
//  DailyLoginView.swift
//  IslandEpoch
//

import SwiftUI

struct DailyLoginReward {
    let day: Int
    let gold: Int
    let gems: Int
}

struct DailyLoginView: View {
    @EnvironmentObject var vm: GameViewModel
    let onClaim: (Int, Int) -> Void  // (gold, gems) to claim
    @Environment(\.dismiss) var dismiss

    let rewards: [DailyLoginReward] = [
        DailyLoginReward(day: 1, gold: 50, gems: 1),
        DailyLoginReward(day: 2, gold: 100, gems: 0),
        DailyLoginReward(day: 3, gold: 75, gems: 2),
        DailyLoginReward(day: 4, gold: 150, gems: 0),
        DailyLoginReward(day: 5, gold: 100, gems: 2),
        DailyLoginReward(day: 6, gold: 200, gems: 0),
        DailyLoginReward(day: 7, gold: 150, gems: 5),
    ]

    private var streak: Int {
        vm.gameState.dailyLogin.currentStreak
    }

    /// The day index (1-7) the player is on within the weekly cycle.
    private var currentDay: Int {
        // If streak is 0, we're on day 1 (first claim)
        // Otherwise, calculate position in 7-day cycle
        if streak == 0 {
            return 1
        }
        let dayInCycle = (streak % 7)
        return dayInCycle == 0 ? 7 : dayInCycle
    }

    private var canClaimToday: Bool {
        guard let last = vm.gameState.dailyLogin.lastClaimDate else { return true }
        return !Calendar.current.isDateInToday(last)
    }

    private func dayState(_ day: Int) -> DayState {
        if day < currentDay || (day == currentDay && !canClaimToday) {
            return .claimed
        } else if day == currentDay && canClaimToday {
            return .today
        } else {
            return .locked
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 40))
                        .foregroundStyle(.orange)

                    Text("Daily Bonus")
                        .font(.largeTitle)
                        .bold()

                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("\(max(streak, 1)) day streak")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 16)

                // 7-day reward row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(rewards, id: \.day) { reward in
                            DayCard(
                                reward: reward,
                                state: dayState(reward.day)
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }

                // Claim button
                if canClaimToday {
                    let todayReward = rewards[(currentDay - 1).clamped(to: 0..<rewards.count)]
                    VStack(spacing: 6) {
                        Button {
                            onClaim(todayReward.gold, todayReward.gems)
                            dismiss()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "gift.fill")
                                Text("Claim Day \(currentDay)!")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        .padding(.horizontal, 32)

                        Text("\(todayReward.gold) gold\(todayReward.gems > 0 ? " + \(todayReward.gems) gems" : "")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("Come back tomorrow!")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Day State

private enum DayState {
    case claimed
    case today
    case locked
}

// MARK: - Day Card

private struct DayCard: View {
    let reward: DailyLoginReward
    let state: DayState

    @State private var pulse = false

    var body: some View {
        VStack(spacing: 6) {
            Text("Day \(reward.day)")
                .font(.caption2)
                .bold()
                .foregroundStyle(state == .today ? .white : .secondary)

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardBackground)
                    .frame(width: 72, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(cardBorder, lineWidth: state == .today ? 2 : 1)
                    )
                    .scaleEffect(state == .today && pulse ? 1.05 : 1.0)

                switch state {
                case .claimed:
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)

                case .today:
                    VStack(spacing: 4) {
                        goldLabel
                        gemsLabel
                    }

                case .locked:
                    VStack(spacing: 4) {
                        goldLabel
                        gemsLabel
                    }
                    .opacity(0.4)
                }
            }
        }
        .onAppear {
            if state == .today {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
        }
    }

    @ViewBuilder
    private var goldLabel: some View {
        HStack(spacing: 2) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.caption2)
                .foregroundStyle(.yellow)
            Text("\(reward.gold)")
                .font(.caption)
                .bold()
                .foregroundStyle(state == .today ? .white : .primary)
        }
    }

    @ViewBuilder
    private var gemsLabel: some View {
        if reward.gems > 0 {
            HStack(spacing: 2) {
                Image(systemName: "diamond.fill")
                    .font(.caption2)
                    .foregroundStyle(.purple)
                Text("\(reward.gems)")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(state == .today ? .white : .primary)
            }
        }
    }

    private var cardBackground: Color {
        switch state {
        case .claimed: return Color.gray.opacity(0.3)
        case .today: return .orange
        case .locked: return Color.gray.opacity(0.15)
        }
    }

    private var cardBorder: Color {
        switch state {
        case .claimed: return .green.opacity(0.3)
        case .today: return .orange
        case .locked: return Color.gray.opacity(0.4)
        }
    }
}

// MARK: - Clamped Helper

private extension Int {
    func clamped(to range: Range<Int>) -> Int {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound - 1)
    }
}

#Preview {
    DailyLoginView(onClaim: { gold, gems in
        print("Claimed \(gold) gold, \(gems) gems")
    })
    .environmentObject(GameViewModel())
}
