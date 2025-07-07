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
    
    func addGame(_ game: Game, mediaId: Int? = nil) async throws -> Game {
        if useRemoteData {
            do {
                // Crear en la API con mediaId
                let createdGame = try await remoteDataSource.createGame(game, mediaId: mediaId)
                
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

    func updateGame(_ game: Game, mediaId: Int? = nil) async throws -> Game {
        if useRemoteData {
            do {
                // Actualizar en la API con mediaId
                let updatedGame = try await remoteDataSource.updateGame(game, mediaId: mediaId)
                
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
    
    // REEMPLAZAR tu método getGames() existente con este:
    func getGames(page: Int, perPage: Int, sortOption: SortOption = .alphabetical) async throws -> [Game] {
        if useRemoteData {
            do {
                // Intentar hacer login si no está autenticado
                try await remoteDataSource.login()
                
                // Obtener juegos de la API con paginación y ordenamiento
                let games = try await remoteDataSource.getGames(page: page, perPage: perPage, sortOption: sortOption)
                
                // Si es la primera página, guardar en local como backup
                if page == 1 {
                    localDataSource.saveGames(games)
                }
                
                return games
            } catch {
                print("Error fetching page \(page) from API: \(error)")
                // Si falla la API y es la primera página, usar datos locales
                if page == 1 {
                    return localDataSource.getGames()
                } else {
                    // Para páginas > 1, no hay fallback local
                    throw error
                }
            }
        } else {
            // Para datos locales, simular paginación con ordenamiento
            let allGames = localDataSource.getGames()
            
            // Aplicar ordenamiento localmente
            let sortedGames: [Game]
            switch sortOption {
            case .alphabetical:
                sortedGames = allGames.sorted { $0.title < $1.title }
            case .score:
                sortedGames = allGames.sorted { $0.score > $1.score }
            case .year:
                sortedGames = allGames.sorted { $0.completionDate > $1.completionDate }
            case .platform:
                sortedGames = allGames.sorted { $0.platform < $1.platform }
            }
            
            let startIndex = (page - 1) * perPage
            let endIndex = min(startIndex + perPage, sortedGames.count)
            
            guard startIndex < sortedGames.count else {
                return []
            }
            
            return Array(sortedGames[startIndex..<endIndex])
        }
    }
    
    // MARK: - Configuration
    func setUseRemoteData(_ useRemote: Bool) {
        self.useRemoteData = useRemote
    }
}
