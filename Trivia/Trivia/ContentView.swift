// xcode: set sdk=iOS

//
//  ContentView.swift
//  Trivia
//
//  Created by Brian Ribeiro on 11/13/26.
//

import Foundation
import SwiftUI

struct ContentView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let category: String
    let difficulty: String
    let questionCount: Int
    let questionType: String
    let timeLimit: Int

    @State private var questions: [TriviaQuestion] = []
    @State private var selectedAnswers: [String: String] = [:]
    @State private var isSubmitted = false
    @State private var timeRemaining = 0
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingResults = false
    
    func fetchQuestions() async {
        isLoading = true
        errorMessage = nil
        questions = []

        defer {
            isLoading = false
        }

        var urlString = "https://opentdb.com/api.php?amount=\(questionCount)&type=\(questionType)&encode=url3986"

        if category != "any" {
            urlString += "&category=\(category)"
        }

        if difficulty != "any" {
            urlString += "&difficulty=\(difficulty)"
        }

        guard let url = URL(string: urlString) else {
            errorMessage = "The quiz URL could not be created."
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  200...299 ~= httpResponse.statusCode else {
                errorMessage = "The trivia server returned an error."
                return
            }

            let decodedResponse = try JSONDecoder().decode(
                TriviaResponse.self,
                from: data
            )

            guard decodedResponse.responseCode == 0 else {
                errorMessage = "No questions matched those settings."
                return
            }

            guard !decodedResponse.results.isEmpty else {
                errorMessage = "No questions were returned."
                return
            }

            questions = decodedResponse.results
        } catch {
            errorMessage = "Questions could not be loaded. Please try again."
            print("Error fetching questions: \(error)")
        }
    }
    
    func loadQuiz() async {
        selectedAnswers = [:]
        isSubmitted = false
        timeRemaining = 0
        showingResults = false

        await fetchQuestions()

        guard errorMessage == nil, !questions.isEmpty else {
            return
        }

        await runTimer()
    }
    var formattedTimeRemaining: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func submitQuiz() {
        guard !isSubmitted else {
            return
        }

        isSubmitted = true
        showingResults = true
    }

    func runTimer() async {
        guard timeLimit > 0 else {
            return
        }

        let endDate = Date.now.addingTimeInterval(
            TimeInterval(timeLimit)
        )

        while !isSubmitted {
            let secondsRemaining = Int(
                ceil(endDate.timeIntervalSinceNow)
            )

            timeRemaining = max(0, secondsRemaining)

            if timeRemaining == 0 {
                submitQuiz()
                return
            }

            do {
                try await Task.sleep(for: .milliseconds(250))
            } catch {
                return
            }
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
    
    func answerSymbol(
        answer: String,
        question: TriviaQuestion
    ) -> String? {
        let selectedAnswer = selectedAnswers[question.question]

        if isSubmitted {
            if answer == question.correctAnswer {
                return "checkmark.circle.fill"
            }

            if answer == selectedAnswer {
                return "xmark.circle.fill"
            }
        } else if answer == selectedAnswer {
            return "checkmark.circle.fill"
        }

        return nil
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
                            HStack {
                                Text(answer.removingPercentEncoding ?? answer)

                                Spacer()

                                if let symbol = answerSymbol(
                                    answer: answer,
                                    question: question
                                ) {
                                    Image(systemName: symbol)
                                }
                            }
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
                            submitQuiz()
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
        }.overlay {
            if isLoading {
                ProgressView("Loading questions…")
            } else if let errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)

                    Text(errorMessage)
                        .multilineTextAlignment(.center)

                    Button("Try Again") {
                        Task {
                            await loadQuiz()
                        }
                        
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }.safeAreaInset(edge: .bottom, spacing: 0) {
            if !questions.isEmpty {
                VStack(spacing: 8) {
                    HStack {
                        Text("Quiz Progress")

                        Spacer()

                        Text(
                            "\(selectedAnswers.count) of \(questions.count) answered"
                        )
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                    }

                    ProgressView(
                        value: Double(selectedAnswers.count),
                        total: Double(questions.count)
                    )
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(.regularMaterial)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Quiz progress")
                .accessibilityValue(
                    "\(selectedAnswers.count) of \(questions.count) answered"
                )
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
            await loadQuiz()
        }
        .sheet(isPresented: $showingResults) {
            VStack(spacing: 20) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.yellow)

                Text("Quiz Complete!")
                    .font(.largeTitle.bold())

                Text("Score: \(calculateScore()) / \(questions.count)")
                    .font(.title2)

                Text("Answered: \(selectedAnswers.count)")
                    .foregroundStyle(.secondary)

                Text(
                    "Unanswered: \(questions.count - selectedAnswers.count)"
                )
                .foregroundStyle(.secondary)

                Button("Review Answers") {
                    showingResults = false
                }
                .buttonStyle(.borderedProminent)

                Button("Play Again") {
                    showingResults = false

                    Task {
                        await loadQuiz()
                    }
                }
                .buttonStyle(.bordered)

                Button("Change Settings") {
                    showingResults = false
                    dismiss()
                }
            }
            .padding()
            .presentationDetents([.medium])
            .interactiveDismissDisabled()
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
