//
//  Questions.swift
//  Trivia
//
//  Created by Brian Ribeiro on 11/13/26.
//

import Foundation

struct TriviaResponse: Decodable {
    let responseCode: Int
    let results: [TriviaQuestion]

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}

struct TriviaQuestion: Decodable, Identifiable {
    let id = UUID()
    let category: String
    let difficulty: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
    var allAnswers: [String] {
        incorrectAnswers + [correctAnswer]
    }

    enum CodingKeys: String, CodingKey {
        case category
        case difficulty
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}
