// MARK: - Extensions/Game+Extensions.swift
import Foundation

extension Game {
    /// Devuelve el review limpio sin etiquetas HTML
    var cleanReview: String {
        return review.cleanHTMLForDisplay()
    }
    
    /// Versión avanzada del review limpio (usar si hay problemas con la versión básica)
    var cleanReviewAdvanced: String {
        return review.cleanHTMLAdvanced()
    }
    
    /// Preview corto del review (primeros 100 caracteres)
    var reviewPreview: String {
        let cleaned = cleanReview
        if cleaned.count <= 100 {
            return cleaned
        } else {
            return String(cleaned.prefix(100)) + "..."
        }
    }
    
    /// Indica si el review tiene contenido (no está vacío después de limpiar HTML)
    var hasReview: Bool {
        return !cleanReview.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
