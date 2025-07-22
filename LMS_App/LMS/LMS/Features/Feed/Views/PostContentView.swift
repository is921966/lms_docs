import SwiftUI

struct PostContentView: View {
    let post: FeedPost
    @State private var isExpanded = false
    
    // Константы для управления сворачиванием
    private let collapsedLineLimit = 3
    private let characterLimit = 200
    
    private var isLongPost: Bool {
        post.content.count > characterLimit || post.content.components(separatedBy: .newlines).count > collapsedLineLimit
    }
    
    private var displayedContent: String {
        if isExpanded || !isLongPost {
            return post.content
        } else {
            // Обрезаем контент для свернутого вида
            let truncated = String(post.content.prefix(characterLimit))
            if let lastSpace = truncated.lastIndex(of: " ") {
                return String(truncated[..<lastSpace]) + "..."
            }
            return truncated + "..."
        }
    }
    
    // Проверка, является ли пост HTML контентом (новость о релизе)
    private var isHTMLContent: Bool {
        post.content.contains("<") && post.content.contains(">") &&
        (post.content.contains("</p>") || post.content.contains("</div>") || post.content.contains("<br"))
    }
    
    // Форматирование контента поста для правильной обработки markdown
    private func formatPostContent(_ content: String) -> String {
        var formatted = content
        
        // Исправляем случаи, когда ## стоит в конце строки без пробела
        formatted = formatted.replacingOccurrences(of: " ##", with: "")
        formatted = formatted.replacingOccurrences(of: "##\n", with: "\n")
        
        // Разбиваем длинные строки с заголовками для лучшего форматирования
        let lines = formatted.components(separatedBy: .newlines)
        var processedLines: [String] = []
        
        for line in lines {
            // Если строка содержит заголовок и другой контент, разбиваем её
            if line.hasPrefix("# ") && line.count > 50 {
                // Ищем первое вхождение ** после заголовка
                if let firstBoldRange = line.range(of: "**") {
                    let headerPart = String(line[..<firstBoldRange.lowerBound]).trimmingCharacters(in: .whitespaces)
                    let contentPart = String(line[firstBoldRange.lowerBound...])
                    processedLines.append(headerPart)
                    processedLines.append("")  // Пустая строка для разделения
                    processedLines.append(contentPart)
                } else {
                    processedLines.append(line)
                }
            } else {
                processedLines.append(line)
            }
        }
        
        return processedLines.joined(separator: "\n")
    }

    // Форматированный текст с поддержкой markdown-style разметки
    private var formattedContent: AttributedString {
        let text = displayedContent
        var attributedString = AttributedString()
        
        // Разбиваем на строки для обработки заголовков
        let lines = text.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            var processedLine = AttributedString(line)
            
            // Обработка заголовков
            if line.hasPrefix("### ") {
                let content = String(line.dropFirst(4))
                processedLine = AttributedString(content)
                processedLine.font = .headline
                processedLine.foregroundColor = .primary
            } else if line.hasPrefix("## ") {
                let content = String(line.dropFirst(3))
                processedLine = AttributedString(content)
                processedLine.font = .title3
                processedLine.foregroundColor = .primary
            } else if line.hasPrefix("# ") {
                let content = String(line.dropFirst(2))
                processedLine = AttributedString(content)
                processedLine.font = .title2
                processedLine.foregroundColor = .primary
            } else {
                // Обработка **bold** текста в обычных строках
                var workingLine = line
                var result = AttributedString()
                
                while let boldRange = workingLine.range(of: "**") {
                    // Добавляем текст до **
                    let beforeBold = String(workingLine[..<boldRange.lowerBound])
                    result.append(AttributedString(beforeBold))
                    
                    // Ищем закрывающие **
                    workingLine = String(workingLine[boldRange.upperBound...])
                    if let endRange = workingLine.range(of: "**") {
                        // Текст между ** должен быть жирным
                        let boldText = String(workingLine[..<endRange.lowerBound])
                        var boldAttr = AttributedString(boldText)
                        boldAttr.font = .body.bold()
                        result.append(boldAttr)
                        
                        // Продолжаем с оставшимся текстом
                        workingLine = String(workingLine[endRange.upperBound...])
                    } else {
                        // Нет закрывающих **, добавляем как есть
                        result.append(AttributedString("**" + workingLine))
                        break
                    }
                }
                
                // Добавляем оставшийся текст
                if !workingLine.isEmpty {
                    result.append(AttributedString(workingLine))
                }
                
                processedLine = result
            }
            
            // Обработка списков
            if line.hasPrefix("- ") {
                let content = String(line.dropFirst(2))
                processedLine = AttributedString("• " + content)
            }
            
            attributedString.append(processedLine)
            
            // Добавляем перенос строки, кроме последней строки
            if index < lines.count - 1 {
                attributedString.append(AttributedString("\n"))
            }
        }
        
