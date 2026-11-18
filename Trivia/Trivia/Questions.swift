//
//  Questions.swift
//  Trivia
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
    let allAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case category
        case difficulty
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        category = try container.decode(
            String.self,
            forKey: .category
        )

        difficulty = try container.decode(
            String.self,
            forKey: .difficulty
        )

        question = try container.decode(
            String.self,
            forKey: .question
        )

        correctAnswer = try container.decode(
            String.self,
            forKey: .correctAnswer
        )

        incorrectAnswers = try container.decode(
            [String].self,
            forKey: .incorrectAnswers
        )

        allAnswers = (
            incorrectAnswers + [correctAnswer]
        ).shuffled()
    }
}
