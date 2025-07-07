// MARK: - YouTubePlayerView.swift - Reproductor completo con UIKit
import SwiftUI
import WebKit

// MARK: - YouTube Player completo
struct YouTubePlayerView: View {
    let videoId: String
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = true
    @State private var hasError = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if hasError {
                    ErrorView(videoId: videoId)
                } else {
                    YouTubeWebView(
                        videoId: videoId,
                        isLoading: $isLoading,
                        hasError: $hasError
                    )
                    .ignoresSafeArea(.all, edges: .bottom)
                }
                
                // Loading overlay
                if isLoading && !hasError {
                    LoadingOverlay()
                }
            }
            .navigationTitle("Trailer")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarStyle()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // Botón de recarga
                        Button(action: {
                            hasError = false
                            isLoading = true
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.white)
                        }
                        
                        // Abrir en YouTube/Safari
                        Menu {
                            if let youtubeURL = URL(string: "youtube://watch?v=\(videoId)") {
                                Link("Open in YouTube App", destination: youtubeURL)
                            }
                            
                            if let safariURL = URL(string: "https://www.youtube.com/watch?v=\(videoId)") {
                                Link("Open in Safari", destination: safariURL)
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - YouTube WebView mejorado
struct YouTubeWebView: UIViewRepresentable {
    let videoId: String
    @Binding var isLoading: Bool
    @Binding var hasError: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // Mejoras para mejor rendimiento
        configuration.preferences.javaScriptEnabled = true
        configuration.allowsPictureInPictureMediaPlayback = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .black
        webView.isOpaque = false
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let embedHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
            <style>
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                }
                body {
                    background-color: #000;
                    overflow: hidden;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    height: 100vh;
                }
                .video-container {
                    position: relative;
                    width: 100%;
                    height: 100%;
                    background: #000;
                }
                iframe {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    border: none;
                    background: #000;
                }
            </style>
        </head>
        <body>
            <div class="video-container">
                <iframe
                    src="https://www.youtube.com/embed/\(videoId)?autoplay=0&playsinline=1&enablejsapi=1&rel=0&modestbranding=1&controls=1&showinfo=0&fs=1&cc_load_policy=0&iv_load_policy=3&origin=\(Bundle.main.bundleIdentifier ?? "com.yourapp")"
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                    allowfullscreen
                    frameborder="0"
                    title="YouTube video player">
                </iframe>
            </div>
            
            <script>
                // Manejar carga del iframe
                document.querySelector('iframe').onload = function() {
                    console.log('YouTube iframe loaded');
                    setTimeout(function() {
                        if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.videoReady) {
                            window.webkit.messageHandlers.videoReady.postMessage('ready');
                        }
                    }, 1000);
                };
                
                // Fallback para ocultar loading
                setTimeout(function() {
                    if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.videoReady) {
                        window.webkit.messageHandlers.videoReady.postMessage('ready');
                    }
                }, 4000);
            </script>
        </body>
        </html>
        """
        
        webView.loadHTMLString(embedHTML, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        let parent: YouTubeWebView
        
        init(_ parent: YouTubeWebView) {
            self.parent = parent
            super.init()
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            parent.hasError = false
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Auto-hide loading después de un delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.parent.isLoading = false
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            
            // Ignorar errores de cancelación (-999) y errores de frame
            if nsError.code == NSURLErrorCancelled || nsError.code == 102 {
                print("YouTube WebView: Navigation cancelled (normal behavior)")
                return
            }
            
            parent.isLoading = false
            parent.hasError = true
            print("YouTube WebView failed: \(error)")
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let nsError = error as NSError
            
            // Ignorar errores comunes de YouTube embed
            if nsError.code == NSURLErrorCancelled || nsError.code == 102 {
                print("YouTube WebView: Provisional navigation cancelled (normal behavior)")
                // No marcar como error, YouTube embed funciona así
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.parent.isLoading = false
                }
                return
            }
            
            parent.isLoading = false
            parent.hasError = true
            print("YouTube WebView provisional navigation failed: \(error)")
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "videoReady" {
                DispatchQueue.main.async {
                    self.parent.isLoading = false
                }
            }
        }
    }
}

// MARK: - Loading Overlay
struct LoadingOverlay: View {
    @State private var rotation = 0.0
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "play.circle")
                .font(.system(size: 50))
                .foregroundColor(.white)
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            
            Text("Loading video...")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Please wait")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
    }
}

// MARK: - Error View
struct ErrorView: View {
    let videoId: String
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Unable to load video")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Text("The video might be unavailable or you may not have an internet connection.")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            VStack(spacing: 12) {
                if let youtubeURL = URL(string: "youtube://watch?v=\(videoId)") {
                    Link(destination: youtubeURL) {
                        HStack {
                            Image(systemName: "play.rectangle.fill")
                            Text("Open in YouTube App")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
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
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

// MARK: - Navigation Bar Style
extension View {
    func navigationBarStyle() -> some View {
        self.toolbarBackground(Color.black.opacity(0.8), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
