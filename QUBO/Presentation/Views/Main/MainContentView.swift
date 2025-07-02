// MARK: - Presentation/Views/Main/MainContentView.swift
import SwiftUI

struct MainContentView: View {
    @ObservedObject var viewModel: GamesViewModel
    
    var body: some View {
        // Games Content (removed header since it's now in TopBar)
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
                
                // Empty state if no games
                if viewModel.games.isEmpty && !viewModel.isLoading {
                    EmptyStateView(viewModel: viewModel)
                        .padding(.top, 60)
                }
            }
            .padding(.horizontal, AppTheme.largeSpacing)
            .padding(.top, 20)
            .padding(.bottom, 40) // Extra bottom padding for safe area
        }
        .background(AppTheme.backgroundColor)
        .refreshable {
            viewModel.refreshGames()
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    @ObservedObject var viewModel: GamesViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "gamecontroller")
                .font(.system(size: 64))
                .foregroundColor(AppTheme.textColor.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Games Yet")
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                Text("Add your first completed game to get started")
                    .font(.body)
                    .foregroundColor(AppTheme.textColor)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                viewModel.showingAddGame = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add First Game")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(AppTheme.primaryColor)
                .cornerRadius(AppTheme.mediumCornerRadius)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
    }
}
