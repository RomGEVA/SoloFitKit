//
//  ContentView.swift
//  SoloFitKit
//
//  Created by Роман Главацкий on 14.07.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject var workoutViewModel = WorkoutViewModel()
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    var body: some View {
        if hasSeenOnboarding {
            MainView()
        } else {
            OnboardingView(workoutViewModel: workoutViewModel)
        }
    }
}

#Preview {
    ContentView()
}
