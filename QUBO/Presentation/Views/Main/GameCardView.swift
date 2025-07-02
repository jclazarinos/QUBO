// MARK: - Presentation/Views/Main/GameCardView.swift
import SwiftUI

struct GameCardView: View {
    let game: Game
    @ObservedObject var viewModel: GamesViewModel
    
    var body: some View {
        VStack(spacing: AppTheme.smallSpacing) {
            // Cover Image
            RoundedRectangle(cornerRadius: AppTheme.mediumCornerRadius)
                .fill(AppTheme.textColor)
                .frame(height: AppTheme.gameCardHeight)
                .overlay(
                    Image(systemName: game.coverImage)
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                )
            
            // Game Info
            VStack(spacing: 4) {
                Text(game.title)
                    .font(AppTheme.caption)
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text(game.platform)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(AppTheme.accentColor)
                    .padding(.horizontal, AppTheme.smallSpacing)
                    .padding(.vertical, 2)
                    .background(AppTheme.accentColor.opacity(0.1))
                    .cornerRadius(AppTheme.smallCornerRadius)
                
                Text(game.formattedDate)
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundColor(AppTheme.textColor)
                
                HStack(spacing: 2) {
                    ForEach(1...10, id: \.self) { index in
                        Image(systemName: index <= game.score ? "star.fill" : "star")
                            .font(.system(size: 8))
                            .foregroundColor(index <= game.score ? AppTheme.secondaryColor : .gray)
                    }
                }
                
                Button("VIEW REVIEW") {
                    viewModel.selectedGame = game
                }
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(AppTheme.primaryColor)
                .cornerRadius(AppTheme.smallCornerRadius)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(AppTheme.largeCornerRadius)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
