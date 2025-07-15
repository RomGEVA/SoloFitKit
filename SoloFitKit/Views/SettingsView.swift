import SwiftUI
import StoreKit

struct SettingsView: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingResetAlert = false
    @State private var showingPrivacyPolicy = false
    @State private var showingAchievements = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("BackgroundColor"),
                        Color("BackgroundColor").opacity(0.9)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Difficulty Level
                        settingsSection(
                            title: "Difficulty Level",
                            content: { difficultySection }
                        )
                        
                        // Workout Duration
                        settingsSection(
                            title: "Workout Duration",
                            content: { durationSection }
                        )
                        
                        // Sound & Vibration
                        settingsSection(
                            title: "Sound & Vibration",
                            content: { soundSection }
                        )
                        
                        // Statistics
                        settingsSection(
                            title: "Statistics",
                            content: { statisticsSection }
                        )
                        
                        // Actions
                        settingsSection(
                            title: "Actions",
                            content: { actionsSection }
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("AccentColor"))
                }
            }
        }
        .alert("Reset Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetData()
            }
        } message: {
            Text("All workout data will be deleted. This action cannot be undone.")
        }
    }
    
    func rateUs() {
        SKStoreReviewController.requestReview()
    }
    
    private var difficultySection: some View {
        VStack(spacing: 12) {
            ForEach(DifficultyLevel.allCases) { difficulty in
                Button(action: {
                    workoutViewModel.updateDifficulty(difficulty)
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(difficulty.rawValue)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color("PrimaryTextColor"))
                            
                            Text(difficultyDescription(for: difficulty))
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(Color("SecondaryTextColor"))
                        }
                        
                        Spacer()
                        
                        if workoutViewModel.settings.difficultyLevel == difficulty {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color("AccentColor"))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(workoutViewModel.settings.difficultyLevel == difficulty ? 
                                  Color("AccentColor").opacity(0.1) : Color("CardBackgroundColor"))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var durationSection: some View {
        VStack(spacing: 12) {
            ForEach(WorkoutDuration.allCases) { duration in
                Button(action: {
                    workoutViewModel.updateWorkoutDuration(duration)
                }) {
                    HStack {
                        Text(duration.displayName)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color("PrimaryTextColor"))
                        
                        Spacer()
                        
                        if workoutViewModel.settings.workoutDuration == duration {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(Color("AccentColor"))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(workoutViewModel.settings.workoutDuration == duration ? 
                                  Color("AccentColor").opacity(0.1) : Color("CardBackgroundColor"))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private var soundSection: some View {
        VStack(spacing: 16) {
            // Sound toggle
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Voice Prompts")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("PrimaryTextColor"))
                    
                    Text("Voice instructions and sounds")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color("SecondaryTextColor"))
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { workoutViewModel.settings.soundEnabled },
                    set: { _ in workoutViewModel.toggleSound() }
                ))
                .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
            }
        }
    }
    
    private var statisticsSection: some View {
        VStack(spacing: 16) {
            StatRow(
                title: "Workouts Completed",
                value: "\(workoutViewModel.settings.completedWorkouts.count)",
                icon: "figure.run"
            )
            
            StatRow(
                title: "Total Time",
                value: formatTotalTime(),
                icon: "clock.fill"
            )
            
            StatRow(
                title: "Last Workout",
                value: formatLastWorkout(),
                icon: "calendar"
            )
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: 16) {
            Button(action: { showingAchievements = true }) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color("AccentColor"))
                    Text("Achievements")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("PrimaryTextColor"))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color("SecondaryTextColor"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color("CardBackgroundColor")))
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showingAchievements) {
                AchievementsView(workoutViewModel: workoutViewModel)
            }
            
            Button(action: { showingResetAlert = true }) {
                HStack {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                    
                    Text("Reset Data")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.red)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.1))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                if let url = URL(string: "https://www.termsfeed.com/live/036d4b53-9c0d-4861-a902-418b83440a5e") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(Color("AccentColor"))
                    Text("Privacy Policy")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("PrimaryTextColor"))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color("SecondaryTextColor"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color("CardBackgroundColor")))
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: rateUs) {
                HStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.yellow)
                    
                    Text("Rate App")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("PrimaryTextColor"))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color("SecondaryTextColor"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("CardBackgroundColor"))
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color("PrimaryTextColor"))
            
            content()
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("CardBackgroundColor"))
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                )
        }
    }
    
    private func difficultyDescription(for difficulty: DifficultyLevel) -> String {
        switch difficulty {
        case .beginner: return "For beginners, easy exercises"
        case .intermediate: return "Intermediate, balanced load"
        case .advanced: return "For experienced, intense workouts"
        }
    }
    
    private func formatTotalTime() -> String {
        let totalMinutes = workoutViewModel.settings.completedWorkouts.reduce(0) { $0 + $1.duration } / 60
        if totalMinutes >= 60 {
            let hours = totalMinutes / 60
            let minutes = totalMinutes % 60
            return "\(hours)h \(minutes)m"
        } else {
            return "\(totalMinutes)m"
        }
    }
    
    private func formatLastWorkout() -> String {
        guard let lastWorkout = workoutViewModel.settings.completedWorkouts.last else {
            return "No data"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: lastWorkout.startDate)
    }
    
    private func resetData() {
        workoutViewModel.settings.completedWorkouts.removeAll()
        UserDefaults.standard.saveSettings(workoutViewModel.settings)
    }
    
    private func rateApp() {
        // In a real app, this would open the App Store
        if let url = URL(string: "https://apps.apple.com/app/id123456789") {
            UIApplication.shared.open(url)
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("AccentColor"))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color("AccentColor").opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color("SecondaryTextColor"))
                
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color("PrimaryTextColor"))
            }
            
            Spacer()
        }
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color("PrimaryTextColor"))
                    
                    Text("SoloFit respects your privacy. This app:")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color("PrimaryTextColor"))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        PolicyPoint(text: "Does not collect personal data")
                        PolicyPoint(text: "Does not require registration")
                        PolicyPoint(text: "Works fully offline")
                        PolicyPoint(text: "Does not share data with third parties")
                        PolicyPoint(text: "Stores data only on your device")
                    }
                    
                    Text("All workout data is stored locally on your device and can be deleted at any time via the app settings.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color("SecondaryTextColor"))
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("AccentColor"))
                }
            }
        }
    }
}

struct PolicyPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("AccentColor"))
            
            Text(text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color("PrimaryTextColor"))
        }
    }
}

#Preview {
    SettingsView(workoutViewModel: WorkoutViewModel())
} 
