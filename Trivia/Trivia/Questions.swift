//
//  Questions.swift
//  Trivia
//
//  Created by Brian Ribeiro on 11/13/26.
//

import Foundation

struct TriviaResponse: Codable {
    let response_code: Int
    let results: [TriviaQuestion]
}

struct TriviaQuestion: Codable {
    let category: String
    let difficulty: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}
