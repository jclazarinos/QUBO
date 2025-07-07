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
    
    // REEMPLAZAR tu método getGames() en RemoteGameDataSource.swift con este:
    func getGames(page: Int, perPage: Int, sortOption: SortOption = .alphabetical) async throws -> [Game] {
        return try await apiService.getGames(page: page, perPage: perPage, sortOption: sortOption)
    }
    
    func createGame(_ game: Game, mediaId: Int? = nil) async throws -> Game {
        return try await apiService.createGame(game, mediaId: mediaId)
    }

    func updateGame(_ game: Game, mediaId: Int? = nil) async throws -> Game {
        return try await apiService.updateGame(game, mediaId: mediaId)
    }
    
    func deleteGame(withId id: Int) async throws {
        try await apiService.deleteGame(withId: id)
    }
}
