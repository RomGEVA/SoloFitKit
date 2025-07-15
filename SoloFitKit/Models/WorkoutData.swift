import Foundation

// MARK: - Workout Data Provider
struct WorkoutData {
    
    static func exercises(for category: WorkoutCategory, difficulty: DifficultyLevel) -> [Exercise] {
        switch category {
        case .warmup:
            return warmupExercises(difficulty: difficulty)
        case .chestArms:
            return chestArmsExercises(difficulty: difficulty)
        case .legs:
            return legsExercises(difficulty: difficulty)
        case .hiit:
            return hiitExercises(difficulty: difficulty)
        case .stretching:
            return stretchingExercises(difficulty: difficulty)
        case .yoga:
            return yogaExercises(difficulty: difficulty)
        }
    }
    
    // MARK: - Warm-up Exercises
    private static func warmupExercises(difficulty: DifficultyLevel) -> [Exercise] {
        let all: [Exercise] = [
            Exercise(
                name: "March in Place",
                description: "Slowly march in place, lifting your knees",
                duration: 30,
                animationName: "walking_in_place",
                voiceInstruction: "Let's start with marching in place. Lift your knees higher for a better warm-up.",
                category: .warmup,
                difficulty: difficulty,
                baseLevel: .beginner,
                tips: ["Keep your back straight", "Swing your arms naturally"]
            ),
            Exercise(
                name: "Arm Circles",
                description: "Make circular motions with your arms forward and backward",
                duration: 20,
                animationName: "arm_circles",
                voiceInstruction: "Now arm circles. 10 forward, 10 backward.",
                category: .warmup,
                difficulty: difficulty,
                baseLevel: .beginner,
                tips: ["Relax your shoulders", "Make big, controlled circles"]
            ),
            Exercise(
                name: "Side Bends",
                description: "Bend to the left and right, stretching your sides",
                duration: 25,
                animationName: "side_bends",
                voiceInstruction: "Side bends. Breathe deeply and stretch your sides.",
                category: .warmup,
                difficulty: difficulty,
                baseLevel: .beginner,
                tips: ["Don't lean forward or back", "Reach for the ceiling"]
            ),
            Exercise(
                name: "Bodyweight Squats",
                description: "Do shallow squats with no weight",
                duration: 30,
                animationName: "bodyweight_squats",
                voiceInstruction: "Bodyweight squats. Keep your knees behind your toes.",
                category: .warmup,
                difficulty: difficulty,
                baseLevel: .intermediate,
                tips: ["Keep your chest up", "Push through your heels"]
            ),
            Exercise(
                name: "Jumping Jacks",
                description: "Light jumps to warm up the whole body",
                duration: 25,
                animationName: "jumping_jacks",
                voiceInstruction: "Finish the warm-up with jumping jacks. Raise your arms up.",
                category: .warmup,
                difficulty: difficulty,
                baseLevel: .advanced,
                tips: ["Land softly on your feet", "Keep your core engaged"]
            )
        ]
        switch difficulty {
        case .beginner:
            return all.filter { $0.baseLevel == .beginner }
        case .intermediate:
            return all.filter { $0.baseLevel == .beginner || $0.baseLevel == .intermediate }
        case .advanced:
            return all
        }
    }
    
    // MARK: - Chest and Arms Exercises
    private static func chestArmsExercises(difficulty: DifficultyLevel) -> [Exercise] {
        let all: [Exercise] = [
            Exercise(
                name: "Push-ups",
                description: "Classic push-ups from the floor",
                duration: 45,
                animationName: "push_ups",
                voiceInstruction: "Push-ups. Keep your body straight, elbows close to your body.",
                category: .chestArms,
                difficulty: difficulty,
                baseLevel: .intermediate,
                tips: ["Keep your elbows at 45°", "Don't let your hips sag"]
            ),
            Exercise(
                name: "Knee Push-ups",
                description: "Easier version of push-ups",
                duration: 40,
                animationName: "knee_push_ups",
                voiceInstruction: "Knee push-ups. Perfect for beginners.",
                category: .chestArms,
                difficulty: difficulty,
                baseLevel: .beginner,
                tips: ["Keep your body in a straight line", "Lower your chest to the floor"]
            ),
            Exercise(
                name: "Plank",
                description: "Hold a plank to strengthen your core",
                duration: 30,
                animationName: "plank",
                voiceInstruction: "Plank. Keep your body straight, tighten your abs.",
                category: .chestArms,
                difficulty: difficulty,
                baseLevel: .beginner,
                tips: ["Don't let your hips drop", "Look down, not forward"]
            ),
            Exercise(
                name: "Burpees",
                description: "A complex full-body exercise",
                duration: 35,
                animationName: "burpees",
                voiceInstruction: "Burpees. Squat, push-up, jump up.",
                category: .chestArms,
                difficulty: difficulty,
                baseLevel: .advanced,
                tips: ["Land softly", "Explode up on the jump"]
            ),
            Exercise(
                name: "Clap Push-ups",
                description: "Explosive push-ups with a clap",
                duration: 30,
                animationName: "clap_push_ups",
                voiceInstruction: "Clap push-ups. For advanced only!",
                category: .chestArms,
                difficulty: difficulty,
                baseLevel: .advanced,
                tips: ["Push hard off the ground", "Keep your core tight"]
            )
        ]
        switch difficulty {
        case .beginner:
            return all.filter { $0.baseLevel == .beginner }
        case .intermediate:
            return all.filter { $0.baseLevel == .beginner || $0.baseLevel == .intermediate }
        case .advanced:
            return all
        }
    }
    
