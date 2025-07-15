import SwiftUI

struct MainView: View {
    @StateObject private var workoutViewModel = WorkoutViewModel()
    @State private var showingSettings = false
    @State private var showingAchievements = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("BackgroundColor"),
                        Color("BackgroundColor").opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Categories grid
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                            ForEach(WorkoutCategory.allCases) { category in
                                CategoryCard(category: category) {
                                    workoutViewModel.startWorkout(for: category)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Кнопка истории и прогресса
                        NavigationLink(destination: HistoryView(workoutViewModel: workoutViewModel)) {
                            HStack {
                                Image(systemName: "chart.bar.xaxis")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(Color("AccentColor"))
                                Text("History & Progress")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color("AccentColor"))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color("SecondaryTextColor"))
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color("CardBackgroundColor"))
                                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 32)
                        }
                        // Кнопка ачивок
                        Button(action: { showingAchievements = true }) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(Color("AccentColor"))
                                Text("Achievements")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color("AccentColor"))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color("SecondaryTextColor"))
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color("CardBackgroundColor"))
                                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 12)
                        }
                        .sheet(isPresented: $showingAchievements) {
                            AchievementsView(workoutViewModel: workoutViewModel)
                        }
                        // Плейсхолдер если ачивок нет
                        if workoutViewModel.settings.achievements.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "star")
                                    .font(.system(size: 40, weight: .regular))
                                    .foregroundColor(Color("SecondaryTextColor").opacity(0.5))
                                Text("No achievements yet")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("SecondaryTextColor").opacity(0.7))
                                Text("Complete workouts and challenges to earn badges!")
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundColor(Color("SecondaryTextColor").opacity(0.6))
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(workoutViewModel: workoutViewModel)
        }
        .fullScreenCover(isPresented: $workoutViewModel.isWorkoutActive) {
            WorkoutView(workoutViewModel: workoutViewModel)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("SoloFit")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color("PrimaryTextColor"))
                    
                    // Индикатор уровня и времени
                    HStack(spacing: 12) {
                        Label(
                            workoutViewModel.settings.difficultyLevel.rawValue,
                            systemImage: "bolt.fill"
                        )
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("AccentColor"))
                        .labelStyle(.titleOnly)
                        
                        Divider().frame(height: 16)
                        
                        Label(
                            "\(workoutViewModel.settings.workoutDuration.rawValue) min",
                            systemImage: "clock"
                        )
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("AccentColor"))
                        .labelStyle(.titleOnly)
                    }
                }
                
                Spacer()
                
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(Color("AccentColor"))
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color("CardBackgroundColor"))
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Stats cards
            HStack(spacing: 12) {
                StatCard(
                    title: "Workouts",
                    value: "\(workoutViewModel.settings.completedWorkouts.count)",
                    icon: "figure.run"
                )
                
                StatCard(
                    title: "Total Time",
                    value: formatTotalTime(),
                    icon: "clock.fill"
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
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
}

struct CategoryCard: View {
    let category: WorkoutCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(category.color).opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(Color(category.color))
                }
                
                // Text
                VStack(spacing: 4) {
                    Text(category.rawValue)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("PrimaryTextColor"))
                        .multilineTextAlignment(.center)
                    
                    Text("5-10 exercises")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color("SecondaryTextColor"))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("CardBackgroundColor"))
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color("AccentColor"))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color("AccentColor").opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color("PrimaryTextColor"))
                
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color("SecondaryTextColor"))
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CardBackgroundColor"))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    MainView()
} 