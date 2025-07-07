// MARK: - Data/Services/APIService.swift
import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError
    case authenticationFailed
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .noData:
            return "No se recibieron datos"
        case .decodingError:
            return "Error al procesar los datos"
        case .networkError:
            return "Error de red"
        case .authenticationFailed:
            return "Error de autenticación"
        case .serverError(let code):
            return "Error del servidor: \(code)"
        }
    }
}

class APIService {
    static let shared = APIService()
    
    private let baseURL = "https://apiwpduck.duckdns.org/wp-json"
    private var authToken: String?
    
    private init() {}
    
    // MARK: - Authentication
    func login(username: String = "admin", password: String = "ancientgear7530") async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/jwt-auth/v1/token") else {
            throw APIError.invalidURL
        }
        
        let loginRequest = LoginRequest(username: username, password: password)
        let requestData = try JSONEncoder().encode(loginRequest)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.authenticationFailed
        }
        
        do {
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            self.authToken = loginResponse.token
            return loginResponse
        } catch {
            throw APIError.decodingError
        }
    }
    
    // MARK: - Games API
    func getAllGames() async throws -> [Game] {
        guard let url = URL(string: "\(baseURL)/wp/v2/game?per_page=100") else {
                throw APIError.invalidURL
            }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        do {
                let apiGames = try JSONDecoder().decode([GameAPIResponse].self, from: data)
                
                // 🔍 DEBUG: Cuántos juegos devuelve la API
                print("🌐 API returned \(apiGames.count) games from WordPress")
                
                var games: [Game] = []
                
                for apiGame in apiGames {
                    if let game = try await convertAPIGameToGame(apiGame) {
                        games.append(game)
                        print("✅ Converted game: \(game.title)")
                    } else {
                        print("❌ Failed to convert game: \(apiGame.title.rendered)")
                    }
                }
                
                print("🎮 Total games successfully converted: \(games.count)")
                return games
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError
        }
    }
    
    func getGameById(_ id: Int) async throws -> Game? {
        guard let url = URL(string: "\(baseURL)/wp/v2/game/\(id)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        do {
            let apiGame = try JSONDecoder().decode(GameAPIResponse.self, from: data)
            return try await convertAPIGameToGame(apiGame)
        } catch {
            throw APIError.decodingError
        }
    }
    // MARK: - Paginated Games API (AGREGAR AL FINAL DEL ARCHIVO)
    func getGames(page: Int = 1, perPage: Int = 20, sortOption: SortOption = .alphabetical) async throws -> [Game] {
        // Convertir SortOption a parámetros de WordPress
        let (orderBy, order) = getSortParameters(for: sortOption)
        
        guard let url = URL(string: "\(baseURL)/wp/v2/game?page=\(page)&per_page=\(perPage)&orderby=\(orderBy)&order=\(order)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError
        }
        
        // Log pagination info
        if let totalPages = httpResponse.value(forHTTPHeaderField: "X-WP-TotalPages"),
           let totalPosts = httpResponse.value(forHTTPHeaderField: "X-WP-Total") {
            print("📊 Page \(page)/\(totalPages) - \(totalPosts) total games (sorted by \(sortOption.rawValue))")
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 400 && page > 1 {
                print("📄 Page \(page) is out of range, no more games")
                return []
            }
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        do {
            let apiGames = try JSONDecoder().decode([GameAPIResponse].self, from: data)
            print("🌐 Page \(page): API returned \(apiGames.count) games")
            
            var games: [Game] = []
            
            for apiGame in apiGames {
                if let game = try await convertAPIGameToGame(apiGame) {
                    games.append(game)
                }
            }
            
            print("🎮 Page \(page): \(games.count) games successfully converted")
            return games
            
        } catch {
            print("❌ Decoding error on page \(page): \(error)")
            throw APIError.decodingError
        }
    }

    // AGREGAR este método helper:
    private func getSortParameters(for sortOption: SortOption) -> (orderBy: String, order: String) {
        switch sortOption {
        case .alphabetical:
            return ("title", "asc")
        case .score:
            return ("meta_value_num", "desc") // Asumiendo que score es meta field
        case .year:
            return ("date", "desc")
        case .platform:
            return ("meta_value", "asc") // Asumiendo que platform es meta field
        }
    }
    
    func createGame(_ game: Game) async throws -> Game {
        guard let token = authToken else {
            throw APIError.authenticationFailed
        }
        
        guard let url = URL(string: "\(baseURL)/wp/v2/game") else {
            throw APIError.invalidURL
        }
        
        let createRequest = game.toCreateRequest()
        let requestData = try JSONEncoder().encode(createRequest)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError
        }
        
        guard httpResponse.statusCode == 201 else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        do {
            let apiGame = try JSONDecoder().decode(GameAPIResponse.self, from: data)
            return try await convertAPIGameToGame(apiGame) ?? game
        } catch {
            throw APIError.decodingError
        }
    }
    
    func updateGame(_ game: Game) async throws -> Game {
        guard let token = authToken else {
            throw APIError.authenticationFailed
        }
        
        guard let url = URL(string: "\(baseURL)/wp/v2/game/\(game.id)") else {
            throw APIError.invalidURL
        }
        
        let updateRequest = game.toCreateRequest()
        let requestData = try JSONEncoder().encode(updateRequest)
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        do {
            let apiGame = try JSONDecoder().decode(GameAPIResponse.self, from: data)
            return try await convertAPIGameToGame(apiGame) ?? game
        } catch {
            throw APIError.decodingError
        }
    }
    
    func deleteGame(withId id: Int) async throws {
        guard let token = authToken else {
            throw APIError.authenticationFailed
        }
        
        guard let url = URL(string: "\(baseURL)/wp/v2/game/\(id)?force=true") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.serverError(httpResponse.statusCode)
        }
    }
    
    // MARK: - Media Upload
    func uploadImage(_ imageData: Data, fileName: String) async throws -> MediaUploadResponse {
        guard let token = authToken else {
            throw APIError.authenticationFailed
        }
        
        guard let url = URL(string: "\(baseURL)/wp/v2/media") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("attachment; filename=\"\(fileName)\"", forHTTPHeaderField: "Content-Disposition")
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError
        }
        
        guard httpResponse.statusCode == 201 else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(MediaUploadResponse.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
    
    private func convertAPIGameToGame(_ apiGame: GameAPIResponse) async throws -> Game? {
        // Extraer datos básicos del ACF
        guard let title = apiGame.acf.title,
              let anoFinalizado = apiGame.acf.anoFinalizado,
              let date = DateFormatter.apiDateFormatter.date(from: anoFinalizado) else {
            print("❌ Missing required fields for game: \(apiGame.title.rendered)")
            return nil
        }
        
        // Obtener URL de la imagen si existe
        var imageUrl = "gamecontroller.fill"
        if let imageId = apiGame.acf.imageId {
            imageUrl = try await getMediaURL(for: imageId) ?? "gamecontroller.fill"
        }
        
        return Game(
            id: apiGame.id,
            title: title,
            platform: apiGame.acf.platform?.first ?? "Unknown",
            completionDate: date,
            score: apiGame.acf.score ?? 0,
            coverImage: imageUrl,
            review: apiGame.acf.review ?? "",
            description: apiGame.acf.description ?? "",
            trailer: apiGame.acf.trailer,
            gameStatus: apiGame.acf.gamestatus ?? "Completed"
        )
    }
    
    private func getMediaURL(for mediaId: Int) async throws -> String? {
        guard let url = URL(string: "\(baseURL)/wp/v2/media/\(mediaId)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("Failed to get media URL for ID \(mediaId)")
                return nil
            }
            
            let mediaResponse = try JSONDecoder().decode(MediaUploadResponse.self, from: data)
            return mediaResponse.sourceUrl
        } catch {
            print("Error getting media URL: \(error)")
            return nil
        }
    }
}
