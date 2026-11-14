//
//  ContentView.swift
//  Trivia
//
//  Created by Brian Ribeiro on 11/13/26.
//

import SwiftUI

struct ContentView: View {
    
    
    @State private var questions: [TriviaQuestion] = []
    
    func fetchQuestions() async {
        guard let url = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple&encode=url3986") else {
            return
        }
            
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            let decodedResponse = try JSONDecoder().decode(
                TriviaResponse.self,
                from: data
            )
            
            questions = decodedResponse.results
            print("Fetched \(questions.count) questions")
            
        } catch {
            print("Error fetching questions: \(error)")
        }
    }
    
    
    
    var body: some View {
        NavigationStack {
            
            List(questions, id: \.question) { question in
                VStack(alignment: .leading, spacing: 10) {
                    Text(question.question.removingPercentEncoding ?? question.question)
                        .font(.headline)

                    ForEach(question.allAnswers, id: \.self) { answer in
                        Button {
                            print("Selected: \(answer)")
                        } label: {
                            Text(answer.removingPercentEncoding ?? answer)
                        }
                    }
                }
                .padding(.vertical, 5)
            }

            .navigationTitle("Trivia Game")
            .task {
                await fetchQuestions()
            }
        }
    }
}

#Preview {
    ContentView()
}