    // MARK: - Legs Exercises
    private static func legsExercises(difficulty: DifficultyLevel) -> [Exercise] {
        let all: [Exercise] = [
            Exercise(
                name: "Squats",
                description: "Deep squats with proper technique",
                duration: 40,
                animationName: "squats",
                voiceInstruction: "Squats. Keep your knees behind your toes.",
                category: .legs,
                difficulty: difficulty,
                baseLevel: .beginner,
                tips: ["Keep your chest up", "Knees out, not in"]
            ),
            Exercise(
                name: "Lunges",
                description: "Alternate lunges forward",
                duration: 35,
                animationName: "lunges",
                voiceInstruction: "Lunges. Step forward, back knee to the floor.",
                category: .legs,
                difficulty: difficulty,
                baseLevel: .beginner,
                tips: ["Keep your front knee above your ankle", "Don't let your back knee touch the floor"]
            ),
            Exercise(
                name: "Jump Squats",
                description: "Squat down and jump up explosively",
                duration: 30,
                animationName: "jump_squats",
                voiceInstruction: "Jump squats. Squat and jump up powerfully.",
                category: .legs,
                difficulty: difficulty,
                baseLevel: .intermediate,
                tips: ["Land softly", "Explode up from the bottom"]
            ),
            Exercise(
                name: "Calf Raises",
                description: "Strengthen your calves",
                duration: 25,
                animationName: "calf_raises",
                voiceInstruction: "Calf raises. Slowly go up and down.",
                category: .legs,
                difficulty: difficulty,
                baseLevel: .beginner,
                tips: ["Pause at the top", "Keep your balance"]
            ),
            Exercise(
                name: "Bulgarian Split Squats",
                description: "Squats with your back leg elevated",
                duration: 30,
                animationName: "bulgarian_split_squats",
                voiceInstruction: "Bulgarian split squats. Back leg on a chair.",
                category: .legs,
                difficulty: difficulty,
                baseLevel: .advanced,
                tips: ["Keep your torso upright", "Push through your front heel"]
            )
        ]
        switch difficulty {
        case .beginner:
            return all.filter { $0.baseLevel == .beginner }
        case .intermediate:
            return all.filter { $0.baseLevel == .beginner || $0.baseLevel == .intermediate }
        case .advanced:
            return all
        }
    }
    
    // MARK: - HIIT Exercises
    private static func hiitExercises(difficulty: DifficultyLevel) -> [Exercise] {
        let all: [Exercise] = [
            Exercise(
                name: "Burpees",
                description: "Intense full-body exercise",
                duration: 30,
                animationName: "burpees",
                voiceInstruction: "Burpees! Maximum intensity!",
                category: .hiit,
                difficulty: difficulty,
                baseLevel: .intermediate,
                tips: ["Move fast, but keep form", "Explode up on the jump"]
            ),
            Exercise(
                name: "Jumping Jacks",
                description: "Jumping with arms and legs apart",
                duration: 25,
                animationName: "jumping_jacks",
                voiceInstruction: "Jumping jacks! Fast and intense!",
                category: .hiit,
                difficulty: difficulty,
                baseLevel: .beginner,
                tips: ["Keep your arms straight", "Land softly"]
            ),
            Exercise(
                name: "Mountain Climbers",
                description: "Running in place in a plank position",
                duration: 35,
                animationName: "mountain_climbers",
                voiceInstruction: "Mountain climbers! Quickly bring your knees to your chest!",
                category: .hiit,
                difficulty: difficulty,
                baseLevel: .intermediate,
                tips: ["Keep your hips low", "Drive your knees quickly"]
            ),
            Exercise(
                name: "Jump Squats",
                description: "Explosive jumps from a squat",
                duration: 30,
                animationName: "jump_squats",
                voiceInstruction: "Jump squats! Maximum power!",
                category: .hiit,
                difficulty: difficulty,
                baseLevel: .advanced,
                tips: ["Explode up", "Land softly"]
            ),
            Exercise(
                name: "Clap Push-ups",
                description: "Explosive push-ups",
                duration: 25,
                animationName: "clap_push_ups",
                voiceInstruction: "Clap push-ups! Explosive strength!",
                category: .hiit,
                difficulty: difficulty,
                baseLevel: .advanced,
                tips: ["Push hard off the ground", "Keep your core tight"]
            )
        ]
        switch difficulty {
        case .beginner:
            return all.filter { $0.baseLevel == .beginner }
        case .intermediate:
            return all.filter { $0.baseLevel == .beginner || $0.baseLevel == .intermediate }
        case .advanced:
            return all
        }
    }
    
