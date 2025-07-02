// MARK: - Presentation/Views/Sidebar/MenuButton.swift
import SwiftUI

struct MenuButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(AppTheme.caption)
                    .foregroundColor(isSelected ? .black : .white)
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.black)
                        .font(.system(size: 12))
                }
            }
            .padding(.vertical, AppTheme.smallSpacing)
            .padding(.horizontal, 12)
            .background(isSelected ? AppTheme.secondaryColor : Color.clear)
            .cornerRadius(AppTheme.smallCornerRadius)
        }
    }
}
