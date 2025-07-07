import SwiftUI

// MARK: - Platform Picker View (reutilizado del AddGameView)
struct PlatformPickerView: View {
    @Binding var selectedPlatform: String
    let availablePlatforms: [String]
    @Binding var isPresented: Bool
    
    @State private var searchText = ""
    
    var filteredPlatforms: [String] {
        if searchText.isEmpty {
            return availablePlatforms
        } else {
            return availablePlatforms.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                TextField("Search platforms...", text: $searchText)
                    .font(.pixelBody)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.darkGray, lineWidth: 2)
                    )
                    .padding(.horizontal)
                    .padding(.top)
                
                // Platform list
                List {
                    ForEach(filteredPlatforms, id: \.self) { platform in
                        Button(action: {
                            selectedPlatform = platform
                            isPresented = false
                        }) {
                            HStack {
                                Text(platform)
                                    .foregroundColor(Color.darkGray)
                                    .font(.pixelBody)
                                Spacer()
                                if selectedPlatform == platform {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(Color.retroBlue)
                                        .font(.pixelBody)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Platform")
            .navigationBarTitleDisplayMode(.inline)
            .font(.pixelHeading)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .font(.pixelBody)
                }
            }
        }
    }
}
