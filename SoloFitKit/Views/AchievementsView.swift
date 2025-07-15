import SwiftUI

struct AchievementsView: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    
    private var achievements: [Achievement] {
        workoutViewModel.settings.achievements.sorted { $0.dateEarned > $1.dateEarned }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let maxPoints = [100, 500, 1000].first(where: { $0 > workoutViewModel.settings.totalPoints }) {
                    VStack(spacing: 6) {
                        Text("Points: \(workoutViewModel.settings.totalPoints)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color("AccentColor"))
                        Text("\(maxPoints - workoutViewModel.settings.totalPoints) points to next badge")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(Color("SecondaryTextColor"))
                    }
                    .padding(.top, 16)
                } else {
                    Text("Points: \(workoutViewModel.settings.totalPoints)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color("AccentColor"))
                        .padding(.top, 16)
                }
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 20)], spacing: 20) {
                        ForEach(achievements) { achievement in
                            AchievementCard(achievement: achievement)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Achievements")
            .background(Color("BackgroundColor").ignoresSafeArea())
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: achievement.type.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(Color("AccentColor"))
                .shadow(color: Color("AccentColor").opacity(0.18), radius: 8, x: 0, y: 4)
            Text(achievement.type.title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(Color("PrimaryTextColor"))
                .multilineTextAlignment(.center)
            Text(achievement.type.description)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(Color("SecondaryTextColor"))
                .multilineTextAlignment(.center)
            Text(achievement.dateEarned, style: .date)
                .font(.caption2)
                .foregroundColor(Color("SecondaryTextColor").opacity(0.7))
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 180)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color("CardBackgroundColor"))
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color("AccentColor").opacity(0.08), lineWidth: 1)
        )
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: achievement.id)
    }
}

#Preview {
    AchievementsView(workoutViewModel: WorkoutViewModel())
} 
