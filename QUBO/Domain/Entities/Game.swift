// MARK: - Domain/Entities/Game.swift
import Foundation

struct Game: Identifiable, Hashable {
    let id: Int // Cambiado de UUID a Int para compatibilidad con WordPress API
    let title: String
    let platform: String
    let completionDate: Date
    let score: Int
    let coverImage: String
    let review: String
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: completionDate)
    }
    
    var firstLetter: String {
        String(title.prefix(1).uppercased())
    }
    
    // Inicializador para crear juegos nuevos (sin ID de API)
    init(title: String, platform: String, completionDate: Date, score: Int, coverImage: String, review: String) {
        self.id = Int.random(in: 1000...9999) // ID temporal para juegos locales
        self.title = title
        self.platform = platform
        self.completionDate = completionDate
        self.score = score
        self.coverImage = coverImage
        self.review = review
    }
    
    // Inicializador completo (incluye ID de API)
    init(id: Int, title: String, platform: String, completionDate: Date, score: Int, coverImage: String, review: String) {
        self.id = id
        self.title = title
        self.platform = platform
        self.completionDate = completionDate
        self.score = score
        self.coverImage = coverImage
        self.review = review
    }
}
