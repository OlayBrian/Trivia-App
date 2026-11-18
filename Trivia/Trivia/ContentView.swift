//
//  ContentView.swift
//  Trivia
//
//  Created by Brian Ribeiro on 11/13/26.
//

import Foundation
import SwiftUI

struct ContentView: View {
    
    let category: String
    let difficulty: String
    let questionCount: Int
    let questionType: String
    let timeLimit: Int

    @State private var questions: [TriviaQuestion] = []
    @State private var selectedAnswers: [String: String] = [:]
    @State private var isSubmitted = false
    @State private var timeRemaining = 0
    
    func fetchQuestions() async {
        var urlString = "https://opentdb.com/api.php?amount=\(questionCount)&type=\(questionType)&encode=url3986"

        if category != "any" {
            urlString += "&category=\(category)"
        }

        if difficulty != "any" {
            urlString += "&difficulty=\(difficulty)"
        }

        guard let url = URL(string: urlString) else {
            return
        }
        print("API URL: \(url.absoluteString)")
        
            
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let decodedResponse = try JSONDecoder().decode(
                TriviaResponse.self,
                from: data
            )
            
            questions = decodedResponse.results
            for question in questions {
                print("Category: \(question.category)")
            }
        } catch {
            print("Error fetching questions: \(error)")
        }
    }
    
    
    
    var formattedTimeRemaining: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func runTimer() async {
        guard timeLimit > 0 else {
            return
        }

        timeRemaining = timeLimit

        while timeRemaining > 0 && !isSubmitted {
            do {
                try await Task.sleep(for: .seconds(1))
            } catch {
                return
            }

            guard !isSubmitted else {
                return
            }

            timeRemaining -= 1
        }

        if timeRemaining == 0 {
            isSubmitted = true
        }
    }

    func answerColor(answer: String, question: TriviaQuestion) -> Color {
        guard let selected = selectedAnswers[question.question] else {
            return Color.gray.opacity(0.1)
        }

        if !isSubmitted {
            return answer == selected
                ? Color.blue.opacity(0.3)
                : Color.gray.opacity(0.1)
        }

        if answer == question.correctAnswer {
            return Color.green.opacity(0.3)
        }

        if answer == selected {
            return Color.red.opacity(0.3)
        }

        return Color.gray.opacity(0.1)
    }


    var body: some View {
        List {
            ForEach(questions) { question in
                VStack(alignment: .leading, spacing: 10) {
                    Text(question.question.removingPercentEncoding ?? question.question)
                        .font(.headline)

                    ForEach(question.allAnswers, id: \.self) { answer in
                        Button {
                            if !isSubmitted {
                                selectedAnswers[question.question] = answer
                            }
                        } label: {
                            Text(answer.removingPercentEncoding ?? answer)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    answerColor(answer: answer, question: question)
                                )
                                .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 5)
            }

            if !questions.isEmpty {
                Section {
                    if !isSubmitted {
                        Button("Submit Answers") {
                            isSubmitted = true
                        }
                        .frame(maxWidth: .infinity)
                        .disabled(selectedAnswers.count != questions.count)
                    } else {
                        VStack {
                            Text("Quiz Complete!")
                                .font(.headline)

                            Text("Score: \(calculateScore()) / \(questions.count)")
                                .font(.title2)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .navigationTitle("Trivia Game")
        .toolbar {
            if timeLimit > 0 && !questions.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                        Text(formattedTimeRemaining)
                            .monospacedDigit()
                    }
                    .foregroundStyle(timeRemaining <= 5 ? .red : .primary)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Time remaining: \(timeRemaining) seconds")
                }
            }
        }
        .task {
            await fetchQuestions()
            await runTimer()
        }
    }
    
    
    func calculateScore() -> Int {
        questions.filter { question in
            selectedAnswers[question.question] == question.correctAnswer
        }.count
    }


}

#Preview {
    //ContentView(category: "any")
}
