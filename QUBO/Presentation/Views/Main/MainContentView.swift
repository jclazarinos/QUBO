// MARK: - Presentation/Views/Main/MainContentView.swift
import SwiftUI

struct MainContentView: View {
    @ObservedObject var viewModel: GamesViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("COMPLETED GAMES")
                    .font(AppTheme.largeTitle)
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("\(viewModel.totalGamesCount) games")
                    .font(AppTheme.caption)
                    .foregroundColor(AppTheme.textColor)
            }
            .padding(.horizontal, AppTheme.largeSpacing)
            .padding(.vertical, 20)
            .background(AppTheme.backgroundColor)
            
            // Games Content
            ScrollView {
                LazyVStack(spacing: 20) {
                    if viewModel.viewType == .icons {
                        // Group by letter
                        ForEach(viewModel.groupedGames, id: \.0) { letter, games in
                            GameGroupView(letter: letter, games: games, viewModel: viewModel)
                        }
                    } else {
                        // List view
                        ForEach(viewModel.sortedGames) { game in
                            GameListItemView(game: game, viewModel: viewModel)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.largeSpacing)
                .padding(.top, 20)
            }
            .background(AppTheme.backgroundColor)
        }
    }
}
