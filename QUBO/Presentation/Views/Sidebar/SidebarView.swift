// MARK: - Presentation/Views/Sidebar/SidebarView.swift
import SwiftUI

struct SidebarView: View {
    @ObservedObject var viewModel: GamesViewModel
    @State private var showViewOptions = false
    @State private var showSortOptions = false
    @State private var showThemeOptions = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Logo
            VStack(spacing: AppTheme.mediumSpacing) {
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: AppTheme.largeIconSize))
                    .foregroundColor(.white)
                
                Text("RETRO\nGAMES")
                    .font(AppTheme.title)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 60) // Extra padding for status bar
            .padding(.bottom, 30)
            
            // Games counter
            HStack {
                Text("\(viewModel.totalGamesCount)")
                    .font(.title.bold())
                    .foregroundColor(AppTheme.secondaryColor)
                
                Text("GAMES")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
            }
            .padding(.horizontal, AppTheme.mediumSpacing)
            .padding(.bottom, 20)
            
            // Menu Options
            VStack(spacing: 0) {
                // View Type
                AccordionSection(
                    title: "VIEW",
                    isExpanded: $showViewOptions,
                    content: {
                        ForEach(ViewType.allCases, id: \.self) { viewType in
                            MenuButton(
                                title: viewType.rawValue,
                                isSelected: viewModel.viewType == viewType
                            ) {
                                viewModel.viewType = viewType
                            }
                        }
                    }
                )
                
                // Sort Options
                AccordionSection(
                    title: "SORT BY",
                    isExpanded: $showSortOptions,
                    content: {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            MenuButton(
                                title: option.rawValue,
                                isSelected: viewModel.sortOption == option
                            ) {
                                viewModel.sortOption = option
                            }
                        }
                    }
                )
                
                // Theme
                AccordionSection(
                    title: "THEME",
                    isExpanded: $showThemeOptions,
                    content: {
                        ForEach(Theme.allCases, id: \.self) { theme in
                            MenuButton(
                                title: theme.rawValue,
                                isSelected: viewModel.selectedTheme == theme
                            ) {
                                viewModel.selectedTheme = theme
                            }
                        }
                    }
                )
                
                // API Status Section
                AccordionSection(
                    title: "DATA SOURCE",
                    isExpanded: .constant(false),
                    content: {
                        VStack(spacing: 8) {
                            HStack {
                                Circle()
                                    .fill(viewModel.useRemoteAPI ? Color.green : Color.orange)
                                    .frame(width: 8, height: 8)
                                
                                Text(viewModel.useRemoteAPI ? "WordPress API" : "Local Data")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Spacer()
                            }
                            
                            // Toggle comentado por ahora
                            // Toggle("Use Remote API", isOn: $viewModel.useRemoteAPI)
                            //     .toggleStyle(SwitchToggleStyle(tint: AppTheme.secondaryColor))
                        }
                    }
                )
            }
            .padding(.horizontal, AppTheme.mediumSpacing)
            
            Spacer()
            
            // Add Game Button
            Button(action: {
                viewModel.showingAddGame = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("NEW GAME")
                        .font(AppTheme.body)
                }
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(AppTheme.secondaryColor)
                .cornerRadius(AppTheme.mediumCornerRadius)
            }
            .padding(.horizontal, AppTheme.mediumSpacing)
            .padding(.bottom, 40)
        }
        .background(AppTheme.primaryColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .shadow(radius: 10)
    }
}
