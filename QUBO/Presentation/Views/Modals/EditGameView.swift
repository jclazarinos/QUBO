// MARK: - Presentation/Views/Modals/EditGameView.swift
import SwiftUI

struct EditGameView: View {
    let originalGame: Game
    @ObservedObject var viewModel: GamesViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // Campos básicos
    @State private var title: String
    @State private var platform: String
    @State private var completionDate: Date
    @State private var score: Int
    @State private var review: String
    
    // Nuevos campos
    @State private var description: String
    @State private var trailer: String
    @State private var gameStatus: String
    
    // Estado para UI
    @State private var showingPlatformPicker = false
    
    @State private var imageSource: ImageSource = .none
    @State private var uploadedMediaId: Int?
    @State private var finalImageURL: String
    // Platform options (lista completa)
    private let platformOptions = [
        "Amiga", "Android", "Arcade", "Arcade Sega NAOMI", "Atari 2600",
        "Game & Watch", "Microsoft Xbox 360", "MSX", "Neo Geo", "Neo Geo CD",
        "Neo Geo Pocket", "Neo Geo Pocket Color", "Nintendo 3DS", "Nintendo 64",
        "Nintendo DS", "Nintendo Entertainment System (NES)", "Nintendo Game Boy",
        "Nintendo Game Boy Advance", "Nintendo Game Boy Color", "Nintendo GameCube",
        "Nintendo Switch", "Nintendo Wii", "Nintendo Wii U", "PC", "PC-Engine",
        "Sega CD", "Sega Dreamcast", "Sega Game Gear", "Sega Genesis",
        "Sega Master System", "Sega Saturn", "SEGA SG-1000", "Sharp X68000",
        "Super Nintendo (SNES)", "Sony Playstation (PSX)", "Sony Playstation 2",
        "Sony Playstation 4", "Sony PSP", "Sony Playstation Vita",
        "TurboGrafx 16", "TurboGrafx CD", "WonderSwan", "WonderSwan Color"
    ]
    
    // Game status options (en español)
    private let gameStatusOptions = ["Revisión", "Finalizado", "Por Jugar", "Jugando"]
    
    init(game: Game, viewModel: GamesViewModel) {
        self.originalGame = game
        self.viewModel = viewModel
        
        // Initialize state variables
        _title = State(initialValue: game.title)
        _platform = State(initialValue: game.platform)
        _completionDate = State(initialValue: game.completionDate)
        _score = State(initialValue: game.score)
        _review = State(initialValue: game.review)
        _description = State(initialValue: game.description)
        _trailer = State(initialValue: game.trailer ?? "")
        _gameStatus = State(initialValue: game.gameStatus)
        _finalImageURL = State(initialValue: game.coverImage.hasPrefix("http") ? game.coverImage : "")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header (estilo pixel consistente)
                HStack {
                    Button("CANCEL") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.pixelBody)
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("EDIT GAME")
                        .font(.pixelTitle)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("SAVE") {
                        saveGame()
                    }
                    .font(.pixelBody)
                    .foregroundColor(.white)
                    .disabled(title.isEmpty || platform.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(Color.snesRed)
                
                // Form
                ScrollView {
                    VStack(spacing: 20) {
                        // TITLE
                        FormField(title: "TITLE", isRequired: true) {
                            TextField("Game name", text: $title)
                                .textFieldStyle()
                        }
                        
                        // PLATFORM (con picker)
                        FormField(title: "PLATFORM", isRequired: true) {
                            Button(action: {
                                showingPlatformPicker = true
                            }) {
                                HStack {
                                    Text(platform.isEmpty ? "Select platform..." : platform)
                                        .foregroundColor(platform.isEmpty ? Color.darkGray.opacity(0.6) : Color.darkGray)
                                        .font(.pixelBody)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(Color.darkGray)
                                        .font(.pixelCaption)
                                }
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.darkGray, lineWidth: 2)
                                )
                            }
                        }
                        
                        // DESCRIPTION
                        FormField(title: "DESCRIPTION") {
                            TextEditor(text: $description)
                                .font(.pixelBody)
                                .frame(minHeight: 80)
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.darkGray, lineWidth: 2)
                                )
                        }
                        
