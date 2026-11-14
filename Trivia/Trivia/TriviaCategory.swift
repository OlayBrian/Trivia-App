//
//  TriviaCategory.swift
//  Trivia
//
//  Created by Brian Ribeiro on 11/13/26.
//


import Foundation

struct CategoryResponse: Codable {
    let trivia_categories: [TriviaCategory]
}

struct TriviaCategory: Codable, Identifiable {
    let id: Int
    let name: String
}
