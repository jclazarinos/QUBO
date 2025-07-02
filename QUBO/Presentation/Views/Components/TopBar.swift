// MARK: - Presentation/Views/Components/TopBar.swift
import SwiftUI

struct TopBar: View {
    @ObservedObject var viewModel: GamesViewModel
    @Binding var showSidebar: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Sidebar Toggle Button
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showSidebar.toggle()
                }
            } label: {
                Image(systemName: "sidebar.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.2))
                    )
            }
            
            // Title Section
            VStack(alignment: .leading, spacing: 2) {
                Text("COMPLETED GAMES")
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundColor(.white)
                
                Text("\(viewModel.totalGamesCount) games")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Status and Actions
            HStack(spacing: 12) {
                // API Status Indicator
                HStack(spacing: 6) {
                    Circle()
                        .fill(viewModel.useRemoteAPI ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                    
                    Text(viewModel.useRemoteAPI ? "API" : "LOCAL")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                )
                
                // Refresh Button
                Button {
                    viewModel.refreshGames()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                        .animation(
                            viewModel.isLoading ?
                            .linear(duration: 1).repeatForever(autoreverses: false) :
                            .default,
                            value: viewModel.isLoading
                        )
                }
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.2))
                )
                .disabled(viewModel.isLoading)
                
                // Add Game Button
                Button {
                    viewModel.showingAddGame = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(AppTheme.secondaryColor)
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.opacity(0.8)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}

// MARK: - Preview
struct TopBar_Previews: PreviewProvider {
    static var previews: some View {
        TopBar(
            viewModel: GamesViewModel(gameUseCases: GameUseCases(repository: GameRepository(localDataSource: LocalGameDataSource(), remoteDataSource: RemoteGameDataSource()))),
            showSidebar: .constant(false)
        )
        .previewLayout(.sizeThatFits)
    }
}
