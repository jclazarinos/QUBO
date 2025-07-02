// MARK: - Data/DataSources/LocalGameDataSource.swift
import Foundation

protocol LocalGameDataSourceProtocol {
    func getGames() -> [Game]
    func saveGames(_ games: [Game])
}

class LocalGameDataSource: LocalGameDataSourceProtocol {
    private var games: [Game] = []
    
    init() {
        loadSampleData()
    }
    
    func getGames() -> [Game] {
        return games
    }
    
    func saveGames(_ games: [Game]) {
        self.games = games
    }
    
    private func loadSampleData() {
        games = [
            Game(
                id: 1001, // IDs temporales para datos locales
                title: "Chrono Trigger",
                platform: "SNES",
                completionDate: Date().addingTimeInterval(-86400 * 30),
                score: 10,
                coverImage: "gamepad.fill",
                review: "A timeless masterpiece that combines exceptional narrative with innovative combat mechanics. Time travel is perfectly integrated into the story, creating epic moments that remain in memory."
            ),
            Game(
                id: 1002,
                title: "Final Fantasy VII",
                platform: "PSX",
                completionDate: Date().addingTimeInterval(-86400 * 15),
                score: 9,
                coverImage: "gamepad.fill",
                review: "A revolutionary RPG that marked an era. The story of Cloud and Sephiroth remains one of the most memorable in video games, with graphics that were groundbreaking for their time."
            ),
            Game(
                id: 1003,
                title: "Castlevania: Symphony of the Night",
                platform: "PSX",
                completionDate: Date().addingTimeInterval(-86400 * 60),
                score: 10,
                coverImage: "gamepad.fill",
                review: "Metroidvania perfection. Every corner of Dracula's castle is full of secrets, and character progression is addictive. Exceptional soundtrack."
            ),
            Game(
                id: 1004,
                title: "Super Metroid",
                platform: "SNES",
                completionDate: Date().addingTimeInterval(-86400 * 45),
                score: 9,
                coverImage: "gamepad.fill",
                review: "Masterful level design and unique atmosphere. The feeling of exploration and discovery is unmatched, setting the standard for future metroidvanias."
            ),
            Game(
                id: 1005,
                title: "Bonk's Adventure",
                platform: "PC-Engine",
                completionDate: Date().addingTimeInterval(-86400 * 20),
                score: 7,
                coverImage: "gamepad.fill",
                review: "A fun and colorful platformer with unique personality. While it doesn't revolutionize the genre, it offers hours of solid entertainment."
            )
        ]
    }
}
