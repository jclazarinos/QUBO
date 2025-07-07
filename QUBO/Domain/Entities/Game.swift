// MARK: - Domain/Entities/Game.swift
import Foundation

struct Game: Identifiable, Hashable {
    let id: Int
    let title: String
    let platform: String
    let completionDate: Date
    let score: Int
    let coverImage: String
    let review: String
    
    // NUEVOS CAMPOS AGREGADOS
    let description: String
    let trailer: String?
    let gameStatus: String
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: completionDate)
    }
    
    var formattedYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: completionDate)
    }
    
    var firstLetter: String {
        String(title.prefix(1).uppercased())
    }
    
    // Verificar si tiene trailer válido
    var hasTrailer: Bool {
        guard let trailer = trailer else { return false }
        return !trailer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Extraer ID de video de YouTube
    var youtubeVideoId: String? {
        guard let trailer = trailer else { return nil }
        
        // Patrones comunes de URLs de YouTube
        let patterns = [
            "(?:youtube\\.com/watch\\?v=|youtu\\.be/|youtube\\.com/embed/)([a-zA-Z0-9_-]{11})",
            "(?:youtube\\.com/watch\\?.*&v=)([a-zA-Z0-9_-]{11})"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(location: 0, length: trailer.utf16.count)
                if let match = regex.firstMatch(in: trailer, options: [], range: range) {
                    if let videoIdRange = Range(match.range(at: 1), in: trailer) {
                        return String(trailer[videoIdRange])
                    }
                }
            }
        }
        return nil
    }
    
    // URL de thumbnail de YouTube
    var youtubeThumbnailURL: String? {
        guard let videoId = youtubeVideoId else { return nil }
        return "https://img.youtube.com/vi/\(videoId)/maxresdefault.jpg"
    }
    
    // Inicializador para crear juegos nuevos (sin ID de API)
    init(title: String, platform: String, completionDate: Date, score: Int, coverImage: String, review: String, description: String = "", trailer: String? = nil, gameStatus: String = "Completed") {
        self.id = Int.random(in: 1000...9999)
        self.title = title
        self.platform = platform
        self.completionDate = completionDate
        self.score = score
        self.coverImage = coverImage
        self.review = review
        self.description = description
        self.trailer = trailer
        self.gameStatus = gameStatus
    }
    
    // Inicializador completo (incluye ID de API)
    init(id: Int, title: String, platform: String, completionDate: Date, score: Int, coverImage: String, review: String, description: String = "", trailer: String? = nil, gameStatus: String = "Completed") {
        self.id = id
        self.title = title
        self.platform = platform
        self.completionDate = completionDate
        self.score = score
        self.coverImage = coverImage
        self.review = review
        self.description = description
        self.trailer = trailer
        self.gameStatus = gameStatus
    }
}
