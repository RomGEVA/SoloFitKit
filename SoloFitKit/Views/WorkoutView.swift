import SwiftUI

struct WorkoutView: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geo in
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
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                        .frame(maxWidth: .infinity)
                        .padding(.top, geo.safeAreaInsets.top + geo.size.height * 0.01)
                        .background(Color.clear)
                    
                    // Main content
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: geo.size.height * 0.03) {
                            timerView
                                .frame(maxWidth: .infinity)
                            exerciseInfoView
                                .frame(maxWidth: .infinity)
                                .layoutPriority(1)
                           // animationView
                                .frame(maxWidth: .infinity)
                            controlsView
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, min(geo.size.width * 0.06, 32))
                        .padding(.top, geo.size.height * 0.01)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, geo.safeAreaInsets.bottom + 16)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .navigationBarHidden(true)
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(Color("SecondaryTextColor"))
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color("CardBackgroundColor"))
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                }
                
                Spacer()
                
                // Progress indicator
                VStack(spacing: 4) {
                    Text("\(workoutViewModel.currentExerciseNumber)/\(workoutViewModel.totalExercises)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("SecondaryTextColor"))
                    
                    ProgressView(value: workoutViewModel.workoutProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color("AccentColor")))
                        .frame(width: 100)
                }
                
                Spacer()
                
                Button(action: { workoutViewModel.stopWorkout() }) {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                        .foregroundColor(.red)
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
        }
    }
    
    private var timerView: some View {
        VStack(spacing: 8) {
            Text(workoutViewModel.formattedTimeRemaining)
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(Color("PrimaryTextColor"))
                .monospacedDigit()
                .scaleEffect(workoutViewModel.timeRemaining <= 3 ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: workoutViewModel.timeRemaining)
            
            Text("remaining")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color("SecondaryTextColor"))
            
            if let ex = workoutViewModel.currentExercise {
                let exercisePoints = 10 + max(1, ex.duration / 10)
                HStack(spacing: 8) {
                    Image(systemName: "rosette")
                        .foregroundColor(Color("AccentColor"))
                    Text("+\(exercisePoints) points for this exercise")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("AccentColor"))
                }
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color("CardBackgroundColor")).shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1))
                .frame(maxWidth: 260)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("CardBackgroundColor"))
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
        )
    }
    
    private var exerciseInfoView: some View {
        let ex = workoutViewModel.currentExercise
        let workout = workoutViewModel.workout
        let points: Int = {
            guard let workout = workout else { return 0 }
            let base = workout.exercises.count * 10
            let minutes = max(1, workout.totalDuration / 60) * 5
            let bonus = (workout.mode == .challenge) ? 20 : 0
            return base + minutes + bonus
        }()
        return Group {
            if let ex = ex {
                VStack(spacing: 20) {
                    Text(ex.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color("PrimaryTextColor"))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                        .padding(.bottom, 2)
                        .minimumScaleFactor(0.7)
                        .lineLimit(2)
                    Text(ex.description)
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(Color("SecondaryTextColor"))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 4)
                        .minimumScaleFactor(0.7)
                        .lineLimit(4)

                    if points > 0 {
                        HStack(spacing: 10) {
                            Image(systemName: "rosette")
                                .foregroundColor(Color("AccentColor"))
                            Text("+\(points) points for this workout")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(Color("AccentColor"))
                        }
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color("CardBackgroundColor")).shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2))
                        .frame(maxWidth: 320)
                    }

                    // Tips Card
                    if !ex.tips.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(Color("AccentColor"))
                                    .font(.system(size: 18, weight: .bold))
                                Text("Tips")
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color("AccentColor"))
                            }
                            ForEach(ex.tips, id: \.self) { tip in
                                Text("• \(tip)")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("PrimaryTextColor"))
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color("CardBackgroundColor"))
                                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                        )
                        .frame(maxWidth: 420)
                        .padding(.horizontal, 8)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    // Info Card
                    HStack(spacing: 14) {
                        HStack(spacing: 6) {
                            Image(systemName: ex.category.icon)
                                .foregroundColor(Color(ex.category.color))
                            Text(ex.category.rawValue)
                                .font(.caption)
                                .foregroundColor(Color("SecondaryTextColor"))
                        }
                        HStack(spacing: 6) {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(Color("AccentColor"))
                            Text(ex.difficulty.rawValue)
                                .font(.caption)
                                .foregroundColor(Color("SecondaryTextColor"))
                        }
                        Spacer()
                        Text("\(ex.adjustedDuration)s")
                            .font(.caption)
                            .foregroundColor(Color("SecondaryTextColor"))
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color("CardBackgroundColor"))
                            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                    )
                    .frame(maxWidth: 420)
                    .padding(.horizontal, 8)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))

                    // Voice instruction
                    HStack(spacing: 8) {
                        Image(systemName: "quote.bubble")
                            .foregroundColor(Color("AccentColor"))
                        Text(ex.voiceInstruction)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(Color("PrimaryTextColor").opacity(0.85))
                            .lineLimit(2)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color("CardBackgroundColor"))
                            .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
                    )
                    .frame(maxWidth: 420)
                    .padding(.horizontal, 8)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)
            }
        }
    }
    
//    private var animationView: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 20)
//                .fill(Color("CardBackgroundColor"))
//                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
//            
//            VStack(spacing: 16) {
//                // Placeholder for exercise animation
//                ZStack {
//                    Circle()
//                        .fill(Color("AccentColor").opacity(0.1))
//                        .frame(width: 120, height: 120)
//                    
//                    Image(systemName: "figure.strengthtraining.traditional")
//                        .font(.system(size: 48, weight: .medium))
//                        .foregroundColor(Color("AccentColor"))
//                        .scaleEffect(workoutViewModel.isPaused ? 1.0 : 1.1)
//                        .animation(
//                            .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
//                            value: workoutViewModel.isPaused
//                        )
//                }
//                
//                Text("Exercise animation")
//                    .font(.system(size: 14, weight: .medium, design: .rounded))
//                    .foregroundColor(Color("SecondaryTextColor"))
//            }
//            .padding(.vertical, 40)
//        }
//        .frame(height: 200)
//    }
    
    private var controlsView: some View {
        HStack(spacing: 24) {
            // Previous exercise (disabled for first exercise)
            Button(action: {}) {
                Image(systemName: "backward.fill")
                    .font(.title2)
                    .foregroundColor(workoutViewModel.currentExerciseNumber > 1 ? Color("AccentColor") : Color("SecondaryTextColor").opacity(0.3))
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(Color("CardBackgroundColor"))
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
            }
            .disabled(workoutViewModel.currentExerciseNumber <= 1)
            
            // Play/Pause button
            Button(action: {
                if workoutViewModel.isPaused {
                    workoutViewModel.resumeWorkout()
                } else {
                    workoutViewModel.pauseWorkout()
                }
            }) {
                Image(systemName: workoutViewModel.isPaused ? "play.fill" : "pause.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(Color("AccentColor"))
                            .shadow(color: Color("AccentColor").opacity(0.3), radius: 16, x: 0, y: 8)
                    )
            }
            
            // Next exercise
            Button(action: { workoutViewModel.nextExercise() }) {
                Image(systemName: "forward.fill")
                    .font(.title2)
                    .foregroundColor(Color("AccentColor"))
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(Color("CardBackgroundColor"))
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
            }
        }
        .padding(.bottom, 40)
    }
}

#Preview {
    WorkoutView(workoutViewModel: WorkoutViewModel())
} 
