// MARK: - Presentation/Views/Components/FormField.swift
import SwiftUI

// MARK: - Form Field Component
struct FormField<Content: View>: View {
    let title: String
    let isRequired: Bool
    let content: Content
    
    init(title: String, isRequired: Bool = false, @ViewBuilder content: () -> Content) {
        self.title = title
        self.isRequired = isRequired
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.pixelHeading)
                    .foregroundColor(Color.darkGray)
                
                if isRequired {
                    Text("*")
                        .font(.pixelHeading)
                        .foregroundColor(Color.snesRed)
                }
                
                Spacer()
            }
            
            content
        }
    }
}
