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
            // Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("REVIEW")
                    .font(AppTheme.largeTitle)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Options menu
                Menu {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Edit Game", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete Game", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, AppTheme.largeSpacing)
            .padding(.vertical, 20)
            .background(AppTheme.primaryColor)
            
            ScrollView {
                VStack(spacing: AppTheme.largeSpacing) {
                    // Game Header
                    HStack(spacing: AppTheme.mediumSpacing) {
                        RoundedRectangle(cornerRadius: AppTheme.largeCornerRadius)
                            .fill(AppTheme.textColor)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Group {
                                    if game.coverImage.hasPrefix("http") {
                                        // AsyncImage for URL
                                        AsyncImage(url: URL(string: game.coverImage)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            Image(systemName: "gamepad.fill")
                                                .font(.system(size: AppTheme.mediumIconSize))
                                                .foregroundColor(.white)
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.largeCornerRadius))
                                    } else {
                                        // SF Symbol
                                        Image(systemName: game.coverImage)
                                            .font(.system(size: AppTheme.mediumIconSize))
                                            .foregroundColor(.white)
                                    }
                                }
                            )
                        
                        VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
                            Text(game.title)
                                .font(AppTheme.title)
                                .foregroundColor(.black)
                                .lineLimit(2)
                            
                            Text(game.platform)
                                .font(AppTheme.body)
                                .foregroundColor(AppTheme.accentColor)
                            
                            Text(game.formattedDate)
                                .font(AppTheme.caption)
                                .foregroundColor(AppTheme.textColor)
                            
                            // Score with stars
                            HStack(spacing: 4) {
                                ForEach(1...10, id: \.self) { index in
                                    Image(systemName: index <= game.score ? "star.fill" : "star")
                                        .font(.system(size: 12))
                                        .foregroundColor(index <= game.score ? AppTheme.secondaryColor : .gray)
                                }
                                
                                Text("\(game.score)/10")
                                    .font(AppTheme.caption)
                                    .foregroundColor(AppTheme.secondaryColor)
                                    .padding(.leading, AppTheme.smallSpacing)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // Review Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("MY REVIEW")
                                .font(AppTheme.body)
                                .foregroundColor(AppTheme.primaryColor)
                            
                            Spacer()
                            
                            Button {
                                showingEditSheet = true
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(AppTheme.accentColor)
                            }
                        }
                        
                        Text(game.review)
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(.black)
                            .lineSpacing(4)
                            .padding(.top, 8)
                    }
                    
                    // Game Stats (if needed)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("GAME INFO")
                            .font(AppTheme.body)
                            .foregroundColor(AppTheme.primaryColor)
                        
                        VStack(spacing: 8) {
                            InfoRow(title: "Platform", value: game.platform)
                            InfoRow(title: "Completed", value: game.formattedDate)
                            InfoRow(title: "Score", value: "\(game.score)/10")
                            InfoRow(title: "Game ID", value: "#\(game.id)")
                        }
                    }
                }
                .padding(.horizontal, AppTheme.largeSpacing)
                .padding(.top, AppTheme.largeSpacing)
                .padding(.bottom, 40)
            }
            .background(AppTheme.backgroundColor)
        }
        .sheet(isPresented: $showingEditSheet) {
            EditGameView(game: game, viewModel: viewModel)
        }
        .alert("Delete Game", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteGame()
            }
        } message: {
            Text("Are you sure you want to delete '\(game.title)'? This action cannot be undone.")
        }
    }
    
    private func deleteGame() {
        viewModel.deleteGame(withId: game.id)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Supporting Views
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(AppTheme.textColor)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.caption)
                .foregroundColor(.black)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
