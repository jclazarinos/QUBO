// MARK: - Data/Models/APIModels.swift
import Foundation

// MARK: - Authentication Models
struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let token: String
    let userEmail: String
    let userNicename: String
    let userDisplayName: String
    
    enum CodingKeys: String, CodingKey {
        case token
        case userEmail = "user_email"
        case userNicename = "user_nicename"
        case userDisplayName = "user_display_name"
    }
}

// MARK: - Game API Models
struct GameAPIResponse: Codable {
    let id: Int
    let title: RenderedContent
    let content: RenderedContent
    let status: String
    let acf: GameACF
    
    struct RenderedContent: Codable {
        let rendered: String
    }
    
    struct GameACF: Codable {
        let title: String?
        let image: Int?
        let gamestatus: String?
        let platform: [String]?
        let description: String?
        let trailer: String?
        let review: String?
        let score: Int?
        let anoFinalizado: String?
        
        enum CodingKeys: String, CodingKey {
            case title, image, gamestatus, platform, description, trailer, review, score
            case anoFinalizado = "ano_finalizado"
        }
    }
}

struct CreateGameRequest: Codable {
    let title: String
    let status: String
    let content: String
    let acf: GameACFRequest
    
    struct GameACFRequest: Codable {
        let title: String
        let image: Int?
        let gamestatus: String
        let platform: [String]
        let description: String
        let trailer: String?
        let review: String
        let score: Int
        let anoFinalizado: String
        
        enum CodingKeys: String, CodingKey {
            case title, image, gamestatus, platform, description, trailer, review, score
            case anoFinalizado = "ano_finalizado"
        }
    }
}

// MARK: - Media Upload Models
struct MediaUploadResponse: Codable {
    let id: Int
    let sourceUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case sourceUrl = "source_url"
    }
}

// MARK: - API Extensions for Game Conversion
extension GameAPIResponse.GameACF {
    func toGame(id: Int, title: String) -> Game? {
        // Convertir fecha desde formato "20250630" a Date
        guard let anoFinalizado = self.anoFinalizado,
              let date = DateFormatter.apiDateFormatter.date(from: anoFinalizado) else {
            return nil
        }
        
        return Game(
            id: id,
            title: self.title ?? title,
            platform: self.platform?.first ?? "Unknown",
            completionDate: date,
            score: self.score ?? 0,
            coverImage: "", // Se obtendrá la URL de la imagen por separado
            review: self.review ?? ""
        )
    }
}

extension Game {
    func toCreateRequest() -> CreateGameRequest {
        let dateString = DateFormatter.apiDateFormatter.string(from: self.completionDate)
        
        return CreateGameRequest(
            title: self.title,
            status: "publish",
            content: self.review,
            acf: CreateGameRequest.GameACFRequest(
                title: self.title,
                image: nil, // Se asignará después de subir la imagen
                gamestatus: "Finalizado", // Valor por defecto
                platform: [self.platform],
                description: self.review,
                trailer: nil,
                review: self.review,
                score: self.score,
                anoFinalizado: dateString
            )
        )
    }
}

// MARK: - Date Formatter Extension
extension DateFormatter {
    static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
}
