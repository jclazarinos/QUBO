// MARK: - Presentation/Views/Components/EnhancedImageField.swift - CORREGIDO
import SwiftUI
import PhotosUI

// MARK: - Enhanced Image Field Component (usando APIService existente)
struct EnhancedImageField: View {
    let title: String
    @Binding var imageSource: ImageSource
    @Binding var uploadedMediaId: Int?
    @Binding var finalImageURL: String
    
    @State private var imageURL: String = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var uploadState: UploadState = .idle
    @State private var showingSourcePicker = false
    
    // Validation states for URL
    @State private var isValidURL = false
    @State private var isLoadingURL = false
    @State private var validationTimer: Timer?
    
    private let validImageExtensions = ["jpg", "jpeg", "png", "gif", "webp", "bmp"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(title)
                    .font(.pixelHeading)
                    .foregroundColor(Color.darkGray)
                
                Spacer()
                
                // Upload status indicator
                uploadStatusIndicator
            }
            
            // Source Selection Buttons
            HStack(spacing: 12) {
                Button("FROM URL") {
                    showingSourcePicker = false
                    resetToURLMode()
                }
                .buttonStyle(SourceButtonStyle(isSelected: !showingSourcePicker))
                
                Button("UPLOAD") {
                    showingSourcePicker = true
                    showingImagePicker = true
                }
                .buttonStyle(SourceButtonStyle(isSelected: showingSourcePicker))
            }
            
            // URL Input (when URL mode is selected)
            if !showingSourcePicker {
                urlInputSection
            }
            
            // Image Preview
            imagePreviewSection
            
            // Upload Progress
            if case .uploading = uploadState {
                uploadProgressSection
            }
            
