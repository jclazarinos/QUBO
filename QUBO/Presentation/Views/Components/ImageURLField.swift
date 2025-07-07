// MARK: - Presentation/Views/Components/ImageURLField.swift
import SwiftUI

// MARK: - Image URL Field Component
struct ImageURLField: View {
    let title: String
    @Binding var imageURL: String
    @State private var isValidURL = false
    @State private var isLoading = false
    @State private var showPreview = false
    
    // Timer para delay en la validación
    @State private var validationTimer: Timer?
    
    private let validImageExtensions = ["jpg", "jpeg", "png", "gif", "webp", "bmp", "svg"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header (estilo consistente con FormField)
            HStack {
                Text(title)
                    .font(.pixelHeading)
                    .foregroundColor(Color.darkGray)
                
                Spacer()
                
                // Status indicator
                if !imageURL.isEmpty {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.7)
                    } else if isValidURL {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.pixelBody)
                    } else {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.pixelBody)
                    }
                }
            }
            
            // URL Input Field (mismo estilo que otros TextField)
            TextField("https://example.com/image.jpg", text: $imageURL)
                .font(.pixelBody)
                .padding(12)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.darkGray, lineWidth: 2)
                )
                .autocapitalization(.none)
                .keyboardType(.URL)
                .onChange(of: imageURL) { newValue in
                    handleURLChange(newValue)
                }
            
            // Validation feedback (más sutil)
            if !imageURL.isEmpty && !isLoading && !isValidURL {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                        .font(.pixelCaption)
                    
                    Text("Please enter a valid image URL")
                        .font(.pixelCaption)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 4)
            }
            
            // Image Preview (solo si es válida)
            if showPreview && isValidURL && !imageURL.isEmpty {
                VStack(spacing: 8) {
                    Text("PREVIEW")
                        .font(.pixelCaption)
                        .foregroundColor(Color.darkGray.opacity(0.7))
                    
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 120)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.darkGray, lineWidth: 2)
                            )
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .frame(height: 80)
                            .overlay(
                                VStack(spacing: 4) {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Loading...")
                                        .font(.pixelCaption)
                                        .foregroundColor(Color.darkGray.opacity(0.7))
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.darkGray, lineWidth: 2)
                            )
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            // Supported formats info (solo cuando está vacío)
            if imageURL.isEmpty {
                VStack(spacing: 4) {
                    Text("SUPPORTED: JPG, PNG, GIF, WEBP, SVG")
                        .font(.pixelCaption)
                        .foregroundColor(Color.darkGray.opacity(0.6))
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Computed Properties (simplificadas)
    
    private var feedbackIcon: String {
        return "exclamationmark.triangle"
    }
    
    private var feedbackColor: Color {
        return .orange
    }
    
    // MARK: - Methods
    
    private func handleURLChange(_ newValue: String) {
        // Cancel previous timer
        validationTimer?.invalidate()
        
        // Reset states
        isValidURL = false
        showPreview = false
        
        guard !newValue.isEmpty else {
            isLoading = false
            return
        }
        
        // Start loading state
        isLoading = true
        
        // Validate after 1 second delay
        validationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            validateImageURL(newValue)
        }
    }
    
    private func validateImageURL(_ urlString: String) {
        guard isValidImageURL(urlString),
              let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.isValidURL = false
                self.showPreview = false
            }
            return
        }
        
        // Test if image is accessible
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200,
                   let data = data,
                   data.count > 0 {
                    self.isValidURL = true
                    
                    // Show preview after another short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            self.showPreview = true
                        }
                    }
                } else {
                    self.isValidURL = false
                    self.showPreview = false
                }
            }
        }.resume()
    }
    
    private func isValidImageURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString),
              url.scheme == "http" || url.scheme == "https" else {
            return false
        }
        
        let pathExtension = url.pathExtension.lowercased()
        return validImageExtensions.contains(pathExtension) || pathExtension.isEmpty
    }
}

// MARK: - Image Preview Component (simplificado)
struct ImagePreview: View {
    let imageURL: String
    
    var body: some View {
        AsyncImage(url: URL(string: imageURL)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 120)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.darkGray, lineWidth: 2)
                )
        } placeholder: {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .frame(height: 80)
                .overlay(
                    VStack(spacing: 4) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading...")
                            .font(.pixelCaption)
                            .foregroundColor(Color.darkGray.opacity(0.7))
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.darkGray, lineWidth: 2)
                )
        }
        .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - Quick Image URL Suggestions (eliminado - ya no se necesita)
