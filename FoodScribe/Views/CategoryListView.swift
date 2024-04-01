//
//  CategoryListView.swift
//  FoodScribe
//
//  Created by Ryan Morrison on 31/03/2024.
//

import Foundation
import SwiftUI

struct CategoryListView: View {
    let categories = ["Entrees", "Desserts", "Salads"]
    
    var body: some View {
        NavigationView {
            List(categories, id: \.self) { category in
                NavigationLink(destination: RecipeListView(category: category)) {
                    Text(category)
                }
            }
            .navigationTitle("Categories")
        }
    }
}
