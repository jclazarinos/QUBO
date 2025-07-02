// MARK: - Domain/Entities/Enums.swift

enum SortOption: String, CaseIterable {
    case score = "Score"
    case year = "Year"
    case platform = "Platform"
    case alphabetical = "A-Z"
}

enum ViewType: String, CaseIterable {
    case icons = "Icons"
    case list = "List"
}

enum Theme: String, CaseIterable {
    case games = "GAMES"
    case rpg = "RPG"
    case retro = "Retro"
}
