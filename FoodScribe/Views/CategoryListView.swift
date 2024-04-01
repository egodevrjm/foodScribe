//
//  CategoryListView.swift
//  FoodScribe
//
//  Created by Ryan Morrison on 31/03/2024.
//

import Foundation
import SwiftUI

struct CategoryListView: View {
    @StateObject private var recipeData = RecipeData()
    
    var body: some View {
        NavigationView {
            List(recipeData.categories, id: \.self) { category in
                NavigationLink(destination: RecipeListView(category: category, recipes: recipeData.recipes)) {
                    HStack {
                        if let firstRecipe = recipeData.recipes.first(where: { $0.category == category }) {
                            Image(uiImage: UIImage(named: firstRecipe.image)!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipped()
                                .cornerRadius(8)
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .foregroundColor(.gray)
                        }
                        
                        Text(category)
                            .font(.headline)
                            .padding(.leading)
                    }
                }
            }
            .navigationTitle("Categories")
            .accentColor(.primary)
        }
    }
}
