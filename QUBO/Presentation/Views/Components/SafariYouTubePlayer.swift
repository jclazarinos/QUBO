// MARK: - SafariYouTubePlayer.swift - Reproductor interno con Safari
import SwiftUI
import SafariServices

// MARK: - YouTube Player con SFSafariViewController (Interno)
struct YouTubePlayerView: View {
    let videoId: String
    @Environment(\.presentationMode) var presentationMode
    @State private var showingSafari = false
    
    var youtubeURL: URL? {
        URL(string: "https://www.youtube.com/watch?v=\(videoId)")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header personalizado
            HStack {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
                .padding(.leading, 16)
                
                Spacer()
                
                Text("Trailer")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Menu {
                    if let youtubeURL = URL(string: "youtube://watch?v=\(videoId)"),
                       UIApplication.shared.canOpenURL(youtubeURL) {
                        Button(action: {
                            UIApplication.shared.open(youtubeURL)
                        }) {
                            Label("Open in YouTube", systemImage: "play.rectangle.fill")
                        }
                    }
                    
                    Button(action: {
                        UIPasteboard.general.string = "https://www.youtube.com/watch?v=\(videoId)"
                    }) {
                        Label("Copy Link", systemImage: "doc.on.doc")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.white)
                        .padding(.trailing, 16)
                }
            }
            .frame(height: 44)
            .background(Color.black)
            
            // Safari View Controller
            if let youtubeURL = youtubeURL {
                SafariWebView(url: youtubeURL)
                    .ignoresSafeArea(.all, edges: .bottom)
            } else {
            }
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Safari Web View Wrapper
struct SafariWebView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        config.barCollapsingEnabled = true
        
        let safari = SFSafariViewController(url: url, configuration: config)
        safari.preferredBarTintColor = .black
        safari.preferredControlTintColor = .white
        safari.dismissButtonStyle = .cancel
        
        return safari
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No need to update
    }
}
