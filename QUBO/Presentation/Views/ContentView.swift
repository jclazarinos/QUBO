// MARK: - Presentation/Views/ContentView.swift
import SwiftUI
struct ContentView: View {
    @EnvironmentObject var viewModel: GamesViewModel
    @State private var showSidebar = false
    
    var body: some View {
        ZStack {
            // Main Content Structure
            VStack(spacing: 0) {
                // Top Bar
                TopBar(viewModel: viewModel, showSidebar: $showSidebar)
                
                // Main Content Area
                MainContentView(viewModel: viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                
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
            
            // Sidebar Overlay - ANIMACIÓN MEJORADA
            ZStack {
                // Overlay background con fade
                if showSidebar {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showSidebar = false
                            }
                        }
                        .transition(.opacity)
                        .zIndex(0)
                }
                
                // Sidebar con deslizamiento
                if showSidebar {
                    HStack {
                        SidebarView(viewModel: viewModel)
                            .frame(width: 280)
                            .background(AppTheme.primaryColor)
                        
                        Spacer()
                    }
                    .transition(.move(edge: .leading))
                    .zIndex(1)
                }
            }
            .zIndex(showSidebar ? 1 : -1)
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
