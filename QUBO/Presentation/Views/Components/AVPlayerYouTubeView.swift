// MARK: - AVPlayerYouTubeView.swift - Reproductor nativo con AVPlayer
import SwiftUI
import AVKit

// MARK: - YouTube Player con AVPlayer (Nativo)
struct YouTubePlayerView: View {
    let videoId: String
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = true
    @State private var hasError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if hasError {
                    ErrorView(videoId: videoId, errorMessage: errorMessage)
                } else if isLoading {
                    LoadingView()
                } else {
                    // Mostrar enlace directo como fallback
                    DirectLinkView(videoId: videoId)
                }
            }
            .navigationTitle("Trailer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // YouTube App
                        if let youtubeURL = URL(string: "youtube://watch?v=\(videoId)"),
                           UIApplication.shared.canOpenURL(youtubeURL) {
                            Button(action: {
                                UIApplication.shared.open(youtubeURL)
                            }) {
                                Label("Open in YouTube", systemImage: "play.rectangle.fill")
                            }
                        }
                        
                        // Safari
                        if let safariURL = URL(string: "https://www.youtube.com/watch?v=\(videoId)") {
                            Button(action: {
                                UIApplication.shared.open(safariURL)
                            }) {
                                Label("Open in Safari", systemImage: "safari")
                            }
                        }
                        
                        // Copiar enlace
                        Button(action: {
                            UIPasteboard.general.string = "https://www.youtube.com/watch?v=\(videoId)"
                        }) {
                            Label("Copy Link", systemImage: "doc.on.doc")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            // Simular carga y mostrar opciones
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isLoading = false
            }
        }
    }
}

// MARK: - Vista de enlaces directos (más confiable)
struct DirectLinkView: View {
    let videoId: String
    
    var body: some View {
        VStack(spacing: 30) {
            // Thumbnail de YouTube
            AsyncImage(url: URL(string: "https://img.youtube.com/vi/\(videoId)/maxresdefault.jpg")) { image in
                image
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fit)
                    .cornerRadius(12)
                    .overlay(
                        // Play button overlay
                        Button(action: openInYouTube) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 30, weight: .bold))
                                        .foregroundColor(.white)
                                        .offset(x: 3)
                                )
                        }
                        .shadow(color: .black.opacity(0.3), radius: 10)
                    )
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(16/9, contentMode: .fit)
                    .cornerRadius(12)
                    .overlay(
                        Image(systemName: "play.rectangle")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.7))
                    )
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 16) {
                Text("Watch Trailer")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                Text("Choose how you'd like to watch this video")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 12) {
                    // YouTube App Button
                    if let youtubeURL = URL(string: "youtube://watch?v=\(videoId)"),
                       UIApplication.shared.canOpenURL(youtubeURL) {
                        Button(action: {
                            UIApplication.shared.open(youtubeURL)
                        }) {
                            HStack {
                                Image(systemName: "play.rectangle.fill")
                                    .font(.title3)
                                Text("Open in YouTube App")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red)
                            )
                        }
                    }
                    
                    // Safari Button
                    Button(action: openInSafari) {
                        HStack {
                            Image(systemName: "safari")
                                .font(.title3)
                            Text("Open in Safari")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
    
    private func openInYouTube() {
        if let youtubeURL = URL(string: "youtube://watch?v=\(videoId)"),
           UIApplication.shared.canOpenURL(youtubeURL) {
            UIApplication.shared.open(youtubeURL)
        } else {
            openInSafari()
        }
    }
    
    private func openInSafari() {
        if let safariURL = URL(string: "https://www.youtube.com/watch?v=\(videoId)") {
            UIApplication.shared.open(safariURL)
        }
    }
}

// MARK: - Vista de carga
struct LoadingView: View {
    @State private var rotation = 0.0
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "play.circle")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            
            Text("Loading trailer...")
                .font(.title3)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

// MARK: - Vista de error
struct ErrorView: View {
    let videoId: String
    let errorMessage: String
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Unable to Load Video")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Text(errorMessage.isEmpty ? "Please try opening the video in YouTube or Safari." : errorMessage)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            VStack(spacing: 12) {
                // YouTube App
                if let youtubeURL = URL(string: "youtube://watch?v=\(videoId)"),
                   UIApplication.shared.canOpenURL(youtubeURL) {
                    Button(action: {
                        UIApplication.shared.open(youtubeURL)
                    }) {
                        HStack {
                            Image(systemName: "play.rectangle.fill")
                            Text("Open in YouTube")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                    }
                }
                
                // Safari
                Button(action: {
                    if let safariURL = URL(string: "https://www.youtube.com/watch?v=\(videoId)") {
                        UIApplication.shared.open(safariURL)
                    }
                }) {
                    HStack {
                        Image(systemName: "safari")
                        Text("Open in Safari")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

// MARK: - Alternativa: Simple Link View (Más básico pero más confiable)
struct SimpleYouTubePlayerView: View {
    let videoId: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.red)
                    
                    Text("YouTube Trailer")
                        .font(.title.bold())
                        .foregroundColor(.primary)
                    
                    Text("Video ID: \(videoId)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Botones de acción
                VStack(spacing: 16) {
                    if let youtubeURL = URL(string: "youtube://watch?v=\(videoId)") {
                        Link(destination: youtubeURL) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Open in YouTube App")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                        }
                    }
                    
                    if let safariURL = URL(string: "https://www.youtube.com/watch?v=\(videoId)") {
                        Link(destination: safariURL) {
                            HStack {
                                Image(systemName: "safari")
                                Text("Open in Safari")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("Trailer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
