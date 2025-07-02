// MARK: - Presentation/Views/ContentView.swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: GamesViewModel
    @State private var showSidebar = false
    
    var body: some View {
        ZStack {
            // Main Content (always visible)
            HStack(spacing: 0) {
                // Main Content Area
                MainContentView(viewModel: viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .navigationTitle("Games")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showSidebar.toggle()
                                }
                            } label: {
                                Image(systemName: "sidebar.left")
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            HStack {
                                // API Status Indicator
                                Circle()
                                    .fill(viewModel.useRemoteAPI ? Color.green : Color.orange)
                                    .frame(width: 8, height: 8)
                                
                                // Toggle para API/Local (opcional, comentado por ahora)
                                // Toggle("API", isOn: $viewModel.useRemoteAPI)
                                //     .toggleStyle(SwitchToggleStyle(tint: .blue))
                                
                                // Refresh button
                                Button {
                                    viewModel.refreshGames()
                                } label: {
                                    Image(systemName: "arrow.clockwise")
                                        .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                                        .animation(
                                            viewModel.isLoading ?
                                            .linear(duration: 1).repeatForever(autoreverses: false) :
                                            .default,
                                            value: viewModel.isLoading
                                        )
                                }
                                .disabled(viewModel.isLoading)
                            }
                        }
                    }
                    .overlay(
                        // Loading indicator
                        Group {
                            if viewModel.isLoading {
                                ZStack {
                                    Color.black.opacity(0.3)
                                        .ignoresSafeArea()
                                    
                                    VStack(spacing: 16) {
                                        ProgressView()
                                            .scaleEffect(1.2)
                                        Text("Loading games...")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                    .padding(24)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.ultraThinMaterial)
                                    )
                                }
                            }
                        }
                    )
            }
            
            // Sidebar Overlay (slides in from left)
            if showSidebar {
                HStack(spacing: 0) {
                    // Sidebar
                    SidebarView(viewModel: viewModel)
                        .frame(width: 280)
                        .transition(.move(edge: .leading))
                        .zIndex(1)
                    
                    // Overlay to close sidebar when tapping outside
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showSidebar = false
                            }
                        }
                }
            }
        }
        .sheet(isPresented: $viewModel.showingAddGame) {
            AddGameView(viewModel: viewModel)
        }
        .sheet(item: $viewModel.selectedGame) { game in
            GameDetailView(game: game, viewModel: viewModel)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPad Pro (12.9-inch)")
    }
}
