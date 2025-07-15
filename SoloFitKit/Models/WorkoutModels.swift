import Foundation

// MARK: - Workout Category
enum WorkoutCategory: String, CaseIterable, Identifiable, Codable {
    case warmup = "Warm-up"
    case chestArms = "Chest & Arms"
    case legs = "Legs"
    case hiit = "HIIT"
    case stretching = "Stretching"
    case yoga = "Bedtime Yoga"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .warmup: return "figure.walk"
        case .chestArms: return "figure.strengthtraining.traditional"
        case .legs: return "figure.run"
        case .hiit: return "bolt.fill"
        case .stretching: return "figure.flexibility"
        case .yoga: return "moon.fill"
        }
    }
    
    var color: String {
        switch self {
        case .warmup: return "warmupColor"
        case .chestArms: return "chestArmsColor"
        case .legs: return "legsColor"
        case .hiit: return "hiitColor"
        case .stretching: return "stretchingColor"
        case .yoga: return "yogaColor"
        }
    }
}

// MARK: - Difficulty Level
enum DifficultyLevel: String, CaseIterable, Identifiable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var id: String { rawValue }
    
    var multiplier: Double {
        switch self {
        case .beginner: return 0.8
        case .intermediate: return 1.0
        case .advanced: return 1.3
        }
    }
}

// MARK: - Workout Duration
enum WorkoutDuration: Int, CaseIterable, Identifiable, Codable {
    case short = 10
    case medium = 15
    case long = 30
    
    var id: Int { rawValue }
    
    var displayName: String {
        return "\(rawValue) min"
    }
}

// MARK: - Exercise
struct Exercise: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let duration: Int // in seconds
    let animationName: String
    let voiceInstruction: String
    let category: WorkoutCategory
    let difficulty: DifficultyLevel
    let baseLevel: DifficultyLevel
    let tips: [String]
    
    var adjustedDuration: Int {
        return Int(Double(duration) * difficulty.multiplier)
    }
    
    enum CodingKeys: String, CodingKey {
        case name, description, duration, animationName, voiceInstruction, category, difficulty, baseLevel, tips
    }
    
    init(name: String, description: String, duration: Int, animationName: String, voiceInstruction: String, category: WorkoutCategory, difficulty: DifficultyLevel, baseLevel: DifficultyLevel, tips: [String] = []) {
        self.name = name
        self.description = description
        self.duration = duration
        self.animationName = animationName
        self.voiceInstruction = voiceInstruction
        self.category = category
        self.difficulty = difficulty
        self.baseLevel = baseLevel
        self.tips = tips
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        duration = try container.decode(Int.self, forKey: .duration)
        animationName = try container.decode(String.self, forKey: .animationName)
        voiceInstruction = try container.decode(String.self, forKey: .voiceInstruction)
        category = try container.decode(WorkoutCategory.self, forKey: .category)
        difficulty = try container.decode(DifficultyLevel.self, forKey: .difficulty)
        baseLevel = try container.decode(DifficultyLevel.self, forKey: .baseLevel)
        tips = try container.decodeIfPresent([String].self, forKey: .tips) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(duration, forKey: .duration)
        try container.encode(animationName, forKey: .animationName)
        try container.encode(voiceInstruction, forKey: .voiceInstruction)
        try container.encode(category, forKey: .category)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(baseLevel, forKey: .baseLevel)
        try container.encode(tips, forKey: .tips)
    }
}

// MARK: - Workout Mode
enum WorkoutMode: String, Codable, CaseIterable, Identifiable {
    case normal
    case challenge
    var id: String { rawValue }
}

// MARK: - Workout
struct Workout: Identifiable, Codable {
    let id = UUID()
    let name: String
    let category: WorkoutCategory
    let exercises: [Exercise]
    let totalDuration: Int
    let difficulty: DifficultyLevel
    let mode: WorkoutMode
    
    init(category: WorkoutCategory, difficulty: DifficultyLevel, duration: WorkoutDuration, mode: WorkoutMode = .normal) {
        self.name = category.rawValue
        self.category = category
        self.difficulty = difficulty
        self.mode = mode
        let allExercises = WorkoutData.exercises(for: category, difficulty: difficulty)
        var total = 0
        var selected: [Exercise] = []
        for ex in allExercises {
            if mode == .challenge || total + ex.adjustedDuration <= duration.rawValue * 60 {
                selected.append(ex)
                total += ex.adjustedDuration
                if mode != .challenge && total >= duration.rawValue * 60 { break }
            } else {
                break
            }
        }
        self.exercises = selected
        self.totalDuration = total
    }
    
