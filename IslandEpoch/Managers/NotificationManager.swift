//
//  NotificationManager.swift
//  IslandEpoch
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func scheduleConstructionComplete(buildingName: String, islandName: String, completionDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Construction Complete!"
        content.body = "Your \(buildingName) is ready on \(islandName)!"
        content.sound = .default

        let timeInterval = completionDate.timeIntervalSinceNow
        guard timeInterval > 0 else { return }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "construction_\(buildingName)_\(islandName)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func scheduleResearchComplete(researchName: String, completionDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Research Complete!"
        content.body = "\(researchName) is complete! New possibilities await."
        content.sound = .default

        let timeInterval = completionDate.timeIntervalSinceNow
        guard timeInterval > 0 else { return }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "research_\(researchName)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func scheduleIdleReminders() {
        // 2-hour reminder
        let content2h = UNMutableNotificationContent()
        content2h.title = "Your Islands Miss You!"
        content2h.body = "Come check on your settlers."
        content2h.sound = .default

        let trigger2h = UNTimeIntervalNotificationTrigger(timeInterval: 7200, repeats: false)
        let request2h = UNNotificationRequest(identifier: "idle_2h", content: content2h, trigger: trigger2h)
        UNUserNotificationCenter.current().add(request2h)

        // 8-hour reminder
        let content8h = UNMutableNotificationContent()
        content8h.title = "Your Settlers Have Been Working Hard!"
        content8h.body = "Come see what they've gathered."
        content8h.sound = .default

        let trigger8h = UNTimeIntervalNotificationTrigger(timeInterval: 28800, repeats: false)
        let request8h = UNNotificationRequest(identifier: "idle_8h", content: content8h, trigger: trigger8h)
        UNUserNotificationCenter.current().add(request8h)
    }

    func scheduleAllPending(gameState: GameState) {
        cancelAll()

        // Schedule construction completions
        for island in gameState.islands {
            for building in island.buildings.compactMap({ $0 }) {
                if building.isUnderConstruction, let start = building.constructionStartTime {
                    let completionDate = start.addingTimeInterval(building.constructionDuration)
                    scheduleConstructionComplete(buildingName: building.type.name, islandName: island.name, completionDate: completionDate)
                }
            }
        }

        // Schedule research completion
        if let research = gameState.activeResearch {
            let completionDate = research.startTime.addingTimeInterval(research.duration)
            if let researchType = ResearchType.all.first(where: { $0.id == research.researchId }) {
                scheduleResearchComplete(researchName: researchType.name, completionDate: completionDate)
            }
        }

        // Schedule idle reminders
        scheduleIdleReminders()
    }
}
