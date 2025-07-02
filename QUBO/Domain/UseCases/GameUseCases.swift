// MARK: - Domain/UseCases/GameUseCases.swift
import Foundation

class GameUseCases {
    private let repository: GameRepositoryProtocol
    
    init(repository: GameRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Async Methods (for API operations)
    func getAllGames() async throws -> [Game] {
        return try await repository.getAllGames()
    }
    
    func getSortedGames(by sortOption: SortOption) async throws -> [Game] {
        let games = try await repository.getAllGames()
        
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
    
    func getGroupedGames(by sortOption: SortOption) async throws -> [(String, [Game])] {
        let sortedGames = try await getSortedGames(by: sortOption)
        let grouped = Dictionary(grouping: sortedGames) { $0.firstLetter }
        return grouped.sorted { $0.key < $1.key }
    }
    
    func addGame(_ game: Game) async throws -> Game {
        return try await repository.addGame(game)
    }
    
    func updateGame(_ game: Game) async throws -> Game {
        return try await repository.updateGame(game)
    }
    
    func deleteGame(withId id: Int) async throws {
        try await repository.deleteGame(withId: id)
    }
    
    func getTotalGamesCount() async throws -> Int {
        let games = try await repository.getAllGames()
        return games.count
    }
    
    // MARK: - Configuration
    func setUseRemoteData(_ useRemote: Bool) {
        if let gameRepository = repository as? GameRepository {
            gameRepository.setUseRemoteData(useRemote)
        }
    }
}
