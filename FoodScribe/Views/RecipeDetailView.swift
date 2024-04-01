//
//  RecipeDetailView.swift
//  FoodScribe
//
//  Created by Ryan Morrison on 31/03/2024.
//

import Foundation
import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Image(recipe.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Text(recipe.name)
                    .font(.title)
                
                Text(recipe.description)
                    .font(.subheadline)
                
                // Display other recipe details
            }
            .padding()
        }
        .navigationBarTitle(recipe.name)
    }
}

