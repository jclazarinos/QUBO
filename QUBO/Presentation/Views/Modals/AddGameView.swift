// MARK: - Presentation/Views/Modals/AddGameView.swift
import SwiftUI

struct AddGameView: View {
    @ObservedObject var viewModel: GamesViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // Campos básicos
    @State private var title = ""
    @State private var platform = ""
    @State private var completionDate = Date()
    @State private var score = 5
    @State private var review = ""
    
    // Nuevos campos
    @State private var description = ""
    @State private var trailer = ""
    @State private var gameStatus = "Finalizado"
    @State private var imageSource: ImageSource = .none
    @State private var uploadedMediaId: Int?
    @State private var finalImageURL: String = ""

    // Estado para platform picker
    @State private var showingPlatformPicker = false
    @State private var availablePlatforms: [String] = []
    
    // Game status options (en español)
    private let gameStatusOptions = ["Revisión", "Finalizado", "Por Jugar", "Jugando"]
    
    // Platform options (lista completa)
    private let platformOptions = [
        "Amiga",
        "Android",
        "Arcade",
        "Arcade Sega NAOMI",
        "Atari 2600",
        "Game & Watch",
        "Microsoft Xbox 360",
        "MSX",
        "Neo Geo",
        "Neo Geo CD",
        "Neo Geo Pocket",
        "Neo Geo Pocket Color",
        "Nintendo 3DS",
        "Nintendo 64",
        "Nintendo DS",
        "Nintendo Entertainment System (NES)",
        "Nintendo Game Boy",
        "Nintendo Game Boy Advance",
        "Nintendo Game Boy Color",
        "Nintendo GameCube",
        "Nintendo Switch",
        "Nintendo Wii",
        "Nintendo Wii U",
        "PC",
        "PC-Engine",
        "Sega CD",
        "Sega Dreamcast",
        "Sega Game Gear",
        "Sega Genesis",
        "Sega Master System",
        "Sega Saturn",
        "SEGA SG-1000",
        "Sharp X68000",
        "Super Nintendo (SNES)",
        "Sony Playstation (PSX)",
        "Sony Playstation 2",
        "Sony Playstation 4",
        "Sony PSP",
        "Sony Playstation Vita",
        "TurboGrafx 16",
        "TurboGrafx CD",
        "WonderSwan",
        "WonderSwan Color"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                    .font(.pixelBody)
                    
                    Spacer()
                    
                    Text("NEW GAME")
                        .font(.pixelTitle)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Save") {
                        saveGame()
                    }
                    .foregroundColor(.white)
                    .font(.pixelBody)
                    .disabled(title.isEmpty || platform.isEmpty)
                }
                .padding(.horizontal, AppTheme.largeSpacing)
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
                                Slider(value: Binding(
                                    get: { Double(score) },
                                    set: { score = Int($0) }
                                ), in: 1...10, step: 1)
                                .accentColor(Color.arcadeYellow)
                                
                                // Score visual
                                HStack(spacing: 4) {
                                    ForEach(1...10, id: \.self) { index in
                                        Circle()
                                            .fill(index <= score ? Color.arcadeYellow : Color.darkGray.opacity(0.3))
                                            .frame(width: 12, height: 12)
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
                    .padding(.horizontal, AppTheme.largeSpacing)
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
    
    // MARK: - Actions
    private func saveGame() {
        // Determinar la imagen final
        let finalCoverImage: String
        if !finalImageURL.isEmpty {
            finalCoverImage = finalImageURL
        } else {
            finalCoverImage = "gamepad.fill"
        }
        
        let newGame = Game(
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
        viewModel.addGame(newGame, mediaId: uploadedMediaId)
        presentationMode.wrappedValue.dismiss()
    }
}
