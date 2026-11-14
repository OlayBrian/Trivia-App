//
//  StartingView.swift
//  Trivia
//
//  Created by Brian Ribeiro on 11/13/26.
//


import SwiftUI

struct StartingView: View {
    @State private var category = "any"
    @State private var difficulty = "any"
    @State private var questionCount = 10
    @State private var questionType = "multiple"
    @State private var timeLimit = 15

    var body: some View {
        NavigationStack {
            Form {
                Section("Game Settings") {
                    Picker("Category", selection: $category) {
                        Text("Any Category").tag("any")
                        Text("General Knowledge").tag("9")
                        Text("Science: Computers").tag("18")
                        Text("History").tag("23")
                        Text("Sports").tag("21")
                    }

                    Picker("Difficulty", selection: $difficulty) {
                        Text("Any Difficulty").tag("any")
                        Text("Easy").tag("easy")
                        Text("Medium").tag("medium")
                        Text("Hard").tag("hard")
                    }

                    Stepper(
                        "Questions: \(questionCount)",
                        value: $questionCount,
                        in: 5...20,
                        step: 5
                    )

                    Picker("Question Type", selection: $questionType) {
                        Text("Multiple Choice").tag("multiple")
                        Text("True / False").tag("boolean")
                    }
                    
                    Picker("Time Per Question", selection: $timeLimit) {
                        Text("No Limit").tag(0)
                        Text("10 Seconds").tag(10)
                        Text("15 Seconds").tag(15)
                        Text("30 Seconds").tag(30)
                        Text("60 Seconds").tag(60)
                    }

                }

                Section {
                    Button("Start Game") {
                        print("Category: \(category)")
                        print("Difficulty: \(difficulty)")
                        print("Questions: \(questionCount)")
                        print("Type: \(questionType)")
                        print("Time Limit: \(timeLimit)")
                    }
                }
                
            }
            .navigationTitle("Trivia Challenge")
        }
    }
}

#Preview {
    StartingView()
}
