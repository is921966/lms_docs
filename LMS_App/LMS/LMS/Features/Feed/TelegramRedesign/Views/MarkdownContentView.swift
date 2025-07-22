import SwiftUI

struct MarkdownContentView: View {
    let text: String
    
    private var attributedString: AttributedString {
        do {
            return try AttributedString(markdown: text)
        } catch {
            return AttributedString(text)
        }
    }
    
    var body: some View {
        Text(attributedString)
            .font(.system(size: 15))
            .foregroundColor(.primary)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .tint(.blue) // For links
    }
}

struct MarkdownContentView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            MarkdownContentView(text: "Plain text message")
            
            MarkdownContentView(text: "Text with **bold** and *italic*")
            
            MarkdownContentView(text: """
                # Header
                
                This is a paragraph with [a link](https://example.com).
                
                - List item 1
                - List item 2
                
                ```swift
                let code = "example"
                ```
                """)
        }
        .padding()
    }
} 