// MARK: - QUBOApp.swift
import SwiftUI

@main
struct QUBOApp: App {
    // MARK: - Dependency Injection
    private let localDataSource = LocalGameDataSource()
    private let remoteDataSource = RemoteGameDataSource()
    
    // Hacer gameRepository computed property en lugar de lazy
    private var gameRepository: GameRepository {
        GameRepository(
            localDataSource: localDataSource,
            remoteDataSource: remoteDataSource
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(createGamesViewModel())
        }
    }
    
    @MainActor
    private func createGamesViewModel() -> GamesViewModel {
        let gameUseCases = GameUseCases(repository: gameRepository)
        return GamesViewModel(gameUseCases: gameUseCases)
    }
}
