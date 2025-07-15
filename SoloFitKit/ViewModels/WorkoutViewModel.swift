import Foundation
import Combine
import AVFoundation
import UIKit

class WorkoutViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentExercise: Exercise?
    @Published var currentExerciseIndex: Int = 0
    @Published var timeRemaining: Int = 0
    @Published var isWorkoutActive: Bool = false
    @Published var isPaused: Bool = false
    @Published var workoutProgress: Double = 0.0
    @Published var totalWorkoutTime: Int = 0
    @Published var elapsedTime: Int = 0
    
    // MARK: - Private Properties
    var workout: Workout?
    private var timer: Timer?
    private var audioPlayer: AVAudioPlayer?
    private var speechSynthesizer = AVSpeechSynthesizer()
    
    // MARK: - Settings
    @Published var settings: UserSettings {
        didSet {
            saveSettings()
        }
    }
    
    // MARK: - Initialization
    init() {
        self.settings = UserDefaults.standard.loadSettings()
    }
    
    // MARK: - Workout Management
    func startWorkout(for category: WorkoutCategory) {
        let workout = Workout(category: category, difficulty: settings.difficultyLevel, duration: settings.workoutDuration)
        self.workout = workout
        self.currentExerciseIndex = 0
        self.currentExercise = workout.exercises.first
        self.timeRemaining = currentExercise?.adjustedDuration ?? 0
        self.totalWorkoutTime = workout.totalDuration
        self.elapsedTime = 0
        self.workoutProgress = 0.0
        self.isWorkoutActive = true
        self.isPaused = false
        
        startTimer()
        speakInstruction()
        
        if settings.vibrationEnabled {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    func pauseWorkout() {
        isPaused = true
        timer?.invalidate()
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
    
    func resumeWorkout() {
        isPaused = false
        startTimer()
        speakInstruction()
    }
    
    func stopWorkout() {
        isWorkoutActive = false
        isPaused = false
        timer?.invalidate()
        speechSynthesizer.stopSpeaking(at: .immediate)
        audioPlayer?.stop()
        
        // Save workout session
        if let workout = workout {
            let session = WorkoutSession(workout: workout)
            settings.completedWorkouts.append(session)
            saveSettings()
        }
    }
    
    func nextExercise() {
        guard let workout = workout else { return }
        
        if currentExerciseIndex < workout.exercises.count - 1 {
            currentExerciseIndex += 1
            currentExercise = workout.exercises[currentExerciseIndex]
            timeRemaining = currentExercise?.adjustedDuration ?? 0
            speakInstruction()
            
            if settings.vibrationEnabled {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        } else {
            completeWorkout()
        }
    }
    
    private func completeWorkout() {
        isWorkoutActive = false
        timer?.invalidate()
        
        // Play completion sound
        if settings.soundEnabled {
            playSound(named: "workout_complete")
        }
        
        // Save completed workout
        if let workout = workout {
            var session = WorkoutSession(workout: workout)
            session.endDate = Date()
            session.completed = true
            session.duration = elapsedTime
            settings.completedWorkouts.append(session)
            // ACHIEVEMENTS LOGIC
            var newAchievements: [AchievementType] = []
            let earned = Set(settings.achievements.map { $0.type })
            // First workout
            if settings.completedWorkouts.count == 1 && !earned.contains(.firstWorkout) {
                newAchievements.append(.firstWorkout)
            }
            // Streaks
            let days = Set(settings.completedWorkouts.map { Calendar.current.startOfDay(for: $0.startDate) })
            let sortedDays = days.sorted()
            var maxStreak = 1, curStreak = 1
            for i in 1..<sortedDays.count {
                if Calendar.current.date(byAdding: .day, value: 1, to: sortedDays[i-1]) == sortedDays[i] {
                    curStreak += 1
                    maxStreak = max(maxStreak, curStreak)
                } else {
                    curStreak = 1
                }
            }
            if maxStreak >= 3 && !earned.contains(.streak3) { newAchievements.append(.streak3) }
            if maxStreak >= 7 && !earned.contains(.streak7) { newAchievements.append(.streak7) }
            // All categories
            let allCats = Set(settings.completedWorkouts.map { $0.workout.category })
            if allCats.count == WorkoutCategory.allCases.count && !earned.contains(.allCategories) {
                newAchievements.append(.allCategories)
            }
            // Monday Warrior
            if Calendar.current.component(.weekday, from: session.startDate) == 2 && !earned.contains(.mondayWarrior) {
                newAchievements.append(.mondayWarrior)
            }
            // Challenge Accepted
            if workout.mode == .challenge && !earned.contains(.challengeAccepted) {
                newAchievements.append(.challengeAccepted)
            }
            // Points logic
            let base = workout.exercises.count * 10
            let minutes = max(1, workout.totalDuration / 60) * 5
            let bonus = (workout.mode == .challenge) ? 20 : 0
            let points = base + minutes + bonus
            settings.totalPoints += points
            // Points achievements
            if settings.totalPoints >= 100 && !earned.contains(.points100) { newAchievements.append(.points100) }
            if settings.totalPoints >= 500 && !earned.contains(.points500) { newAchievements.append(.points500) }
            if settings.totalPoints >= 1000 && !earned.contains(.points1000) { newAchievements.append(.points1000) }
            // Save new achievements
            let now = Date()
            for type in newAchievements {
                settings.achievements.append(Achievement(type: type, dateEarned: now))
            }
            saveSettings()
        }
        
        if settings.vibrationEnabled {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
    
    // MARK: - Timer Management
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func updateTimer() {
        guard !isPaused else { return }
        
        if timeRemaining > 0 {
            timeRemaining -= 1
            elapsedTime += 1
            
            // Update progress
            if let workout = workout {
                let totalElapsed = workout.exercises.prefix(currentExerciseIndex).reduce(0) { $0 + $1.adjustedDuration } + (currentExercise?.adjustedDuration ?? 0) - timeRemaining
                workoutProgress = Double(totalElapsed) / Double(workout.totalDuration)
            }
            
            // Play countdown sound
            if timeRemaining <= 3 && timeRemaining > 0 && settings.soundEnabled {
                playSound(named: "countdown")
            }
            
        } else {
            nextExercise()
        }
    }
    
    // MARK: - Voice Instructions
    private func speakInstruction() {
        guard settings.soundEnabled, settings.voicePromptsEnabled, let exercise = currentExercise else { return }
        let utterance = AVSpeechUtterance(string: exercise.voiceInstruction)
        utterance.voice = AVSpeechSynthesisVoice(language: "ru-RU")
        utterance.rate = 0.5
        utterance.volume = 0.8
        speechSynthesizer.speak(utterance)
    }
    
    // MARK: - Sound Effects
    private func playSound(named soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
    
    // MARK: - Settings Management
    private func saveSettings() {
        UserDefaults.standard.saveSettings(settings)
    }
    
    func updateDifficulty(_ difficulty: DifficultyLevel) {
        settings.difficultyLevel = difficulty
    }
    
    func updateWorkoutDuration(_ duration: WorkoutDuration) {
        settings.workoutDuration = duration
    }
    
    func toggleSound() {
        settings.soundEnabled.toggle()
    }
    
    func toggleVibration() {
        settings.vibrationEnabled.toggle()
    }
    
    // MARK: - Computed Properties
    var formattedTimeRemaining: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var formattedElapsedTime: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var currentExerciseNumber: Int {
        return currentExerciseIndex + 1
    }
    
    var totalExercises: Int {
        return workout?.exercises.count ?? 0
    }
    
    var isLastExercise: Bool {
        return currentExerciseIndex == (workout?.exercises.count ?? 0) - 1
    }
} 
