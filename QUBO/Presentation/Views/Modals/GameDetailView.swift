// MARK: - Presentation/Views/Modals/GameDetailView.swift - Estilo Steam con tema retro
import SwiftUI

struct GameDetailView: View {
    let game: Game
    @State private var currentGame: Game
    @ObservedObject var viewModel: GamesViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    init(game: Game, viewModel: GamesViewModel) {
        self.game = game
        self.viewModel = viewModel
        self._currentGame = State(initialValue: game)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 1. HERO IMAGE (estilo Steam)
                HeroImageView(game: currentGame, presentationMode: presentationMode, showingEditSheet: $showingEditSheet, showingDeleteAlert: $showingDeleteAlert)
                
                VStack(spacing: AppTheme.largeSpacing) {
                    // 2. TÍTULO
                    HStack {
                        Text(currentGame.title)
                            .font(AppTheme.largeTitle)
                            .foregroundColor(AppTheme.textColor)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(.horizontal, AppTheme.largeSpacing)
                    .padding(.top, AppTheme.mediumSpacing)
                    
                    // 3. DESCRIPCIÓN (JUSTIFICADA)
                    if !currentGame.description.cleanHTMLForDisplay().isEmpty {
                        VStack {
                            GameDescriptionText(text: currentGame.description.cleanHTMLForDisplay())
                        }
                        .padding(.horizontal, AppTheme.largeSpacing)
                    }
                    
                    // 4. DATOS COMPACTOS (estilo Steam)
                    GameStatsRow(game: currentGame)
                        .padding(.horizontal, AppTheme.largeSpacing)
                    
                    // 5. TRAILER (si existe)
                    if currentGame.hasTrailer {
                        TrailerSection(game: currentGame)
                            .padding(.horizontal, AppTheme.largeSpacing)
                    }
                    
                    // 6. REVIEW (último, con acordeón)
                    ReviewAccordionView(game: currentGame, showingEditSheet: $showingEditSheet)
                        .padding(.horizontal, AppTheme.largeSpacing)
                }
                .padding(.bottom, 40)
            }
        }
        .background(AppTheme.backgroundColor)
        .onAppear {
            updateCurrentGame()
        }
        .onChange(of: viewModel.games) { _ in
            updateCurrentGame()
        }
        .sheet(isPresented: $showingEditSheet) {
            EditGameView(game: currentGame, viewModel: viewModel)
        }
        .alert("DELETE GAME", isPresented: $showingDeleteAlert) {
            Button("CANCEL", role: .cancel) { }
            Button("DELETE", role: .destructive) {
                deleteGame()
            }
        } message: {
            Text("Are you sure you want to delete '\(currentGame.title)'?")
        }
    }
    
    private func updateCurrentGame() {
        if let updatedGame = viewModel.games.first(where: { $0.id == game.id }) {
            currentGame = updatedGame
        }
    }
    
    private func deleteGame() {
        viewModel.deleteGame(withId: currentGame.id)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Hero Image Component
struct HeroImageView: View {
    let game: Game
    let presentationMode: Binding<PresentationMode>
    @Binding var showingEditSheet: Bool
    @Binding var showingDeleteAlert: Bool
    
    var body: some View {
        ZStack {
            // Background Image
            if game.coverImage.hasPrefix("http") {
                AsyncImage(url: URL(string: game.coverImage)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 300)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(AppTheme.primaryColor)
                        .frame(height: 300)
                        .overlay(
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.7))
                        )
                }
            } else {
                Rectangle()
                    .fill(AppTheme.primaryColor)
                    .frame(height: 300)
                    .overlay(
                        Image(systemName: game.coverImage)
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.7))
                    )
            }
            
            // Gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.6),
                    Color.clear,
                    Color.black.opacity(0.3)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Header controls
            VStack {
                HStack {
                    // Close button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(AppTheme.body)
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Menu button
                    Menu {
                        Button {
                            showingEditSheet = true
                        } label: {
                            Label("Edit Game", systemImage: "pencil")
                                .font(AppTheme.body)
                        }
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete Game", systemImage: "trash")
                                .font(AppTheme.body)
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(AppTheme.body)
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, AppTheme.largeSpacing)
                .padding(.top, AppTheme.smallSpacing)
                
                Spacer()
            }
        }
        .frame(height: 300)
    }
}

// MARK: - Game Stats Row (estilo Steam compacto con tema)
struct GameStatsRow: View {
    let game: Game
    
