// MARK: - Extensions/JustifiedText.swift - Texto justificado CORREGIDO
import SwiftUI

// MARK: - Justified Text View
struct JustifiedText: View {
    let text: String
    let font: Font
    let lineSpacing: CGFloat
    let foregroundColor: Color
    
    init(_ text: String, font: Font = .body, lineSpacing: CGFloat = 4, foregroundColor: Color = .primary) {
        self.text = text
        self.font = font
        self.lineSpacing = lineSpacing
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        JustifiedTextRepresentable(
            text: text,
            font: UIFont.systemFont(ofSize: 16), // Ajustar según font
            lineSpacing: lineSpacing,
            textColor: UIColor(foregroundColor)
        )
        .fixedSize(horizontal: false, vertical: true) // CLAVE: Permite altura flexible pero ancho fijo
    }
}

// MARK: - UIViewRepresentable para texto justificado MEJORADO
struct JustifiedTextRepresentable: UIViewRepresentable {
    let text: String
    let font: UIFont
    let lineSpacing: CGFloat
    let textColor: UIColor
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        
        // MEJORAS para evitar desacomodo:
        textView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.textContainer.widthTracksTextView = true
        textView.textContainer.heightTracksTextView = false
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified
        paragraphStyle.lineSpacing = lineSpacing
        
        let attributedString = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: textColor,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        textView.attributedText = attributedString
        
        // Asegurar que el tamaño se calcule correctamente
        textView.sizeToFit()
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        guard let width = proposal.width else { return nil }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified
        paragraphStyle.lineSpacing = lineSpacing
        
        let attributedString = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: textColor,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        let constraintSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingRect = attributedString.boundingRect(
            with: constraintSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        return CGSize(width: width, height: ceil(boundingRect.height))
    }
}

// MARK: - Extensión de Text para justificación (método alternativo simple)
extension Text {
    func justified() -> some View {
        self.multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Componente personalizado para texto justificado CORREGIDO
struct GameDescriptionText: View {
    let text: String
    
    var body: some View {
        JustifiedText(
            text,
            font: .system(size: 16, weight: .regular),
            lineSpacing: 6,
            foregroundColor: .secondary
        )
    }
}

struct GameReviewText: View {
    let text: String
    
    var body: some View {
        JustifiedText(
            text,
            font: .system(size: 16, weight: .regular),
            lineSpacing: 6,
            foregroundColor: .primary
        )
    }
}

// MARK: - Versión alternativa simple (sin UIKit) si sigue dando problemas
struct SimpleJustifiedText: View {
    let text: String
    let font: Font
    let lineSpacing: CGFloat
    let foregroundColor: Color
    
    var body: some View {
        Text(text)
            .font(font)
            .foregroundColor(foregroundColor)
            .lineSpacing(lineSpacing)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Componentes alternativos simples
struct SimpleGameDescriptionText: View {
    let text: String
    
    var body: some View {
        SimpleJustifiedText(
            text: text,
            font: .system(size: 16, weight: .regular),
            lineSpacing: 6,
            foregroundColor: .secondary
        )
    }
}

struct SimpleGameReviewText: View {
    let text: String
    
    var body: some View {
        SimpleJustifiedText(
            text: text,
            font: .system(size: 16, weight: .regular),
            lineSpacing: 6,
            foregroundColor: .primary
        )
    }
}
