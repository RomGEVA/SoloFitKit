import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @ObservedObject var workoutViewModel: WorkoutViewModel
    @State private var page = 0
    
    var body: some View {
        TabView(selection: $page) {
            // 1. Welcome
            VStack(spacing: 32) {
                Spacer()
                Image(systemName: "figure.walk")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color("AccentColor"))
                Text("Welcome to SoloFit")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color("PrimaryTextColor"))
                Text("Minimalistic offline fitness app for your body and mind. No registration, no ads, just results.")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(Color("SecondaryTextColor"))
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .tag(0)
            .padding()
            // 2. Features + Start
            VStack(spacing: 28) {
                Spacer()
                Image(systemName: "star.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(Color("AccentColor"))
                Text("Track Progress & Earn Achievements")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color("PrimaryTextColor"))
                VStack(alignment: .leading, spacing: 10) {
                    Label("Built-in workouts by category", systemImage: "list.bullet")
                    Label("Timer, voice prompts, haptics", systemImage: "timer")
                    Label("History, charts, streaks, badges", systemImage: "chart.bar.xaxis")
                    Label("All data offline, privacy first", systemImage: "lock.fill")
                }
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(Color("SecondaryTextColor"))
                Spacer()
                Button(action: {
                    hasSeenOnboarding = true
                }) {
                    Text("Start SoloFit")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color("AccentColor")))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .tag(1)
            .padding()
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .background(Color("BackgroundColor").ignoresSafeArea())
    }
}

#Preview {
    OnboardingView(workoutViewModel: WorkoutViewModel())
} 
