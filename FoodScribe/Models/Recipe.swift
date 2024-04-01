//
//  Recipe.swift
//  FoodScribe
//
//  Created by Ryan Morrison on 31/03/2024.
//

import Foundation
import SwiftUI

struct Recipe: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let servings: Int
    let prepTime: String
    let cookTime: String
    let totalTime: String
    let ingredients: [Ingredient]
    let instructions: [String]
    let notes: String
    let tags: [String]
    let category: String
    let image: String
    let nutrition: Nutrition
    let publishedDate: String
    let rating: Double
}

struct Ingredient: Codable {
    let item: String
    let amount: Double
    let unit: String?
}

struct Nutrition: Codable {
    let calories: Int
    let fat: Int
    let carbs: Int
    let protein: Int
}

class RecipeData: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var categories: [String] = []
    
    init() {
        loadRecipes()
    }
    
    func loadRecipes() {
        guard let url = Bundle.main.url(forResource: "foodscribe", withExtension: "json") else {
            fatalError("Failed to locate foodscribe.json file")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            recipes = try decoder.decode([Recipe].self, from: data)
            categories = Array(Set(recipes.map { $0.category })).sorted()
        } catch {
            print("Failed to decode JSON: \(error)")
        }
    }
}
