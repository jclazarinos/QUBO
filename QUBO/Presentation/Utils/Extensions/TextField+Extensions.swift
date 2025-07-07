// MARK: - Presentation/Utils/Extensions/TextField+Extensions.swift
import SwiftUI

// MARK: - TextField Style Extensions
extension TextField {
    /// Estilo pixel/retro para campos de texto
    func textFieldStyle() -> some View {
        self
            .font(.pixelBody)
            .padding(12)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.darkGray, lineWidth: 2)
            )
    }
    
    /// Estilo pixel para campos de texto con estado de error
    func textFieldStyle(isError: Bool = false) -> some View {
        self
            .font(.pixelBody)
            .padding(12)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isError ? Color.snesRed : Color.darkGray, lineWidth: 2)
            )
    }
    
    /// Estilo pixel para campos de texto con validación
    func textFieldStyle(validationState: ValidationState) -> some View {
        self
            .font(.pixelBody)
            .padding(12)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(validationState.borderColor, lineWidth: 2)
            )
    }
}

// MARK: - Validation State
enum ValidationState {
    case normal
    case valid
    case invalid
    case loading
    
    var borderColor: Color {
        switch self {
        case .normal:
            return Color.darkGray
        case .valid:
            return .green
        case .invalid:
            return Color.snesRed
        case .loading:
            return Color.retroBlue
        }
    }
}
