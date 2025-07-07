// MARK: - Extensions/String+HTMLCleaner.swift
import Foundation

extension String {
    /// Elimina todas las etiquetas HTML del string
    func stripHTML() -> String {
        return self
            // Eliminar todas las etiquetas HTML
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            // Convertir \r\n a saltos de línea normales
            .replacingOccurrences(of: "\\r\\n", with: "\n")
            // Decodificar entidades HTML comunes
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&apos;", with: "'")
            // Limpiar espacios en blanco al inicio y final
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Limpia HTML y formatea para mostrar en la UI
    func cleanHTMLForDisplay() -> String {
        return self.stripHTML()
            // Dividir por líneas
            .components(separatedBy: .newlines)
            // Filtrar líneas vacías
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            // Unir con doble salto de línea para párrafos
            .joined(separator: "\n\n")
    }
    
    /// Versión más robusta que maneja casos especiales
    func cleanHTMLAdvanced() -> String {
        var cleanedText = self
        
        // Reemplazar etiquetas de párrafo con saltos de línea
        cleanedText = cleanedText.replacingOccurrences(
            of: "</p>\\s*<p[^>]*>",
            with: "\n\n",
            options: [.regularExpression, .caseInsensitive]
        )
        
        // Reemplazar <br> con saltos de línea
        cleanedText = cleanedText.replacingOccurrences(
            of: "<br\\s*/?>",
            with: "\n",
            options: [.regularExpression, .caseInsensitive]
        )
        
        // Eliminar todas las etiquetas HTML restantes
        cleanedText = cleanedText.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression
        )
        
        // Limpiar caracteres especiales
        cleanedText = cleanedText
            .replacingOccurrences(of: "\\r\\n", with: "\n")
            .replacingOccurrences(of: "\\r", with: "\n")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&apos;", with: "'")
        
        // Normalizar espacios múltiples
        cleanedText = cleanedText.replacingOccurrences(
            of: " +",
            with: " ",
            options: .regularExpression
        )
        
        // Normalizar múltiples saltos de línea
        cleanedText = cleanedText.replacingOccurrences(
            of: "\n{3,}",
            with: "\n\n",
            options: .regularExpression
        )
        
        return cleanedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
