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
    @State private var servings: Int
    @State private var selectedIngredients: Set<String> = []
    @State private var timerDuration: TimeInterval = 0
    @State private var isTimerActive: Bool = false
    @State private var showFullScreenImage = false
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var isFavorite: Bool = false

    
    public init(recipe: Recipe) {
        self.recipe = recipe
        _servings = State(initialValue: recipe.servings)
        _timerDuration = State(initialValue: convertToSeconds(recipe.cookTime))
        _timeRemaining = State(initialValue: convertToSeconds(recipe.cookTime))
    }
    
    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    GeometryReader { geometry in
                        Image(uiImage: UIImage(named: recipe.image)!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: 300)
                            .clipped()
                            .overlay(
                                Rectangle()
                                    .foregroundColor(.black)
                                    .opacity(0.5)
                                    .overlay(
                                        Text(recipe.name)
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        , alignment: .bottomLeading
                                    )
                            )
                            .onTapGesture {
                                showFullScreenImage = true
                            }
                            .sheet(isPresented: $showFullScreenImage) {
                                FullScreenImageView(image: UIImage(named: recipe.image)!)
                            }
                    }
                    .frame(height: 300)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(recipe.description)
                        .font(.subheadline)
                        .padding(.top)
                    
                    HStack {
                        Text("Servings:")
                            .font(.headline)
                        
                        Stepper(value: $servings, in: 1...12) {
                            Text("\(servings)")
                        }
                    }
                    
                    Text("Ingredients:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 5) {
                            ForEach(recipe.ingredients, id: \.item) { ingredient in
                                HStack {
                                    Button(action: {
                                        if selectedIngredients.contains(ingredient.item) {
                                            selectedIngredients.remove(ingredient.item)
                                        } else {
                                            selectedIngredients.insert(ingredient.item)
                                        }
                                    }) {
                                        Image(systemName: selectedIngredients.contains(ingredient.item) ? "checkmark.square" : "square")
                                    }
                                    
                                    Text(ingredient.item)
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    Text("\(formatAmount(ingredient.amount * Double(servings) / Double(recipe.servings))) \(ingredient.unit ?? "")")
                                        .lineLimit(1)
                                }
                            }
                        }
                        
                        Text("Instructions:")
                            .font(.headline)
                            .padding(.top)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(recipe.instructions.indices, id: \.self) { index in
                                HStack(alignment: .top) {
                                    Text("\(index + 1).")
                                        .bold()
                                    
                                    Text(recipe.instructions[index])
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    
                    HStack {
                                            Text("Prep Time: \(recipe.prepTime)")
                                            Spacer()
                                            Text("Cook Time: \(recipe.cookTime)")
                                        }
                                        .font(.subheadline)
                                        .padding(.top)
                                        
                                        Button(action: {
                                            if isTimerActive {
                                                stopTimer()
                                            } else {
                                                startTimer()
                                            }
                                        }) {
                                            Text(isTimerActive ? "Stop Timer (\(formatTime(timeRemaining)))" : "Start Timer (\(recipe.cookTime))")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding()
                                                .background(isTimerActive ? Color.red : Color.blue)
                                                .cornerRadius(10)
                                        }
                                        .padding(.top)
                                        
                                        Text("Serving Size: \(recipe.servings)")
                                            .font(.subheadline)
                                    }
                                    .padding()
                                }
                            }
                            .ignoresSafeArea(edges: .top)
                            .navigationBarTitle("", displayMode: .inline)
                            .navigationBarItems(trailing:
                                HStack {
                            Button(action: {
                                toggleFavorite()
                            }) {
                                Image(systemName: isFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(.red)
                            }
                            
                            Button(action: {
                                shareRecipe()
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.blue)
                            }
            }
        )
                            .onAppear {
                                        servings = recipe.servings
                                timeRemaining = convertToSeconds(recipe.cookTime)
                            }
                                    .onReceive(timer) { _ in
                                        if timeRemaining > 0 {
                                            timeRemaining -= 1
                                        } else {
                                            stopTimer()
                                        }
                                    }
                                
                                
    }
    
    private func formatAmount(_ amount: Double) -> String {
        let fractionParts = rationalApproximationOf(x0: amount)
        let numerator = fractionParts.num
        let denominator = fractionParts.den
        
        if denominator == 1 {
            return "\(numerator)"
        } else {
            return "\(numerator)/\(denominator)"
        }
    }
    
    private func rationalApproximationOf(x0: Double, withPrecision eps: Double = 1.0E-6) -> (num: Int, den: Int) {
        var x = x0
        var a = x.rounded(.down)
        var (h1, k1, h, k) = (1, 0, Int(a), 1)
        
        while x - a > eps * Double(k) * Double(k) {
            x = 1.0 / (x - a)
            a = x.rounded(.down)
            (h1, k1, h, k) = (h, k, h1 + Int(a) * h, k1 + Int(a) * k)
        }
        
        return (num: h, den: k)
    }
    
    private func convertToSeconds(_ timeString: String) -> TimeInterval {
        let components = timeString.components(separatedBy: " ")
        var totalSeconds: TimeInterval = 0
        
        for component in components {
            if component.contains("hour") {
                let hours = TimeInterval(component.replacingOccurrences(of: "hours", with: "").replacingOccurrences(of: "hour", with: "").trimmingCharacters(in: .whitespaces)) ?? 0
                totalSeconds += hours * 3600
            } else if component.contains("minute") {
                let minutes = TimeInterval(component.replacingOccurrences(of: "minutes", with: "").replacingOccurrences(of: "minute", with: "").trimmingCharacters(in: .whitespaces)) ?? 0
                totalSeconds += minutes * 60
            }
        }
        
        return totalSeconds
    }
    
    
    private func startTimer() {
        isTimerActive = true
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
        private func stopTimer() {
            isTimerActive = false
            timeRemaining = 0
            timer.upstream.connect().cancel()
        }
        
        private func formatTime(_ time: TimeInterval) -> String {
            let minutes = Int(time) / 60
            let seconds = Int(time) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    
    private func toggleFavorite() {
            isFavorite.toggle()
            // Perform any additional logic or data persistence related to favoriting the recipe
        }
        
        private func shareRecipe() {
            let recipeText = """
            \(recipe.name)
            
            Ingredients:
            \(recipe.ingredients.map { "- \($0.item) (\($0.amount) \($0.unit ?? ""))" }.joined(separator: "\n"))
            
            Instructions:
            \(recipe.instructions.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
            """
            let activityViewController = UIActivityViewController(activityItems: [recipeText], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }

struct FullScreenImageView: View {
    let image: UIImage
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.edgesIgnoringSafeArea(.all))
                .onTapGesture {
                    // Dismiss the full-screen image view when tapped
                    presentationMode.wrappedValue.dismiss()
                }
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
}
