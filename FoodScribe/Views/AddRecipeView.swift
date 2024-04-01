//
//  AddRecipeView.swift
//  FoodScribe
//
//  Created by Ryan Morrison on 31/03/2024.
//

import Foundation
import SwiftUI

struct AddRecipeView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var recipeData = RecipeData()
    
    let categories = ["Appetizers", "Entrees", "Desserts", "Salads", "Breads"]
    
    @State private var name = ""
    @State private var description = ""
    @State private var servings = ""
    @State private var prepTime = ""
    @State private var cookTime = ""
    @State private var ingredients: [Ingredient] = []
    @State private var newIngredient = ""
    @State private var instructions: [String] = []
    @State private var newInstruction = ""
    @State private var selectedCategory = "Appetizers"
    @State private var recipeImage: UIImage?
    @State private var showActionSheet = false
    @State private var showImagePicker = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recipe Details")) {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                    TextField("Servings", text: $servings)
                    TextField("Prep Time", text: $prepTime)
                    TextField("Cook Time", text: $cookTime)
                }
                
                Section(header: Text("Ingredients")) {
                    ForEach(ingredients.indices, id: \.self) { index in
                        let ingredient = ingredients[index]
                        Text("\(ingredient.item) - \(ingredient.amount) \(ingredient.unit ?? "")")
                    }
                    .onDelete(perform: removeIngredient)
                    
                    HStack {
                        TextField("Item", text: $newIngredientItem)
                        TextField("Amount", text: $newIngredientAmount)
                            .keyboardType(.decimalPad)
                        TextField("Unit", text: $newIngredientUnit)
                    }
                    
                    Button(action: addIngredient) {
                        Text("Add Ingredient")
                    }
                }
                
                Section(header: Text("Instructions")) {
                    ForEach(instructions.indices, id: \.self) { index in
                        Text("\(index + 1). \(instructions[index])")
                    }
                    .onDelete(perform: removeInstruction)
                    
                    HStack {
                        TextField("New Instruction", text: $newInstruction)
                        Button(action: addInstruction) {
                            Text("Add")
                        }
                    }
                }
                
                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Recipe Image")) {
                    if recipeImage != nil {
                        Image(uiImage: recipeImage!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                    }
                    
                    Button(action: {
                        self.showActionSheet = true
                    }) {
                        Text("Select Image")
                    }
                }
            }
            .navigationBarTitle("Add Recipe")
            .navigationBarItems(trailing: Button("Save") {
                saveRecipe()
            })
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(title: Text("Select Image"), buttons: [
                    .default(Text("Camera")) {
                        self.imageSource = .camera
                        self.showImagePicker = true
                    },
                    .default(Text("Photo Library")) {
                        self.imageSource = .photoLibrary
                        self.showImagePicker = true
                    },
                    .cancel()
                ])
            }
            .fullScreenCover(isPresented: $showImagePicker) {
                ImagePicker(sourceType: imageSource, selectedImage: $recipeImage)
            }
        }
    }
    
    @State private var newIngredientItem = ""
    @State private var newIngredientAmount = ""
    @State private var newIngredientUnit = ""

    private func addIngredient() {
        guard !newIngredientItem.isEmpty, !newIngredientAmount.isEmpty else {
            print("Please enter an item and amount.")
            return
        }
        
        guard let amount = Double(newIngredientAmount) else {
            print("Invalid amount. Please enter a valid numeric value.")
            return
        }
        
        let unit = newIngredientUnit.isEmpty ? nil : newIngredientUnit
        
        let ingredient = Ingredient(item: newIngredientItem, amount: amount, unit: unit)
        ingredients.append(ingredient)
        
        newIngredientItem = ""
        newIngredientAmount = ""
        newIngredientUnit = ""
    }
    
    private func removeIngredient(at offsets: IndexSet) {
        ingredients.remove(atOffsets: offsets)
    }
    
    private func addInstruction() {
        instructions.append(newInstruction)
        newInstruction = ""
    }
    
    private func removeInstruction(at offsets: IndexSet) {
        instructions.remove(atOffsets: offsets)
    }
    
    private func saveRecipe() {
        guard let imageData = recipeImage?.jpegData(compressionQuality: 0.8) else {
            // Handle the case when no image is selected
            return
        }
        
        let imageName = UUID().uuidString + ".jpg"
        let imagePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(imageName)
        
        do {
            try imageData.write(to: imagePath)
            
            let newRecipe = Recipe(
                id: UUID().uuidString,
                name: name,
                description: description,
                servings: Int(servings) ?? 0,
                prepTime: prepTime,
                cookTime: cookTime,
                totalTime: "",
                ingredients: ingredients,
                instructions: instructions,
                notes: "",
                tags: [],
                category: selectedCategory,
                image: imageName,
                nutrition: Nutrition(calories: 0, fat: 0, carbs: 0, protein: 0),
                publishedDate: "",
                rating: 0
            )
            
            recipeData.recipes.append(newRecipe)
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving image: \(error.localizedDescription)")
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.selectedImage = selectedImage
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
