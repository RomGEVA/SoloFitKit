import Foundation

extension UserDefaults {
    
    private enum Keys {
        static let userSettings = "userSettings"
        static let achievements = "achievements"
    }
    
    func saveSettings(_ settings: UserSettings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            set(encoded, forKey: Keys.userSettings)
        }
    }
    
    func loadSettings() -> UserSettings {
        guard let data = data(forKey: Keys.userSettings),
              let settings = try? JSONDecoder().decode(UserSettings.self, from: data) else {
            return UserSettings.default
        }
        return settings
    }
    
    func saveAchievements(_ achievements: [Achievement]) {
        if let encoded = try? JSONEncoder().encode(achievements) {
            set(encoded, forKey: Keys.achievements)
        }
    }
    
    func loadAchievements() -> [Achievement] {
        guard let data = data(forKey: Keys.achievements),
              let achievements = try? JSONDecoder().decode([Achievement].self, from: data) else {
            return []
        }
        return achievements
    }
} 