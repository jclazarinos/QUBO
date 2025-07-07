// MARK: - Presentation/Views/Modals/GameDetailView.swift - Estilo Steam
import SwiftUI

struct GameDetailView: View {
    @State private var currentGame: Game
    @ObservedObject var viewModel: GamesViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 1. HERO IMAGE (estilo Steam)
                HeroImageView(game: currentGame, presentationMode: presentationMode, showingEditSheet: $showingEditSheet, showingDeleteAlert: $showingDeleteAlert)
                
                VStack(spacing: 20) {
                    // 2. TÍTULO
                    HStack {
                        Text(currentGame.title)
                            .font(.system(size: 28, weight: .bold, design: .default))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // 3. DESCRIPCIÓN (JUSTIFICADA) - USAR currentGame
                    if !currentGame.description.cleanHTMLForDisplay().isEmpty {
                        VStack {
                            GameDescriptionText(text: currentGame.description.cleanHTMLForDisplay())
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // 4. DATOS COMPACTOS (estilo Steam)
                    GameStatsRow(game: currentGame)
                        .padding(.horizontal, 20)
                    
                    // 5. TRAILER (si existe)
                    if currentGame.hasTrailer {
                        TrailerSection(game: currentGame)
                            .padding(.horizontal, 20)
                    }
                    
                    // 6. REVIEW (último, con acordeón)
                    ReviewAccordionView(game: currentGame, showingEditSheet: $showingEditSheet)
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemBackground))
        .onAppear {
            // Actualizar currentGame cuando aparece la vista
            updateCurrentGame()
        }
        .onChange(of: viewModel.games) { _ in
            // Actualizar currentGame cuando el ViewModel cambia
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
            Text("Are you sure you want to delete '\(game.title)'?")
        }
    }
    
    private func deleteGame() {
        viewModel.deleteGame(withId: game.id)
        presentationMode.wrappedValue.dismiss()
    }
}
// AGREGAR este método helper:
private func updateCurrentGame() {
    if let updatedGame = viewModel.games.first(where: { $0.id == game.id }) {
        currentGame = updatedGame
    }
}

// CAMBIAR el init para inicializar currentGame:
init(game: Game, viewModel: GamesViewModel) {
    self.game = game
    self.viewModel = viewModel
    self._currentGame = State(initialValue: game)
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
                            .font(.system(size: 18, weight: .bold))
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
                        }
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete Game", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
            }
        }
        .frame(height: 300)
    }
}

// MARK: - Game Stats Row (estilo Steam compacto)
struct GameStatsRow: View {
    let game: Game
    
    var body: some View {
        HStack(spacing: 16) {
            // Score
            StatItem(
                icon: "star.fill",
                value: "\(game.score)/10",
                label: "Score",
                color: .orange
            )
            
            Divider()
                .frame(height: 30)
            
            // Year
            StatItem(
                icon: "calendar",
                value: game.formattedYear,
                label: "Completed",
                color: .blue
            )
            
            Divider()
                .frame(height: 30)
            
            // Platform
            StatItem(
                icon: "gamecontroller.fill",
                value: game.platform,
                label: "Platform",
                color: .green
            )
            
            Divider()
                .frame(height: 30)
            
            // Status
            StatItem(
                icon: "checkmark.circle.fill",
                value: game.gameStatus,
                label: "Status",
                color: .purple
            )
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
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
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TRAILER")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
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
                            .fill(Color(.systemGray4))
                            .aspectRatio(16/9, contentMode: .fill)
                            .overlay(
                                Image(systemName: "play.rectangle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.7))
                            )
                    }
                    
                    // Play button overlay
                    Color.black.opacity(0.3)
                    
                    Circle()
                        .fill(Color.black.opacity(0.7))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "play.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .offset(x: 2) // Slight offset for visual balance
                        )
                }
                .cornerRadius(12)
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

// MARK: - Review Accordion con texto justificado
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
        VStack(spacing: 16) {
            HStack {
                Text("MY REVIEW")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button {
                    showingEditSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.system(size: 12))
                        Text("EDIT")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .cornerRadius(6)
                }
            }
            
            if game.hasReview {
                VStack(spacing: 12) {
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
                                    .font(.system(size: 14, weight: .semibold))
                                
                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 30))
                        .foregroundColor(.secondary)
                    
                    Text("No review available")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    
                    Text("Tap EDIT to add your thoughts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