            // Error Display
            if case .failed(let error) = uploadState {
                errorSection(error)
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, isPresented: $showingImagePicker)
        }
        .onChange(of: selectedImage) { image in
            if let image = image {
                handleImageSelection(image)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var uploadStatusIndicator: some View {
        Group {
            switch uploadState {
            case .idle:
                EmptyView()
            case .uploading:
                ProgressView()
                    .scaleEffect(0.7)
            case .success:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.pixelBody)
            case .failed:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .font(.pixelBody)
            }
        }
    }
    
    private var urlInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
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
            
            if !imageURL.isEmpty && !isLoadingURL && !isValidURL {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                        .font(.pixelCaption)
                    
                    Text("Please enter a valid image URL")
                        .font(.pixelCaption)
                        .foregroundColor(.orange)
                }
            }
        }
    }
    
    private var imagePreviewSection: some View {
        Group {
            switch imageSource {
            case .url(let urlString):
                if isValidURL {
                    urlImagePreview(urlString)
                }
            case .device(let image):
                deviceImagePreview(image)
            case .none:
                placeholderView
            }
        }
    }
    
    private var uploadProgressSection: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Uploading image...")
                .font(.pixelBody)
                .foregroundColor(Color.darkGray)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.1))
        )
    }
    
    private var placeholderView: some View {
        VStack(spacing: 8) {
            Image(systemName: "photo")
                .font(.system(size: 32))
                .foregroundColor(Color.darkGray.opacity(0.5))
            
            Text("No image selected")
                .font(.pixelBody)
                .foregroundColor(Color.darkGray.opacity(0.7))
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.darkGray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.darkGray, style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5]))
                    )
            )
    }
    
    // MARK: - Preview Components
    
    private func urlImagePreview(_ urlString: String) -> some View {
        VStack(spacing: 8) {
            Text("PREVIEW")
                .font(.pixelCaption)
                .foregroundColor(Color.darkGray.opacity(0.7))
            
            AsyncImage(url: URL(string: urlString)) { image in
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
                        ProgressView()
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.darkGray, lineWidth: 2)
                    )
            }
            
            Button("UPLOAD THIS IMAGE") {
                uploadImageFromURL(urlString)
            }
            .buttonStyle(ActionButtonStyle())
        }
    }
    
    private func deviceImagePreview(_ image: UIImage) -> some View {
        VStack(spacing: 8) {
            Text("SELECTED IMAGE")
                .font(.pixelCaption)
                .foregroundColor(Color.darkGray.opacity(0.7))
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 120)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.darkGray, lineWidth: 2)
                )
            
            Button("UPLOAD THIS IMAGE") {
                uploadImageFromDevice(image)
            }
            .buttonStyle(ActionButtonStyle())
        }
    }
    
    private func errorSection(_ error: Error) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.red)
            Text("Upload failed: \(error.localizedDescription)")
                .font(.pixelCaption)
                .foregroundColor(.red)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.red.opacity(0.1))
        )
    }
    
    // MARK: - Methods
    
    private func resetToURLMode() {
        selectedImage = nil
        imageSource = .none
        uploadState = .idle
    }
    
    private func handleURLChange(_ newValue: String) {
        validationTimer?.invalidate()
        isValidURL = false
        isLoadingURL = false
        
        guard !newValue.isEmpty else {
            imageSource = .none
            return
        }
        
        isLoadingURL = true
        validationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            validateImageURL(newValue)
        }
    }
    
    private func validateImageURL(_ urlString: String) {
        guard isValidImageURL(urlString), let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.isLoadingURL = false
                self.isValidURL = false
                self.imageSource = .none
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoadingURL = false
                
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200,
                   let data = data, data.count > 0 {
                    self.isValidURL = true
                    self.imageSource = .url(urlString)
                } else {
                    self.isValidURL = false
                    self.imageSource = .none
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
    
    private func handleImageSelection(_ image: UIImage) {
        imageSource = .device(image)
        showingSourcePicker = true
        uploadState = .idle
    }
    
    // MARK: - Upload Methods (usando APIService existente)
    
    private func uploadImageFromURL(_ urlString: String) {
        uploadState = .uploading
        
        Task {
            do {
                // 1. Descargar la imagen desde la URL
                guard let url = URL(string: urlString) else {
                    throw APIError.invalidURL
                }
                
                let (imageData, _) = try await URLSession.shared.data(from: url)
                
                // 2. Extraer nombre del archivo
                let fileName = url.lastPathComponent.isEmpty ? "image.jpg" : url.lastPathComponent
                
                // 3. Usar APIService.uploadImage existente
                let response = try await APIService.shared.uploadImage(imageData, fileName: fileName)
                
                await MainActor.run {
                    self.uploadState = .success(response)
                    self.uploadedMediaId = response.id
                    self.finalImageURL = response.sourceUrl
                }
            } catch {
                await MainActor.run {
                    self.uploadState = .failed(error)
                }
            }
        }
    }
    
    private func uploadImageFromDevice(_ image: UIImage) {
        uploadState = .uploading
        
        Task {
            do {
                // 1. Convertir UIImage a Data
                guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                    throw APIError.invalidURL
                }
                
                // 2. Generar nombre único
                let timestamp = Int(Date().timeIntervalSince1970)
                let fileName = "game_cover_\(timestamp).jpg"
                
                // 3. Usar APIService.uploadImage existente
                let response = try await APIService.shared.uploadImage(imageData, fileName: fileName)
                
                await MainActor.run {
                    self.uploadState = .success(response)
                    self.uploadedMediaId = response.id
                    self.finalImageURL = response.sourceUrl
                }
            } catch {
                await MainActor.run {
                    self.uploadState = .failed(error)
                }
            }
        }
    }
}

// MARK: - Supporting Types
enum ImageSource {
    case url(String)
    case device(UIImage)
    case none
    
    var hasImage: Bool {
        switch self {
        case .none:
            return false
        default:
            return true
        }
    }
}

enum UploadState {
    case idle
    case uploading
    case success(MediaUploadResponse)
    case failed(Error)
    
    var isUploading: Bool {
        if case .uploading = self {
            return true
        }
        return false
    }
}

// MARK: - Button Styles
struct SourceButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.pixelCaption)
            .foregroundColor(isSelected ? .white : Color.darkGray)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.retroBlue : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.darkGray, lineWidth: 2)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct ActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.pixelBody)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.arcadeYellow)
            .cornerRadius(6)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.isPresented = false
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}
