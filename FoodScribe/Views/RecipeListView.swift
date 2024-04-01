//
//  RecipeListView.swift
//  FoodScribe
//
//  Created by Ryan Morrison on 31/03/2024.
//

import Foundation
import SwiftUI

struct RecipeListView: View {
    let category: String
    @State private var recipes: [Recipe] = []
    
    var body: some View {
        List(recipes) { recipe in
            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                Text(recipe.name)
            }
        }
        .navigationTitle(category)
        .onAppear {
            loadRecipes()
        }
    }
    
    func loadRecipes() {
        guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json") else {
            fatalError("Failed to locate recipes.json file")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            recipes = try decoder.decode([Recipe].self, from: data)
            recipes = recipes.filter { $0.category == category }
        } catch {
            print("Failed to decode JSON: \(error)")
        }
    }
}

