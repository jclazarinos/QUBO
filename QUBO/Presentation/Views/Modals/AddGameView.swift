// MARK: - Presentation/Views/Modals/AddGameView.swift
import SwiftUI

struct AddGameView: View {
    @ObservedObject var viewModel: GamesViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var platform = ""
    @State private var completionDate = Date()
    @State private var score = 5
    @State private var review = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("NEW GAME")
                        .font(AppTheme.largeTitle)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, AppTheme.largeSpacing)
                .padding(.vertical, 20)
                .background(AppTheme.primaryColor)
                
                // Form
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
                            Text("TITLE")
                                .font(AppTheme.body)
                                .foregroundColor(.black)
                            
                            TextField("Game name", text: $title)
                                .font(AppTheme.caption)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(AppTheme.mediumCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.mediumCornerRadius)
                                        .stroke(AppTheme.textColor, lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
                            Text("PLATFORM")
                                .font(AppTheme.body)
                                .foregroundColor(.black)
                            
                            TextField("e.g. SNES, PSX, PC-Engine", text: $platform)
                                .font(AppTheme.caption)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(AppTheme.mediumCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.mediumCornerRadius)
                                        .stroke(AppTheme.textColor, lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
                            Text("COMPLETION DATE")
                                .font(AppTheme.body)
                                .foregroundColor(.black)
                            
                            DatePicker("", selection: $completionDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .font(AppTheme.caption)
                        }
                        
                        VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
                            Text("SCORE: \(score)/10")
                                .font(AppTheme.body)
                                .foregroundColor(.black)
                            
                            Slider(value: Binding(
                                get: { Double(score) },
                                set: { score = Int($0) }
                            ), in: 1...10, step: 1)
                            .accentColor(AppTheme.secondaryColor)
                        }
                        
                        VStack(alignment: .leading, spacing: AppTheme.smallSpacing) {
                            Text("PERSONAL REVIEW")
                                .font(AppTheme.body)
                                .foregroundColor(.black)
                            
                            TextEditor(text: $review)
                                .font(AppTheme.caption)
                                .frame(minHeight: 120)
                                .padding(AppTheme.smallSpacing)
                                .background(Color.white)
                                .cornerRadius(AppTheme.mediumCornerRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.mediumCornerRadius)
                                        .stroke(AppTheme.textColor, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, AppTheme.largeSpacing)
                    .padding(.top, 20)
                }
                .background(AppTheme.backgroundColor)
                
                // Save Button
                Button(action: {
                    let newGame = Game(
                        title: title,
                        platform: platform,
                        completionDate: completionDate,
                        score: score,
                        coverImage: "gamepad.fill",
                        review: review
                    )
                    viewModel.addGame(newGame)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("SAVE GAME")
                        .font(AppTheme.body)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.mediumSpacing)
                        .background(AppTheme.secondaryColor)
                        .cornerRadius(AppTheme.largeCornerRadius)
                }
                .padding(.horizontal, AppTheme.largeSpacing)
                .padding(.vertical, 20)
                .background(AppTheme.backgroundColor)
                .disabled(title.isEmpty || platform.isEmpty)
            }
            .navigationBarHidden(true)
        }
    }
}
