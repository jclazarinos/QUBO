// MARK: - Presentation/Views/Modals/GameDetailView.swift
import SwiftUI

struct GameDetailView: View {
    let game: Game
    @ObservedObject var viewModel: GamesViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Retro Style - IMPROVED LAYOUT
            ZStack {
                // Background with pattern
                AppTheme.primaryColor
                    .overlay(
                        // Subtle pixel pattern
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.1),
                                        Color.clear
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                
                HStack(spacing: AppTheme.mediumSpacing) {
                    // Close Button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                    .fill(Color.white.opacity(0.2))
                            )
                    }
                    
                    // Title - Centered with overlay for better layout
                    Color.clear
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Text("GAME REVIEW")
                                .font(AppTheme.title)
                                .foregroundColor(.white)
                                .textCase(.uppercase)
                        )
                    
                    // Options Menu
                    Menu {
                        Button {
                            showingEditSheet = true
                        } label: {
                            Label("EDIT GAME", systemImage: "pencil")
                                .font(AppTheme.body)
                        }
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("DELETE GAME", systemImage: "trash")
                                .font(AppTheme.body)
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                    .fill(Color.white.opacity(0.2))
                            )
                    }
                }
                .padding(.horizontal, AppTheme.largeSpacing)
                .padding(.vertical, AppTheme.mediumSpacing)
            }
            .frame(height: 64) // Fixed height for consistency
            
            ScrollView {
                VStack(spacing: AppTheme.largeSpacing) {
                    // Game Header Card
                    VStack(spacing: AppTheme.mediumSpacing) {
                        HStack(spacing: AppTheme.mediumSpacing) {
                            // Game Cover
                            RoundedRectangle(cornerRadius: AppTheme.largeCornerRadius)
                                .fill(AppTheme.textColor)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Group {
                                        if game.coverImage.hasPrefix("http") {
                                            AsyncImage(url: URL(string: game.coverImage)) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            } placeholder: {
                                                Image(systemName: "gamepad.fill")
                                                    .font(.system(size: AppTheme.largeIconSize, design: .monospaced))
                                                    .foregroundColor(.white)
                                            }
                                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.largeCornerRadius))
                                        } else {
                                            Image(systemName: game.coverImage)
                                                .font(.system(size: AppTheme.largeIconSize, design: .monospaced))
                                                .foregroundColor(.white)
                                        }
                                    }
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.largeCornerRadius)
                                        .stroke(AppTheme.accentColor, lineWidth: 2)
                                )
                            
                            // Game Info
                            VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
                                Text(game.title.uppercased())
                                    .font(AppTheme.title)
                                    .foregroundColor(AppTheme.primaryColor)
                                    .lineLimit(2)
                                
                                Text(game.platform.uppercased())
                                    .font(AppTheme.body)
                                    .foregroundColor(AppTheme.accentColor)
                                
                                Text("COMPLETED: \(game.formattedDate.uppercased())")
                                    .font(AppTheme.caption)
                                    .foregroundColor(AppTheme.textColor)
                                
                                // Pixel-style Score
                                HStack(spacing: 6) {
                                    Text("SCORE:")
                                        .font(AppTheme.caption)
                                        .foregroundColor(AppTheme.textColor)
                                    
                                    HStack(spacing: 2) {
                                        ForEach(1...10, id: \.self) { index in
                                            Rectangle()
                                                .fill(index <= game.score ? AppTheme.secondaryColor : AppTheme.textColor.opacity(0.3))
                                                .frame(width: 8, height: 8)
                                        }
                                    }
                                    
                                    Text("\(game.score)/10")
                                        .font(AppTheme.body)
                                        .foregroundColor(AppTheme.secondaryColor)
                                        .fontWeight(.bold)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(AppTheme.mediumSpacing)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.mediumCornerRadius)
                            .fill(Color.white)
                            .shadow(color: AppTheme.textColor.opacity(0.1), radius: 4, x: 2, y: 2)
                    )
                    
                    // Review Section
                    VStack(spacing: AppTheme.mediumSpacing) {
                        HStack {
                            Text("MY REVIEW")
                                .font(AppTheme.title)
                                .foregroundColor(AppTheme.primaryColor)
                                .textCase(.uppercase)
                            
                            Spacer()
                            
                            Button {
                                showingEditSheet = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 12, design: .monospaced))
                                    Text("EDIT")
                                        .font(AppTheme.caption)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppTheme.accentColor)
                                .cornerRadius(AppTheme.smallCornerRadius)
                            }
                        }
                        
                        Text(game.review)
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(AppTheme.textColor)
                            .lineSpacing(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(AppTheme.mediumSpacing)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.mediumCornerRadius)
                            .fill(Color.white)
                            .shadow(color: AppTheme.textColor.opacity(0.1), radius: 4, x: 2, y: 2)
                    )
                    
                    // Game Stats Card
                    VStack(spacing: AppTheme.mediumSpacing) {
                        HStack {
                            Text("GAME DATA")
                                .font(AppTheme.title)
                                .foregroundColor(AppTheme.primaryColor)
                                .textCase(.uppercase)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: AppTheme.smallSpacing) {
                            PixelInfoRow(title: "PLATFORM", value: game.platform.uppercased())
                            PixelInfoRow(title: "COMPLETED", value: game.formattedDate.uppercased())
                            PixelInfoRow(title: "RATING", value: "\(game.score)/10")
                            PixelInfoRow(title: "GAME ID", value: "#\(String(format: "%04d", game.id))")
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
        .sheet(isPresented: $showingEditSheet) {
            EditGameView(game: game, viewModel: viewModel)
        }
        .alert("DELETE GAME", isPresented: $showingDeleteAlert) {
            Button("CANCEL", role: .cancel) { }
            Button("DELETE", role: .destructive) {
                deleteGame()
            }
        } message: {
            Text("Are you sure you want to delete '\(game.title.uppercased())'? This action cannot be undone.")
                .font(AppTheme.body)
        }
    }
    
    private func deleteGame() {
        viewModel.deleteGame(withId: game.id)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Supporting Views
struct PixelInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppTheme.caption)
                .foregroundColor(AppTheme.textColor)
                .frame(width: 100, alignment: .leading)
            
            Rectangle()
                .fill(AppTheme.textColor.opacity(0.3))
                .frame(height: 1)
                .frame(maxWidth: .infinity)
            
            Text(value)
                .font(AppTheme.body)
                .foregroundColor(AppTheme.primaryColor)
                .fontWeight(.bold)
        }
        .padding(.horizontal, AppTheme.smallSpacing)
        .padding(.vertical, AppTheme.smallSpacing)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                .fill(AppTheme.backgroundColor)
        )
    }
}