                        // TRAILER
                        FormField(title: "TRAILER (YouTube URL)") {
                            TextField("https://www.youtube.com/watch?v=...", text: $trailer)
                                .textFieldStyle()
                                .autocapitalization(.none)
                                .keyboardType(.URL)
                        }
                        
                        // COMPLETION DATE
                        FormField(title: "COMPLETION DATE", isRequired: true) {
                            DatePicker("", selection: $completionDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .font(.pixelBody)
                                .accentColor(Color.retroBlue)
                        }
                        
                        // GAME STATUS
                        FormField(title: "STATUS") {
                            Picker("Status", selection: $gameStatus) {
                                ForEach(gameStatusOptions, id: \.self) { status in
                                    Text(status)
                                        .font(.pixelBody)
                                        .tag(status)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .colorMultiply(Color.retroBlue)
                        }
                        
                        // SCORE
                        FormField(title: "SCORE: \(score)/10") {
                            VStack(spacing: 8) {
                                HStack {
                                    Spacer()
                                    
                                    HStack(spacing: 8) {
                                        Button("-") {
                                            if score > 1 { score -= 1 }
                                        }
                                        .font(.pixelBody)
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 32)
                                        .background(Color.snesRed)
                                        .cornerRadius(6)
                                        .disabled(score <= 1)
                                        
                                        Button("+") {
                                            if score < 10 { score += 1 }
                                        }
                                        .font(.pixelBody)
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 32)
                                        .background(Color.snesRed)
                                        .cornerRadius(6)
                                        .disabled(score >= 10)
                                    }
                                }
                                
                                // Score visual
                                HStack(spacing: 4) {
                                    ForEach(1...10, id: \.self) { index in
                                        Circle()
                                            .fill(index <= score ? Color.arcadeYellow : Color.darkGray.opacity(0.3))
                                            .frame(width: 12, height: 12)
                                            .onTapGesture {
                                                score = index
                                            }
                                    }
                                }
                            }
                        }
                        
                        // PERSONAL REVIEW
                        FormField(title: "PERSONAL REVIEW") {
                            TextEditor(text: $review)
                                .font(.pixelBody)
                                .frame(minHeight: 120)
                                .padding(8)
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.darkGray, lineWidth: 2)
                                )
                        }
                        
                        EnhancedImageField(
                            title: "COVER IMAGE",
                            imageSource: $imageSource,
                            uploadedMediaId: $uploadedMediaId,
                            finalImageURL: $finalImageURL
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                .background(Color.lightGray)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingPlatformPicker) {
            PlatformPickerView(
                selectedPlatform: $platform,
                availablePlatforms: platformOptions,
                isPresented: $showingPlatformPicker
            )
        }
    }
    
    private func saveGame() {
        // Determinar la imagen final
        let finalCoverImage: String
        if !finalImageURL.isEmpty {
            finalCoverImage = finalImageURL
        } else if originalGame.coverImage.hasPrefix("http") {
            finalCoverImage = "gamepad.fill" // Si se borró la URL, usar ícono
        } else {
            finalCoverImage = originalGame.coverImage // Mantener ícono existente
        }
        
        let updatedGame = Game(
            id: originalGame.id,
            title: title,
            platform: platform,
            completionDate: completionDate,
            score: score,
            coverImage: finalCoverImage,
            review: review,
            description: description,
            trailer: trailer.isEmpty ? nil : trailer,
            gameStatus: gameStatus
        )
        
        // Pasar mediaId si está disponible
        viewModel.updateGame(updatedGame, mediaId: uploadedMediaId)
        presentationMode.wrappedValue.dismiss()
    }
}