    enum CodingKeys: String, CodingKey {
        case name, category, exercises, totalDuration, difficulty, mode
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(WorkoutCategory.self, forKey: .category)
        exercises = try container.decode([Exercise].self, forKey: .exercises)
        totalDuration = try container.decode(Int.self, forKey: .totalDuration)
        difficulty = try container.decode(DifficultyLevel.self, forKey: .difficulty)
        mode = try container.decodeIfPresent(WorkoutMode.self, forKey: .mode) ?? .normal
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(exercises, forKey: .exercises)
        try container.encode(totalDuration, forKey: .totalDuration)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(mode, forKey: .mode)
    }
}

// MARK: - Workout Session
struct WorkoutSession: Identifiable, Codable {
    let id = UUID()
    let workout: Workout
    let startDate: Date
    var endDate: Date?
    var completed: Bool
    var duration: Int
    
    init(workout: Workout) {
        self.workout = workout
        self.startDate = Date()
        self.endDate = nil
        self.completed = false
        self.duration = 0
    }
    
    enum CodingKeys: String, CodingKey {
        case workout, startDate, endDate, completed, duration
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        workout = try container.decode(Workout.self, forKey: .workout)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decodeIfPresent(Date.self, forKey: .endDate)
        completed = try container.decode(Bool.self, forKey: .completed)
        duration = try container.decode(Int.self, forKey: .duration)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(workout, forKey: .workout)
        try container.encode(startDate, forKey: .startDate)
        try container.encodeIfPresent(endDate, forKey: .endDate)
        try container.encode(completed, forKey: .completed)
        try container.encode(duration, forKey: .duration)
    }
}

// MARK: - User Settings
struct UserSettings: Codable {
    var difficultyLevel: DifficultyLevel = .intermediate
    var workoutDuration: WorkoutDuration = .medium
    var soundEnabled: Bool = true
    var vibrationEnabled: Bool = true
    var completedWorkouts: [WorkoutSession] = []
    var achievements: [Achievement] = []
    var totalPoints: Int = 0
    var voicePromptsEnabled: Bool = false
    static let `default` = UserSettings()
}

// MARK: - Achievements

enum AchievementType: String, Codable, CaseIterable, Identifiable {
    case firstWorkout
    case streak3
    case streak7
    case allCategories
    case mondayWarrior
    case challengeAccepted
    case points100
    case points500
    case points1000
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .firstWorkout: return "First Workout"
        case .streak3: return "3-Day Streak"
        case .streak7: return "7-Day Streak"
        case .allCategories: return "All Categories"
        case .mondayWarrior: return "Monday Warrior"
        case .challengeAccepted: return "Challenge Accepted"
        case .points100: return "100 Points"
        case .points500: return "500 Points"
        case .points1000: return "1000 Points"
        default: return self.rawValue.capitalized
        }
    }
    var description: String {
        switch self {
        case .firstWorkout: return "Complete your first workout."
        case .streak3: return "Train 3 days in a row."
        case .streak7: return "Train 7 days in a row."
        case .allCategories: return "Complete a workout in every category."
        case .mondayWarrior: return "Train on a Monday."
        case .challengeAccepted: return "Finish a Challenge mode workout."
        case .points100: return "Earn 100 total points."
        case .points500: return "Earn 500 total points."
        case .points1000: return "Earn 1000 total points."
        default: return ""
        }
    }
    var icon: String {
        switch self {
        case .firstWorkout: return "star.fill"
        case .streak3: return "flame.fill"
        case .streak7: return "flame"
        case .allCategories: return "circle.hexagongrid.fill"
        case .mondayWarrior: return "calendar"
        case .challengeAccepted: return "bolt.circle.fill"
        case .points100: return "rosette"
        case .points500: return "rosette"
        case .points1000: return "rosette"
        default: return "star"
        }
    }
}

struct Achievement: Identifiable, Codable {
    let id = UUID()
    let type: AchievementType
    let dateEarned: Date
} 
