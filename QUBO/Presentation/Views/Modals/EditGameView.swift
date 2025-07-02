// MARK: - Presentation/Views/Modals/EditGameView.swift
import SwiftUI

struct EditGameView: View {
    let originalGame: Game
    @ObservedObject var viewModel: GamesViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String
    @State private var platform: String
    @State private var completionDate: Date
    @State private var score: Int
    @State private var review: String
    @State private var showingImagePicker = false
    
    init(game: Game, viewModel: GamesViewModel) {
        self.originalGame = game
        self.viewModel = viewModel
        
        // Initialize state variables
        _title = State(initialValue: game.title)
        _platform = State(initialValue: game.platform)
        _completionDate = State(initialValue: game.completionDate)
        _score = State(initialValue: game.score)
        _review = State(initialValue: game.review)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Game Information") {
                    TextField("Game Title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Platform", text: $platform)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    DatePicker("Completion Date", selection: $completionDate, displayedComponents: .date)
                }
                
                Section("Rating") {
                    HStack {
                        Text("Score: \(score)/10")
                            .font(.headline)
                        
                        Spacer()
                        
                        Stepper(value: $score, in: 1...10) {
                            HStack(spacing: 4) {
                                ForEach(1...10, id: \.self) { index in
                                    Image(systemName: index <= score ? "star.fill" : "star")
                                        .font(.caption)
                                        .foregroundColor(index <= score ? .yellow : .gray)
                                }
                            }
                        }
                    }
                }
                
                Section("Review") {
                    TextEditor(text: $review)
                        .frame(minHeight: 120)
                }
                
                Section("Cover Image") {
                    HStack {
                        // Current image preview
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppTheme.textColor)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Group {
                                    if originalGame.coverImage.hasPrefix("http") {
                                        AsyncImage(url: URL(string: originalGame.coverImage)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            Image(systemName: "gamepad.fill")
                                                .foregroundColor(.white)
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    } else {
                                        Image(systemName: originalGame.coverImage)
                                            .foregroundColor(.white)
                                    }
                                }
                            )
                        
                        VStack(alignment: .leading) {
                            Text("Cover Image")
                                .font(.headline)
                            Text("Tap to change image")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button("Change") {
                            showingImagePicker = true
                        }
                        .disabled(true) // Disabled for now, will implement later
                    }
                }
            }
            .navigationTitle("Edit Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGame()
                    }
                    .disabled(title.isEmpty || platform.isEmpty || review.isEmpty)
                }
            }
        }
    }
    
    private func saveGame() {
        let updatedGame = Game(
            id: originalGame.id,
            title: title,
            platform: platform,
            completionDate: completionDate,
            score: score,
            coverImage: originalGame.coverImage, // Keep original image for now
            review: review
        )
        
        viewModel.updateGame(updatedGame)
        presentationMode.wrappedValue.dismiss()
    }
}
