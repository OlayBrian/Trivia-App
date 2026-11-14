//
//  ContentView.swift
//  Trivia
//
//  Created by Brian Ribeiro on 11/13/26.
//

import SwiftUI

struct ContentView: View {
    
    let category: String
    
    
    @State private var questions: [TriviaQuestion] = []
    @State private var selectedAnswers: [String: String] = [:]
    
    func fetchQuestions() async {
        var urlString = "https://opentdb.com/api.php?amount=10&type=multiple&encode=url3986"

        if category != "any" {
            urlString += "&category=\(category)"
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
    
    
    func answerColor(answer: String, question: TriviaQuestion) -> Color {
        guard let selected = selectedAnswers[question.question] else {
            return Color.gray.opacity(0.1)
        }

        if answer == question.correct_answer {
            return Color.green.opacity(0.3)
        }

        if answer == selected {
            return Color.red.opacity(0.3)
        }

        return Color.gray.opacity(0.1)
    }

    
    
    
    var body: some View {
            List(questions, id: \.question) { question in
                VStack(alignment: .leading, spacing: 10) {
                    Text(question.question.removingPercentEncoding ?? question.question)
                        .font(.headline)
                    
                    
                    ForEach(question.allAnswers, id: \.self) { answer in
                        Button {
                            if selectedAnswers[question.question] == nil {
                                selectedAnswers[question.question] = answer
                            }
                        } label: {
                            Text(answer.removingPercentEncoding ?? answer)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    answerColor(
                                        answer: answer,
                                        question: question
                                    )
                                )
                                .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                    }


                }
                .padding(.vertical, 5)
            }

            .navigationTitle("Trivia")
            .task {
                await fetchQuestions()
            }
    }
}

#Preview {
    ContentView(category: "any")
}
