// MARK: - Presentation/Views/Main/GameListItemView.swift
import SwiftUI

struct GameListItemView: View {
    let game: Game
    @ObservedObject var viewModel: GamesViewModel
    
    var body: some View {
        HStack(spacing: AppTheme.mediumSpacing) {
            // Cover Image - ACTUALIZADA
            AsyncImage(url: URL(string: game.coverImage)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(6)
            } placeholder: {
                RoundedRectangle(cornerRadius: 6)
                    .fill(AppTheme.textColor)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    )
            }
            .frame(width: 60, height: 60)
            
            // Game Info
            VStack(alignment: .leading, spacing: 4) {
                Text(game.title)
                    .font(AppTheme.body)
                    .foregroundColor(.black)
                
                Text(game.platform)
                    .font(AppTheme.caption)
                    .foregroundColor(AppTheme.accentColor)
                
                Text(game.formattedDate)
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundColor(AppTheme.textColor)
            }
            
            Spacer()
            
            // Score and Review Button
            VStack(spacing: AppTheme.smallSpacing) {
                Text("\(game.score)/10")
                    .font(AppTheme.body)
                    .foregroundColor(AppTheme.secondaryColor)
                
                Button("REVIEW") {
                    viewModel.selectedGame = game
                }
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, AppTheme.smallSpacing)
                .padding(.vertical, 4)
                .background(AppTheme.primaryColor)
                .cornerRadius(AppTheme.smallCornerRadius)
            }
        }
        .padding(AppTheme.mediumSpacing)
        .background(Color.white)
        .cornerRadius(AppTheme.largeCornerRadius)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
