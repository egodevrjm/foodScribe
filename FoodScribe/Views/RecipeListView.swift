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
    let recipes: [Recipe]
    
    var filteredRecipes: [Recipe] {
        recipes.filter { $0.category == category }
    }
    
    var body: some View {
        List(filteredRecipes) { recipe in
            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                HStack {
                    Image(uiImage: UIImage(named: recipe.image)!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipped()
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading) {
                        Text(recipe.name)
                            .font(.headline)
                        
                        Text(recipe.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                }
            }
        }
        .navigationBarTitle(category, displayMode: .inline)
    }
}
