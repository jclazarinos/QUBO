// MARK: - Presentation/Views/Main/MainContentView.swift
import SwiftUI

struct MainContentView: View {
    @ObservedObject var viewModel: GamesViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Debug info (opcional - puedes removerlo después)
                if viewModel.games.count > 0 {
                    HStack {
                        Text("🎮 \(viewModel.games.count) games loaded")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if viewModel.isLoadingMore {
                            HStack(spacing: 4) {
                                ProgressView()
                                    .scaleEffect(0.6)
                                Text("Loading...")
                                    .font(.caption2)
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, AppTheme.largeSpacing)
                }
                
                if viewModel.viewType == .icons {
                    // Group by letter
                    ForEach(viewModel.groupedGames, id: \.0) { letter, games in
                        GameGroupView(letter: letter, games: games, viewModel: viewModel)
                            .onAppear {
                                // 🚀 Trigger lazy loading para modo icons
                                checkForLoadMoreInGroups(currentLetter: letter)
                            }
                    }
                } else {
                    // List view
                    ForEach(viewModel.sortedGames) { game in
                        GameListItemView(game: game, viewModel: viewModel)
                            .onAppear {
                                // 🚀 Trigger lazy loading para modo lista
                                checkForLoadMore(game: game)
                            }
                    }
                }
                
                // Loading indicator para más contenido
                if viewModel.isLoadingMore {
                    HStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading more games...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 16)
                }
                
                // Empty state if no games
                if viewModel.games.isEmpty && !viewModel.isLoading {
                    EmptyStateView(viewModel: viewModel)
                        .padding(.top, 60)
                }
            }
            .padding(.horizontal, AppTheme.largeSpacing)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .background(AppTheme.backgroundColor)
        .refreshable {
            viewModel.refreshGames()
        }
    }
    
    // MARK: - Lazy Loading Logic
    
    /// Detecta cuándo cargar más contenido en modo lista
    private func checkForLoadMore(game: Game) {
        guard let currentIndex = viewModel.sortedGames.firstIndex(where: { $0.id == game.id }) else {
            return
        }
        
        let totalGames = viewModel.sortedGames.count
        let threshold = max(1, totalGames - 3) // Cargar cuando falten 3 o menos
        
        if currentIndex >= threshold {
            print("🎯 Trigger load more: game \(currentIndex + 1)/\(totalGames)")
            viewModel.loadMoreGames()
        }
    }
    
    /// Detecta cuándo cargar más contenido en modo grupos
    private func checkForLoadMoreInGroups(currentLetter: String) {
        let groupedGames = viewModel.groupedGames
        if let lastGroup = groupedGames.last,
           lastGroup.0 == currentLetter {
            print("🎯 Trigger load more: last group '\(currentLetter)' appeared")
            viewModel.loadMoreGames()
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
