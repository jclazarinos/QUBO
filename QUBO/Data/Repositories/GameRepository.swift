// MARK: - Data/Repositories/GameRepository.swift
import Foundation

class GameRepository: GameRepositoryProtocol {
    private let localDataSource: LocalGameDataSourceProtocol
    private let remoteDataSource: RemoteGameDataSourceProtocol
    private var useRemoteData: Bool = true
    
    init(localDataSource: LocalGameDataSourceProtocol, remoteDataSource: RemoteGameDataSourceProtocol) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }
    
    func getAllGames() async throws -> [Game] {
        if useRemoteData {
            do {
                // Intentar hacer login si no está autenticado
                try await remoteDataSource.login()
                
                // Obtener juegos de la API
                let games = try await remoteDataSource.getAllGames()
                
                // Guardar en local como backup
                localDataSource.saveGames(games)
                
                return games
            } catch {
                print("Error fetching from API, falling back to local data: \(error)")
                // Si falla la API, usar datos locales
                return localDataSource.getGames()
            }
        } else {
            return localDataSource.getGames()
        }
    }
    
    func addGame(_ game: Game) async throws -> Game {
        if useRemoteData {
            do {
                // Crear en la API
                let createdGame = try await remoteDataSource.createGame(game)
                
                // Actualizar datos locales
                var games = localDataSource.getGames()
                games.append(createdGame)
                localDataSource.saveGames(games)
                
                return createdGame
            } catch {
                print("Error creating game in API: \(error)")
                // Fallback a local
                var games = localDataSource.getGames()
                games.append(game)
                localDataSource.saveGames(games)
                return game
            }
        } else {
            var games = localDataSource.getGames()
            games.append(game)
            localDataSource.saveGames(games)
            return game
        }
    }
    
    func updateGame(_ game: Game) async throws -> Game {
        if useRemoteData {
            do {
                // Actualizar en la API
                let updatedGame = try await remoteDataSource.updateGame(game)
                
                // Actualizar datos locales
                var games = localDataSource.getGames()
                if let index = games.firstIndex(where: { $0.id == updatedGame.id }) {
                    games[index] = updatedGame
                    localDataSource.saveGames(games)
                }
                
                return updatedGame
            } catch {
                print("Error updating game in API: \(error)")
                // Fallback a local
                var games = localDataSource.getGames()
                if let index = games.firstIndex(where: { $0.id == game.id }) {
                    games[index] = game
                    localDataSource.saveGames(games)
                }
                return game
            }
        } else {
            var games = localDataSource.getGames()
            if let index = games.firstIndex(where: { $0.id == game.id }) {
                games[index] = game
                localDataSource.saveGames(games)
            }
            return game
        }
    }
    
    func deleteGame(withId id: Int) async throws {
        if useRemoteData {
            do {
                // Eliminar de la API
                try await remoteDataSource.deleteGame(withId: id)
                
                // Eliminar de datos locales
                var games = localDataSource.getGames()
                games.removeAll { $0.id == id }
                localDataSource.saveGames(games)
            } catch {
                print("Error deleting game from API: \(error)")
                // Fallback a local
                var games = localDataSource.getGames()
                games.removeAll { $0.id == id }
                localDataSource.saveGames(games)
            }
        } else {
            var games = localDataSource.getGames()
            games.removeAll { $0.id == id }
            localDataSource.saveGames(games)
        }
    }
    
    // MARK: - Configuration
    func setUseRemoteData(_ useRemote: Bool) {
        self.useRemoteData = useRemote
    }
}