    var body: some View {
        HStack(spacing: AppTheme.mediumSpacing) {
            // Score
            StatItem(
                icon: "star.fill",
                value: "\(game.score)/10",
                label: "Score",
                color: AppTheme.secondaryColor
            )
            
            Divider()
                .frame(height: 30)
                .background(AppTheme.textColor.opacity(0.3))
            
            // Year
            StatItem(
                icon: "calendar",
                value: game.formattedYear,
                label: "Completed",
                color: AppTheme.accentColor
            )
            
            Divider()
                .frame(height: 30)
                .background(AppTheme.textColor.opacity(0.3))
            
            // Platform
            StatItem(
                icon: "gamecontroller.fill",
                value: game.platform,
                label: "Platform",
                color: AppTheme.primaryColor
            )
            
            Divider()
                .frame(height: 30)
                .background(AppTheme.textColor.opacity(0.3))
            
            // Status
            StatItem(
                icon: "checkmark.circle.fill",
                value: game.gameStatus,
                label: "Status",
                color: Color.green
            )
        }
        .padding(.vertical, AppTheme.mediumSpacing)
        .padding(.horizontal, AppTheme.largeSpacing)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.mediumCornerRadius)
                .fill(Color.white.opacity(0.9))
                .shadow(color: AppTheme.textColor.opacity(0.1), radius: 4, x: 2, y: 2)
        )
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(AppTheme.body)
                .foregroundColor(color)
            
            Text(value)
                .font(AppTheme.caption)
                .foregroundColor(AppTheme.textColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(label)
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .foregroundColor(AppTheme.textColor.opacity(0.7))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Trailer Section
struct TrailerSection: View {
    let game: Game
    @State private var showingTrailer = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
            HStack {
                Text("TRAILER")
                    .font(AppTheme.title)
                    .foregroundColor(AppTheme.textColor)
                
                Spacer()
            }
            
            Button(action: {
                showingTrailer = true
            }) {
                ZStack {
                    // Thumbnail
                    AsyncImage(url: URL(string: game.youtubeThumbnailURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fill)
                            .clipped()
                    } placeholder: {
                        Rectangle()
                            .fill(AppTheme.textColor.opacity(0.2))
                            .aspectRatio(16/9, contentMode: .fill)
                            .overlay(
                                Image(systemName: "play.rectangle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppTheme.textColor.opacity(0.7))
                            )
                    }
                    
                    // Play button overlay
                    Color.black.opacity(0.3)
                    
                    Circle()
                        .fill(AppTheme.primaryColor.opacity(0.9))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "play.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .offset(x: 2)
                        )
                }
                .cornerRadius(AppTheme.mediumCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.mediumCornerRadius)
                        .stroke(AppTheme.textColor.opacity(0.2), lineWidth: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .sheet(isPresented: $showingTrailer) {
            if let videoId = game.youtubeVideoId {
                YouTubePlayerView(videoId: videoId)
            }
        }
    }
}

// MARK: - Review Accordion con texto justificado y tema
struct ReviewAccordionView: View {
    let game: Game
    @Binding var showingEditSheet: Bool
    @State private var isExpanded = false
    
    private let previewLength = 150
    
    private var shouldShowAccordion: Bool {
        game.cleanReview.count > previewLength && game.hasReview
    }
    
    private var previewText: String {
        if game.cleanReview.count <= previewLength {
            return game.cleanReview
        } else {
            return String(game.cleanReview.prefix(previewLength)) + "..."
        }
    }
    
    var body: some View {
        VStack(spacing: AppTheme.mediumSpacing) {
            HStack {
                Text("MY REVIEW")
                    .font(AppTheme.title)
                    .foregroundColor(AppTheme.textColor)
                
                Spacer()
                
                Button {
                    showingEditSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(AppTheme.caption)
                        Text("EDIT")
                            .font(AppTheme.caption)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, AppTheme.smallSpacing)
                    .padding(.vertical, 6)
                    .background(AppTheme.accentColor)
                    .cornerRadius(AppTheme.smallCornerRadius)
                }
            }
            
            if game.hasReview {
                VStack(spacing: AppTheme.smallSpacing) {
                    // TEXTO JUSTIFICADO APLICADO
                    GameReviewText(text: isExpanded ? game.cleanReview : previewText)
                        .animation(.easeInOut(duration: 0.3), value: isExpanded)
                    
                    if shouldShowAccordion {
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isExpanded.toggle()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(isExpanded ? "SHOW LESS" : "READ MORE")
                                    .font(AppTheme.caption)
                                
                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                    .font(AppTheme.caption)
                            }
                            .foregroundColor(AppTheme.accentColor)
                            .padding(.horizontal, AppTheme.mediumSpacing)
                            .padding(.vertical, AppTheme.smallSpacing)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                    .fill(AppTheme.accentColor.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                            .stroke(AppTheme.accentColor.opacity(0.3), lineWidth: 2)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            } else {
                VStack(spacing: AppTheme.smallSpacing) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 30))
                        .foregroundColor(AppTheme.textColor.opacity(0.5))
                    
                    Text("No review available")
                        .font(AppTheme.body)
                        .foregroundColor(AppTheme.textColor.opacity(0.7))
                    
                    Text("Tap EDIT to add your thoughts")
                        .font(AppTheme.caption)
                        .foregroundColor(AppTheme.textColor.opacity(0.5))
                }
                .padding(.vertical, AppTheme.largeSpacing)
            }
        }
        .padding(AppTheme.largeSpacing)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.mediumCornerRadius)
                .fill(Color.white.opacity(0.85))
                .shadow(color: AppTheme.textColor.opacity(0.1), radius: 4, x: 2, y: 2)
        )
    }
}
