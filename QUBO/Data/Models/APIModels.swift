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
        let image: AnyCodable? // Usando AnyCodable para manejar Int o String
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
        
        // Helper para obtener el ID de la imagen
        var imageId: Int? {
            if let intValue = image?.value as? Int {
                return intValue
            } else if let stringValue = image?.value as? String,
                      let intValue = Int(stringValue) {
                return intValue
            }
            return nil
        }
    }
}

// MARK: - AnyCodable Helper
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to decode value")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let intValue as Int:
            try container.encode(intValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Unable to encode value"))
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
        let image: Int? // Para crear, siempre enviamos Int
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
            coverImage: "gamecontroller.fill", // Se actualizará con la URL real
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
                gamestatus: "Finalizado",
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