    // MARK: - Stretching Exercises
    private static func stretchingExercises(difficulty: DifficultyLevel) -> [Exercise] {
        let all: [Exercise] = [
            Exercise(
                name: "Hamstring Stretch",
                description: "Bend forward to stretch your hamstrings",
                duration: 30,
                animationName: "hamstring_stretch",
                voiceInstruction: "Hamstring stretch. Keep your knees straight.",
                category: .stretching,
                difficulty: difficulty,
                baseLevel: .beginner,
                tips: ["Don't bounce", "Relax your neck"]
            ),
            Exercise(
                name: "Butterfly Stretch",
                description: "Stretch your inner thighs by bringing your feet together",
                duration: 25,
                animationName: "butterfly_stretch",
                voiceInstruction: "Butterfly stretch. Bring your feet together and lean forward.",
                category: .stretching,
                difficulty: difficulty,
                baseLevel: .beginner,
                tips: ["Keep your back straight", "Gently press your knees down"]
            ),
            Exercise(
                name: "Quad Stretch",
                description: "Standing, pull your heel to your glute",
                duration: 20,
                animationName: "quad_stretch",
                voiceInstruction: "Quad stretch. Pull your heel to your glute.",
                category: .stretching,
                difficulty: difficulty,
                baseLevel: .beginner,
                tips: ["Keep your knees together", "Stand tall"]
            ),
            Exercise(
                name: "Cat-Cow",
                description: "Stretch your back on all fours",
                duration: 30,
                animationName: "cat_cow",
                voiceInstruction: "Cat-cow. Arch and round your back.",
                category: .stretching,
                difficulty: difficulty,
                baseLevel: .intermediate,
                tips: ["Move slowly", "Breathe deeply"]
            ),
            Exercise(
                name: "Shoulder Stretch",
                description: "Cross-body shoulder stretch",
                duration: 20,
                animationName: "shoulder_stretch",
                voiceInstruction: "Shoulder stretch. Cross your arms in front of your chest.",
                category: .stretching,
                difficulty: difficulty,
                baseLevel: .intermediate,
                tips: ["Don't pull too hard", "Relax your shoulders"]
            )
        ]
        switch difficulty {
        case .beginner:
            return all.filter { $0.baseLevel == .beginner }
        case .intermediate:
            return all.filter { $0.baseLevel == .beginner || $0.baseLevel == .intermediate }
        case .advanced:
            return all
        }
    }
    
    // MARK: - Yoga Exercises
    private static func yogaExercises(difficulty: DifficultyLevel) -> [Exercise] {
        let all: [Exercise] = [
            Exercise(
                name: "Child's Pose",
                description: "Relaxing pose for rest",
                duration: 45,
                animationName: "child_pose",
                voiceInstruction: "Child's pose. Relax and breathe deeply.",
                category: .yoga,
                difficulty: difficulty,
                baseLevel: .beginner,
                tips: ["Let your forehead rest on the mat", "Breathe slowly"]
            ),
            Exercise(
                name: "Cat Pose",
                description: "Gentle back stretch",
                duration: 30,
                animationName: "cat_pose",
                voiceInstruction: "Cat pose. Round your back, lower your head.",
                category: .yoga,
                difficulty: difficulty,
                baseLevel: .beginner,
                tips: ["Move with your breath", "Relax your neck"]
            ),
            Exercise(
                name: "Downward Dog",
                description: "Full body stretch",
                duration: 40,
                animationName: "downward_dog",
                voiceInstruction: "Downward dog. Push your hips back and up.",
                category: .yoga,
                difficulty: difficulty,
                baseLevel: .intermediate,
                tips: ["Press your heels down", "Spread your fingers wide"]
            ),
            Exercise(
                name: "Warrior Pose",
                description: "Strengthen your legs and balance",
                duration: 35,
                animationName: "warrior_pose",
                voiceInstruction: "Warrior pose. Wide lunge, arms to the sides.",
                category: .yoga,
                difficulty: difficulty,
                baseLevel: .intermediate,
                tips: ["Keep your front knee above your ankle", "Reach through your fingertips"]
            ),
            Exercise(
                name: "Lotus Pose",
                description: "Meditative pose to finish",
                duration: 60,
                animationName: "lotus_pose",
                voiceInstruction: "Lotus pose. Sit comfortably, close your eyes, meditate.",
                category: .yoga,
                difficulty: difficulty,
                baseLevel: .advanced,
                tips: ["Sit tall", "Relax your shoulders"]
            )
        ]
        switch difficulty {
        case .beginner:
            return all.filter { $0.baseLevel == .beginner }
        case .intermediate:
            return all.filter { $0.baseLevel == .beginner || $0.baseLevel == .intermediate }
        case .advanced:
            return all
        }
    }
} 