        return attributedString
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Контент поста
            if isHTMLContent {
                // HTML контент для новостей о релизах
                HTMLContentWrapper(htmlContent: displayedContent)
            } else if post.content.contains("# ") || post.content.contains("## ") || post.content.contains("### ") || post.content.contains("**") {
                // Markdown контент
                MarkdownContentView(text: formatPostContent(post.content))
            } else {
                // Обычный текстовый контент
                Text(displayedContent)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .animation(.easeInOut(duration: 0.2), value: isExpanded)
                
                // Кнопка "Показать больше" / "Свернуть" для обычного текста
                if isLongPost {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Text(isExpanded ? "Свернуть" : "Показать больше")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 2)
                }
            }

            // Tags
            if let tags = post.tags, !tags.isEmpty {
                FeedFlowLayout(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 4)
            }
        }
    }
}

// MARK: - Legacy Markdown Content View (renamed to avoid conflict)

struct LegacyMarkdownContentView: View {
    let content: String
    @State private var isExpanded = false
    
    private let collapsedLineLimit = 10
    private let characterLimit = 500
    
    private var isLongContent: Bool {
        content.count > characterLimit || content.components(separatedBy: .newlines).count > collapsedLineLimit
    }
    
    private var displayedContent: String {
        if isExpanded || !isLongContent {
            return content
        } else {
            let lines = content.components(separatedBy: .newlines)
            if lines.count > collapsedLineLimit {
                return lines.prefix(collapsedLineLimit).joined(separator: "\n") + "\n..."
            }
            
            let truncated = String(content.prefix(characterLimit))
            if let lastNewline = truncated.lastIndex(of: "\n") {
                return String(truncated[..<lastNewline]) + "\n..."
            }
            return truncated + "..."
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(parseMarkdownLines(displayedContent), id: \.id) { element in
                markdownElementView(element)
                    .padding(.vertical, element.verticalPadding)
            }
            
            if isLongContent {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }) {
                    Text(isExpanded ? "Свернуть" : "Показать больше")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                .padding(.top, 8)
            }
        }
    }
    
    @ViewBuilder
    private func markdownElementView(_ element: MarkdownElement) -> some View {
        switch element.type {
        case .h1:
            Text(formatInlineMarkdown(element.content))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        case .h2:
            Text(formatInlineMarkdown(element.content))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        case .h3:
            Text(formatInlineMarkdown(element.content))
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        case .listItem:
            HStack(alignment: .top, spacing: 8) {
                Text("•")
                    .font(.body)
                    .foregroundColor(.secondary)
                Text(formatInlineMarkdown(element.content))
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
        case .paragraph:
            Text(formatInlineMarkdown(element.content))
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func formatInlineMarkdown(_ text: String) -> AttributedString {
        var attributedString = AttributedString()
        var workingText = text
        
        // Обрабатываем **жирный** текст
        let boldPattern = /\*\*([^*]+)\*\*/
        var lastIndex = workingText.startIndex
        
        while let match = workingText[lastIndex...].firstMatch(of: boldPattern) {
            // Добавляем текст до совпадения
            let beforeText = String(workingText[lastIndex..<match.range.lowerBound])
            if !beforeText.isEmpty {
                attributedString.append(AttributedString(beforeText))
            }
            
            // Добавляем жирный текст
            let boldText = String(match.1)
            var boldAttr = AttributedString(boldText)
            boldAttr.font = .body.bold()
            attributedString.append(boldAttr)
            
            // Обновляем индекс для следующего поиска
            lastIndex = match.range.upperBound
        }
        
        // Добавляем оставшийся текст
        if lastIndex < workingText.endIndex {
            let remainingText = String(workingText[lastIndex...])
            attributedString.append(AttributedString(remainingText))
        }
        
        return attributedString
    }
    
    private func parseMarkdownLines(_ text: String) -> [MarkdownElement] {
        let lines = text.components(separatedBy: .newlines)
        var elements: [MarkdownElement] = []
        var currentParagraph = ""
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.isEmpty {
                // Пустая строка - завершаем текущий параграф
                if !currentParagraph.isEmpty {
                    elements.append(MarkdownElement(type: .paragraph, content: currentParagraph.trimmingCharacters(in: .whitespaces)))
                    currentParagraph = ""
                }
            } else if trimmedLine.hasPrefix("# ") {
                // H1 заголовок
                if !currentParagraph.isEmpty {
                    elements.append(MarkdownElement(type: .paragraph, content: currentParagraph.trimmingCharacters(in: .whitespaces)))
                    currentParagraph = ""
                }
                elements.append(MarkdownElement(type: .h1, content: String(trimmedLine.dropFirst(2))))
            } else if trimmedLine.hasPrefix("## ") {
                // H2 заголовок
                if !currentParagraph.isEmpty {
                    elements.append(MarkdownElement(type: .paragraph, content: currentParagraph.trimmingCharacters(in: .whitespaces)))
                    currentParagraph = ""
                }
                elements.append(MarkdownElement(type: .h2, content: String(trimmedLine.dropFirst(3))))
            } else if trimmedLine.hasPrefix("### ") {
                // H3 заголовок
                if !currentParagraph.isEmpty {
                    elements.append(MarkdownElement(type: .paragraph, content: currentParagraph.trimmingCharacters(in: .whitespaces)))
                    currentParagraph = ""
                }
                elements.append(MarkdownElement(type: .h3, content: String(trimmedLine.dropFirst(4))))
            } else if trimmedLine.hasPrefix("- ") {
                // Элемент списка
                if !currentParagraph.isEmpty {
                    elements.append(MarkdownElement(type: .paragraph, content: currentParagraph.trimmingCharacters(in: .whitespaces)))
                    currentParagraph = ""
                }
                elements.append(MarkdownElement(type: .listItem, content: String(trimmedLine.dropFirst(2))))
            } else {
                // Обычный текст - добавляем к текущему параграфу
                if !currentParagraph.isEmpty {
                    currentParagraph += " "
                }
                currentParagraph += trimmedLine
            }
        }
        
        // Добавляем последний параграф
        if !currentParagraph.isEmpty {
            elements.append(MarkdownElement(type: .paragraph, content: currentParagraph.trimmingCharacters(in: .whitespaces)))
        }
        
        return elements
    }
    
    struct MarkdownElement: Identifiable {
        let id = UUID()
        let type: ElementType
        let content: String
        
        var verticalPadding: CGFloat {
            switch type {
            case .h1: return 8
            case .h2: return 6
            case .h3: return 4
            case .listItem: return 2
            case .paragraph: return 4
            }
        }
        
        enum ElementType {
            case h1, h2, h3, listItem, paragraph
        }
    }
}

// MARK: - Preview

#Preview {
    PostContentView(post: FeedPost(
        id: UUID().uuidString,
        author: UserResponse(
            id: "1",
            email: "test@example.com",
            name: "Test User",
            role: .student
        ),
        content: "# Заголовок\n\n## Подзаголовок\n\nЭто **жирный** текст и обычный текст.\n\n### Список:\n- Первый пункт\n- Второй пункт",
        images: [],
        attachments: [],
        createdAt: Date(),
        visibility: .everyone,
        likes: [],
        comments: [],
        tags: ["#test", "#markdown"],
        mentions: nil,
        metadata: nil
    ))
    .padding()
}

// MARK: - Flow Layout

struct FeedFlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: result.positions[index].x + bounds.minX,
                                    y: result.positions[index].y + bounds.minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - HTML Content Wrapper

struct HTMLContentWrapper: View {
    let htmlContent: String
    @State private var contentHeight: CGFloat = 300
    
    var body: some View {
        HTMLContentView(htmlContent: htmlContent, baseFont: .body)
            .frame(height: contentHeight)
            .fixedSize(horizontal: false, vertical: true)
            .onPreferenceChange(WebViewHeightKey.self) { height in
                if height > 0 {
                    contentHeight = height
                }
            }
    }
}

// MARK: - WebView Height Preference Key

struct WebViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}