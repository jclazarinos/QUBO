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
        VStack(spacing: 0) {
            // Retro Header - IMPROVED LAYOUT
            ZStack {
                AppTheme.primaryColor
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                HStack(spacing: AppTheme.mediumSpacing) {
                    // Cancel Button - Fixed width
                    Button("CANCEL") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(AppTheme.body)
                    .foregroundColor(.white)
                    .frame(width: 80)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                            .fill(Color.white.opacity(0.2))
                    )
                    
                    // Title - Centered with flexible space
                    Spacer()
                    
                    Text("EDIT GAME")
                        .font(AppTheme.title)
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                        .fixedSize()
                    
                    Spacer()
                    
                    // Save Button - Fixed width matching Cancel
                    Button("SAVE") {
                        saveGame()
                    }
                    .font(AppTheme.body)
                    .foregroundColor(title.isEmpty || platform.isEmpty || review.isEmpty ? .gray : .white)
                    .frame(width: 80)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                            .fill(title.isEmpty || platform.isEmpty || review.isEmpty ?
                                  Color.white.opacity(0.2) : AppTheme.secondaryColor)
                    )
                    .disabled(title.isEmpty || platform.isEmpty || review.isEmpty)
                }
                .padding(.horizontal, AppTheme.largeSpacing)
                .padding(.vertical, AppTheme.mediumSpacing)
            }
            .frame(height: 60) // Fixed height for consistency
            
            ScrollView {
                VStack(spacing: AppTheme.largeSpacing) {
                    // Game Information Card
                    VStack(spacing: AppTheme.mediumSpacing) {
                        HStack {
                            Text("GAME INFORMATION")
                                .font(AppTheme.title)
                                .foregroundColor(AppTheme.primaryColor)
                                .textCase(.uppercase)
                            Spacer()
                        }
                        
                        VStack(spacing: AppTheme.mediumSpacing) {
                            PixelTextField(title: "GAME TITLE", text: $title, placeholder: "Enter game title...")
                            PixelTextField(title: "PLATFORM", text: $platform, placeholder: "e.g., SNES, PSX, N64...")
                            
                            // Date Picker with Retro Style
                            VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
                                Text("COMPLETION DATE")
                                    .font(AppTheme.caption)
                                    .foregroundColor(AppTheme.textColor)
                                    .textCase(.uppercase)
                                
                                DatePicker("", selection: $completionDate, displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .accentColor(AppTheme.accentColor)
                                    .padding(AppTheme.smallSpacing)
                                    .background(
                                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                            .fill(AppTheme.backgroundColor)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                                    .stroke(AppTheme.accentColor, lineWidth: 1)
                                            )
                                    )
                            }
                        }
                    }
                    .padding(AppTheme.mediumSpacing)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.mediumCornerRadius)
                            .fill(Color.white)
                            .shadow(color: AppTheme.textColor.opacity(0.1), radius: 4, x: 2, y: 2)
                    )
                    
                    // Rating Card
                    VStack(spacing: AppTheme.mediumSpacing) {
                        HStack {
                            Text("GAME RATING")
                                .font(AppTheme.title)
                                .foregroundColor(AppTheme.primaryColor)
                                .textCase(.uppercase)
                            Spacer()
                        }
                        
                        VStack(spacing: AppTheme.mediumSpacing) {
                            HStack {
                                Text("SCORE: \(score)/10")
                                    .font(AppTheme.body)
                                    .foregroundColor(AppTheme.textColor)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Button("-") {
                                        if score > 1 { score -= 1 }
                                    }
                                    .font(AppTheme.body)
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(AppTheme.primaryColor)
                                    .cornerRadius(AppTheme.smallCornerRadius)
                                    .disabled(score <= 1)
                                    
                                    Button("+") {
                                        if score < 10 { score += 1 }
                                    }
                                    .font(AppTheme.body)
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(AppTheme.primaryColor)
                                    .cornerRadius(AppTheme.smallCornerRadius)
                                    .disabled(score >= 10)
                                }
                            }
                            
                            // Pixel-style score bar
                            HStack(spacing: 2) {
                                ForEach(1...10, id: \.self) { index in
                                    Rectangle()
                                        .fill(index <= score ? AppTheme.secondaryColor : AppTheme.textColor.opacity(0.3))
                                        .frame(height: 16)
                                        .onTapGesture {
                                            score = index
                                        }
                                }
                            }
                            .cornerRadius(AppTheme.smallCornerRadius)
                        }
                    }
                    .padding(AppTheme.mediumSpacing)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.mediumCornerRadius)
                            .fill(Color.white)
                            .shadow(color: AppTheme.textColor.opacity(0.1), radius: 4, x: 2, y: 2)
                    )
                    
                    // Review Card
                    VStack(spacing: AppTheme.mediumSpacing) {
                        HStack {
                            Text("GAME REVIEW")
                                .font(AppTheme.title)
                                .foregroundColor(AppTheme.primaryColor)
                                .textCase(.uppercase)
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
                            Text("WRITE YOUR REVIEW")
                                .font(AppTheme.caption)
                                .foregroundColor(AppTheme.textColor)
                                .textCase(.uppercase)
                            
                            TextEditor(text: $review)
                                .font(.system(size: 16, design: .default))
                                .foregroundColor(AppTheme.textColor)
                                .frame(minHeight: 120)
                                .padding(AppTheme.smallSpacing)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                        .fill(AppTheme.backgroundColor)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                                .stroke(AppTheme.accentColor, lineWidth: 1)
                                        )
                                )
                        }
                    }
                    .padding(AppTheme.mediumSpacing)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.mediumCornerRadius)
                            .fill(Color.white)
                            .shadow(color: AppTheme.textColor.opacity(0.1), radius: 4, x: 2, y: 2)
                    )
                    
                    // Cover Image Card
                    VStack(spacing: AppTheme.mediumSpacing) {
                        HStack {
                            Text("COVER IMAGE")
                                .font(AppTheme.title)
                                .foregroundColor(AppTheme.primaryColor)
                                .textCase(.uppercase)
                            Spacer()
                        }
                        
                        HStack(spacing: AppTheme.mediumSpacing) {
                            // Current image preview
                            RoundedRectangle(cornerRadius: AppTheme.largeCornerRadius)
                                .fill(AppTheme.textColor)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Group {
                                        if originalGame.coverImage.hasPrefix("http") {
                                            AsyncImage(url: URL(string: originalGame.coverImage)) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            } placeholder: {
                                                Image(systemName: "gamepad.fill")
                                                    .font(.system(size: AppTheme.mediumIconSize, design: .monospaced))
                                                    .foregroundColor(.white)
                                            }
                                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.largeCornerRadius))
                                        } else {
                                            Image(systemName: originalGame.coverImage)
                                                .font(.system(size: AppTheme.mediumIconSize, design: .monospaced))
                                                .foregroundColor(.white)
                                        }
                                    }
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.largeCornerRadius)
                                        .stroke(AppTheme.accentColor, lineWidth: 2)
                                )
                            
                            VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
                                Text("CURRENT IMAGE")
                                    .font(AppTheme.body)
                                    .foregroundColor(AppTheme.textColor)
                                    .fontWeight(.bold)
                                
                                Text("Image upload coming soon")
                                    .font(AppTheme.caption)
                                    .foregroundColor(AppTheme.textColor.opacity(0.7))
                                    .textCase(.uppercase)
                            }
                            
                            Spacer()
                            
                            Button("CHANGE") {
                                showingImagePicker = true
                            }
                            .font(AppTheme.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppTheme.textColor.opacity(0.5))
                            .cornerRadius(AppTheme.smallCornerRadius)
                            .disabled(true) // Disabled for now
                        }
                    }
                    .padding(AppTheme.mediumSpacing)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.mediumCornerRadius)
                            .fill(Color.white)
                            .shadow(color: AppTheme.textColor.opacity(0.1), radius: 4, x: 2, y: 2)
                    )
                }
                .padding(.horizontal, AppTheme.largeSpacing)
                .padding(.top, AppTheme.mediumSpacing)
                .padding(.bottom, 40)
            }
            .background(AppTheme.backgroundColor)
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

// MARK: - Supporting Views
struct PixelTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
            Text(title)
                .font(AppTheme.caption)
                .foregroundColor(AppTheme.textColor)
                .textCase(.uppercase)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16, design: .default))
                .foregroundColor(AppTheme.textColor)
                .padding(AppTheme.smallSpacing)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                        .fill(AppTheme.backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                .stroke(AppTheme.accentColor, lineWidth: 1)
                        )
                )
        }
    }
}
