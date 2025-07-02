// MARK: - Presentation/Views/Main/GameGroupView.swift
import SwiftUI

struct GameGroupView: View {
    let letter: String
    let games: [Game]
    @ObservedObject var viewModel: GamesViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(letter)
                .font(AppTheme.title)
                .foregroundColor(AppTheme.primaryColor)
                .padding(.leading, 4)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: AppTheme.mediumSpacing), count: 3), spacing: AppTheme.mediumSpacing) {
                ForEach(games) { game in
                    GameCardView(game: game, viewModel: viewModel)
                }
            }
        }
    }
}
