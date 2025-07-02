// MARK: - Presentation/Views/Sidebar/AccordionSection.swift
import SwiftUI

struct AccordionSection<Content: View>: View {
    let title: String
    @Binding var isExpanded: Bool
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(title)
                        .font(AppTheme.body)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.white)
                        .font(.system(size: 12, weight: .bold))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, AppTheme.smallSpacing)
            }
            
            if isExpanded {
                VStack(spacing: 4) {
                    content
                }
                .padding(.horizontal, AppTheme.mediumSpacing)
                .padding(.bottom, AppTheme.smallSpacing)
            }
        }
        .background(AppTheme.primaryColor)
    }
}
