// MARK: - Presentation/ViewModels/GamesViewModel.swift
import Foundation
import SwiftUI

@MainActor
class GamesViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var sortOption: SortOption = .alphabetical
    @Published var viewType: ViewType = .icons
    @Published var selectedTheme: Theme = .games
    @Published var showingAddGame = false
    @Published var selectedGame: Game?
    
    // MARK: - API State Management
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var useRemoteAPI = true {
        didSet {
            gameUseCases.setUseRemoteData(useRemoteAPI)
            refreshGames()
        }
    }
    
    private let gameUseCases: GameUseCases
    
    init(gameUseCases: GameUseCases) {
        self.gameUseCases = gameUseCases
        loadGames()
    }
    
    // MARK: - Computed Properties
    var sortedGames: [Game] {
        switch sortOption {
        case .alphabetical:
            return games.sorted { $0.title < $1.title }
        case .score:
            return games.sorted { $0.score > $1.score }
        case .year:
            return games.sorted { $0.completionDate > $1.completionDate }
        case .platform:
            return games.sorted { $0.platform < $1.platform }
        }
    }
    
    var groupedGames: [(String, [Game])] {
        let grouped = Dictionary(grouping: sortedGames) { $0.firstLetter }
        return grouped.sorted { $0.key < $1.key }
    }
    
    var totalGamesCount: Int {
        return games.count
    }
    
    // MARK: - Game Operations
    func addGame(_ game: Game) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let createdGame = try await gameUseCases.addGame(game)
                // No need for MainActor.run since we're already on MainActor
                self.games.append(createdGame)
                self.isLoading = false
                self.showingAddGame = false
            } catch {
                self.errorMessage = "Error adding game: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func updateGame(_ game: Game) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let updatedGame = try await gameUseCases.updateGame(game)
                if let index = self.games.firstIndex(where: { $0.id == updatedGame.id }) {
                    self.games[index] = updatedGame
                }
                self.isLoading = false
            } catch {
                self.errorMessage = "Error updating game: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func deleteGame(withId id: Int) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await gameUseCases.deleteGame(withId: id)
                self.games.removeAll { $0.id == id }
                self.isLoading = false
            } catch {
                self.errorMessage = "Error deleting game: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func loadGames() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedGames = try await gameUseCases.getAllGames()
                self.games = fetchedGames
                self.isLoading = false
            } catch {
                self.errorMessage = "Error loading games: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func refreshGames() {
        loadGames()
    }
    
    // MARK: - Error Handling
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Legacy Support
    func deleteGame(withId id: UUID) {
        // Convert UUID to Int if needed, or handle legacy calls
        // For now, we'll search by title since UUID conversion isn't straightforward
        if let game = games.first(where: { $0.title.hashValue == id.hashValue }) {
            deleteGame(withId: game.id)
        }
    }
}
