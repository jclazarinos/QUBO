// MARK: - Domain/Repositories/GameRepositoryProtocol.swift
import Foundation

protocol GameRepositoryProtocol {
    func getAllGames() async throws -> [Game]
    func getGames(page: Int, perPage: Int, sortOption: SortOption) async throws -> [Game]
    func addGame(_ game: Game, mediaId: Int?) async throws -> Game  // ← SIN = nil
    func updateGame(_ game: Game, mediaId: Int?) async throws -> Game  // ← SIN = nil
    func deleteGame(withId id: Int) async throws
}

// MARK: - Data/DataSources/RemoteGameDataSourceProtocol.swift
import Foundation

protocol RemoteGameDataSourceProtocol {
    func getAllGames() async throws -> [Game]
    func getGames(page: Int, perPage: Int, sortOption: SortOption) async throws -> [Game]
    func getGameById(_ id: Int) async throws -> Game?
    func createGame(_ game: Game, mediaId: Int?) async throws -> Game  // ← SIN = nil
    func updateGame(_ game: Game, mediaId: Int?) async throws -> Game  // ← SIN = nil
    func deleteGame(withId id: Int) async throws
    func login() async throws
}
