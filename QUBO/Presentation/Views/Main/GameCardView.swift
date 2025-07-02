// MARK: - Presentation/Views/Main/GameCardView.swift
import SwiftUI

struct GameCardView: View {
    let game: Game
    @ObservedObject var viewModel: GamesViewModel
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Cover Image Container
            ZStack(alignment: .bottomLeading) {
                // Background Image
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppTheme.textColor.opacity(0.8),
                                AppTheme.textColor
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        Group {
                            if game.coverImage.hasPrefix("http") {
                                AsyncImage(url: URL(string: game.coverImage)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Image(systemName: "gamepad.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            } else {
                                Image(systemName: game.coverImage)
                                    .font(.system(size: 50))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                    )
                
                // Platform Badge
                Text(game.platform.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(AppTheme.primaryColor.opacity(0.9))
                    )
                    .padding(8)
            }
            .frame(height: 160)
            .clipped()
            
            // Game Info Section
            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(game.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.textColor)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Date
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.textColor.opacity(0.6))
                    
                    Text("Año: \(game.formattedDate)")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(AppTheme.textColor.opacity(0.8))
                }
                
                // Score
                HStack(spacing: 4) {
                    Text("Score:")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(AppTheme.textColor.opacity(0.8))
                    
                    Text("\(game.score)/10")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.primaryColor)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isHovered ? AppTheme.accentColor : Color.clear, lineWidth: 2)
        )
        .shadow(
            color: isHovered ? AppTheme.primaryColor.opacity(0.3) : Color.black.opacity(0.1),
            radius: isHovered ? 8 : 4,
            x: 0,
            y: isHovered ? 4 : 2
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            viewModel.selectedGame = game
        }
    }
}

// MARK: - Alternative Compact Version
struct GameCardCompactView: View {
    let game: Game
    @ObservedObject var viewModel: GamesViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            // Cover Image
            Rectangle()
                .fill(AppTheme.textColor)
                .frame(width: 60, height: 80)
                .overlay(
                    Group {
                        if game.coverImage.hasPrefix("http") {
                            AsyncImage(url: URL(string: game.coverImage)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "gamepad.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                        } else {
                            Image(systemName: game.coverImage)
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                    }
                )
                .clipped()
            
            // Info Section
            VStack(alignment: .leading, spacing: 4) {
                Text(game.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textColor)
                    .lineLimit(1)
                
                Text(game.platform)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.accentColor)
                
                HStack(spacing: 8) {
                    Text("Año: \(game.formattedDate)")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.textColor.opacity(0.7))
                    
                    Text("Score: \(game.score)/10")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppTheme.primaryColor)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            Spacer()
        }
        .frame(height: 80)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
        .onTapGesture {
            viewModel.selectedGame = game
        }
    }
}
