//
//  HTMLContentView.swift
//  LMS
//
//  Компонент для отображения HTML контента в ленте новостей
//

import SwiftUI
import WebKit

struct HTMLContentView: UIViewRepresentable {
    let htmlContent: String
    let baseFont: Font
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .clear
        webView.isOpaque = false
        
        // Отключаем масштабирование и взаимодействие
        webView.scrollView.isUserInteractionEnabled = false
        webView.scrollView.bounces = false
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let adaptedHTML = wrapHTMLContent(htmlContent)
        webView.loadHTMLString(adaptedHTML, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func wrapHTMLContent(_ content: String) -> String {
        // Получаем цвета для текущей темы
        let textColor = UIColor.label.hexString
        let backgroundColor = UIColor.systemBackground.hexString
        let secondaryColor = UIColor.secondaryLabel.hexString
        
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                * {
                    margin: 0;
                    padding: 0;
                    -webkit-text-size-adjust: none;
                    -webkit-user-select: none;
                    user-select: none;
                }
                body {
                    font-family: -apple-system, system-ui, 'Helvetica Neue', Helvetica, Arial, sans-serif;
                    font-size: 16px;
                    line-height: 1.5;
                    color: \(textColor);
                    background-color: \(backgroundColor);
                    padding: 0;
                    margin: 0;
                    overflow-x: hidden;
                }
                h1 {
                    font-size: 24px;
                    font-weight: 600;
                    margin-bottom: 12px;
                    color: \(textColor);
                }
                h2 {
                    font-size: 20px;
                    font-weight: 600;
                    margin-bottom: 10px;
                    color: \(textColor);
                }
                h3 {
                    font-size: 16px;
                    font-weight: 600;
                    margin-bottom: 8px;
                    color: \(secondaryColor);
                }
                ul {
                    margin: 0;
                    padding-left: 20px;
                }
                li {
                    margin-bottom: 5px;
                    line-height: 1.5;
                }
                a {
                    color: #007AFF;
                    text-decoration: none;
                }
                .content-wrapper {
                    padding: 0;
                }
            </style>
        </head>
        <body>
            <div class="content-wrapper">
                \(content)
            </div>
        </body>
        </html>
        """
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: HTMLContentView
        
        init(_ parent: HTMLContentView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Автоматически подстраиваем высоту под контент
            webView.evaluateJavaScript("document.body.scrollHeight") { height, error in
                if let height = height as? CGFloat {
                    DispatchQueue.main.async {
                        webView.constraints.forEach { constraint in
                            if constraint.firstAttribute == .height {
                                constraint.constant = height
                            }
                        }
                    }
                }
            }
        }
    }
}

// Extension для конвертации UIColor в hex string
extension UIColor {
    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return String(format: "#%02X%02X%02X", 
                     Int(red * 255), 
                     Int(green * 255), 
                     Int(blue * 255))
    }
} 