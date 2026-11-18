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
    @State private var timeLimit = 0
    @State private var categories: [TriviaCategory] = []
    var body: some View {
        NavigationStack {
            Form {
                Section("Game Settings") {
                    
                    Picker("Category", selection: $category) {
                        Text("Any Category").tag("any")

                        ForEach(categories) { category in
                            Text(category.name)
                                .tag(String(category.id))
                        }
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
                        step: 1
                    )

                    Picker("Question Type", selection: $questionType) {
                        Text("Multiple Choice").tag("multiple")
                        Text("True / False").tag("boolean")
                    }
                    
                    Picker("Quiz Time", selection: $timeLimit) {
                        Text("No Limit").tag(0)
                        Text("30 Seconds").tag(30)
                        Text("1 Minute").tag(60)
                        Text("2 Minutes").tag(120)
                        Text("3 Minutes").tag(180)
                    }

                }

                Section {
                    NavigationLink {
                        ContentView(category: category, timeLimit: timeLimit)
                        } label: {
                            Text("Start Game")
                                .frame(maxWidth: .infinity)
                        }
                }
                
            }
            .navigationTitle("Trivia Challenge")
            .task {
                await fetchCategories()
            }
        }
    }
    
    func fetchCategories() async {
        guard let url = URL(string:
            "https://opentdb.com/api_category.php"
        ) else {
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            let response = try JSONDecoder().decode(
                CategoryResponse.self,
                from: data
            )

            categories = response.trivia_categories

            print("Fetched \(categories.count) categories")

        } catch {
            print("Error fetching categories: \(error)")
        }
    }

}

#Preview {
    StartingView()
}
