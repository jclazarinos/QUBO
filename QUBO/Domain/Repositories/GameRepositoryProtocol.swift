// MARK: - Domain/Repositories/GameRepositoryProtocol.swift
import Foundation

protocol GameRepositoryProtocol {
    func getAllGames() async throws -> [Game]
    func addGame(_ game: Game) async throws -> Game
    func updateGame(_ game: Game) async throws -> Game
    func deleteGame(withId id: Int) async throws
}

// MARK: - Data/DataSources/RemoteGameDataSourceProtocol.swift
import Foundation

protocol RemoteGameDataSourceProtocol {
    func getAllGames() async throws -> [Game]
    func getGameById(_ id: Int) async throws -> Game?
    func createGame(_ game: Game) async throws -> Game
    func updateGame(_ game: Game) async throws -> Game
    func deleteGame(withId id: Int) async throws
    func login() async throws
}

// MARK: - Data/DataSources/RemoteGameDataSource.swift
import Foundation

class RemoteGameDataSource: RemoteGameDataSourceProtocol {
    private let apiService = APIService.shared
    
    func login() async throws {
        _ = try await apiService.login()
    }
    
    func getAllGames() async throws -> [Game] {
        return try await apiService.getAllGames()
    }
    
    func getGameById(_ id: Int) async throws -> Game? {
        return try await apiService.getGameById(id)
    }
    
    func createGame(_ game: Game) async throws -> Game {
        return try await apiService.createGame(game)
    }
    
    func updateGame(_ game: Game) async throws -> Game {
        return try await apiService.updateGame(game)
    }
    
    func deleteGame(withId id: Int) async throws {
        try await apiService.deleteGame(withId: id)
    }
}
