import Foundation
import SwiftUI
import PDFKit

// MARK: - PDF Export Service
class PDFExportService {
    static let shared = PDFExportService()
    
    private init() {}
    
    // MARK: - Export Methods
    
    func exportReportToPDF(_ report: Report, completion: @escaping (Result<URL, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let pdfData = try self.generateReportPDF(report)
                let url = try self.savePDFToFile(pdfData, fileName: "Report_\(report.title)_\(Date().timeIntervalSince1970).pdf")
                
                DispatchQueue.main.async {
                    completion(.success(url))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func exportCertificateToPDF(_ certificate: Certificate, user: UserResponse, completion: @escaping (Result<URL, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let pdfData = try self.generateCertificatePDF(certificate, user: user)
                let url = try self.savePDFToFile(pdfData, fileName: "Certificate_\(certificate.id).pdf")
                
                DispatchQueue.main.async {
                    completion(.success(url))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func exportOnboardingReportToPDF(_ program: OnboardingProgram, completion: @escaping (Result<URL, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let pdfData = try self.generateOnboardingReportPDF(program)
                let url = try self.savePDFToFile(pdfData, fileName: "Onboarding_\(program.template.name)_\(Date().timeIntervalSince1970).pdf")
                
                DispatchQueue.main.async {
                    completion(.success(url))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - PDF Generation
    
    private func generateReportPDF(_ report: Report) throws -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "LMS App",
            kCGPDFContextAuthor: report.createdBy,
            kCGPDFContextTitle: report.title
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4 size
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            // Draw header
            drawHeader(report.title, in: context, at: CGPoint(x: 50, y: 50))
            
            // Draw metadata
            var yPosition: CGFloat = 120
            drawText("Тип: \(report.type.rawValue)", at: CGPoint(x: 50, y: yPosition), fontSize: 12)
            yPosition += 25
            drawText("Период: \(report.period.rawValue)", at: CGPoint(x: 50, y: yPosition), fontSize: 12)
            yPosition += 25
            drawText("Создан: \(formatDate(report.createdAt ?? Date()))", at: CGPoint(x: 50, y: yPosition), fontSize: 12)
            yPosition += 40
            
            // Draw description
            if !report.description.isEmpty {
                drawMultilineText(report.description, at: CGPoint(x: 50, y: yPosition), width: 495, fontSize: 14)
                yPosition += 60
            }
            
            // Draw sections
            for section in report.sections {
                if yPosition > 700 {
                    context.beginPage()
                    yPosition = 50
                }
                
                drawSectionHeader(section.title, at: CGPoint(x: 50, y: yPosition))
                yPosition += 30
                
                // Handle different section data types
                switch section.data {
                case .text(let content):
                    drawMultilineText(content, at: CGPoint(x: 50, y: yPosition), width: 495, fontSize: 12)
                    yPosition += CGFloat(content.count / 80 * 20) + 40
                case .summary(let summaryData):
                    let summaryText = summaryData.highlights.joined(separator: "\n")
                    drawMultilineText(summaryText, at: CGPoint(x: 50, y: yPosition), width: 495, fontSize: 12)
                    yPosition += CGFloat(summaryText.count / 80 * 20) + 40
                default:
                    // For other types, just show a placeholder
                    drawText("[Section type: \(section.type.rawValue)]", at: CGPoint(x: 50, y: yPosition), fontSize: 12, color: .gray)
                    yPosition += 40
                }
            }
            
            // Draw footer
            drawFooter(in: context, pageNumber: 1)
        }
        
        return data
    }
    
    private func generateCertificatePDF(_ certificate: Certificate, user: UserResponse) throws -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 842, height: 595) // A4 landscape
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            // Draw border
            let borderRect = pageRect.insetBy(dx: 20, dy: 20)
            context.cgContext.setStrokeColor(UIColor.systemBlue.cgColor)
            context.cgContext.setLineWidth(3)
            context.cgContext.addRect(borderRect)
            context.cgContext.strokePath()
            
            // Draw certificate content
            drawCenteredText("СЕРТИФИКАТ", at: CGPoint(x: pageRect.midX, y: 100), fontSize: 48, weight: .bold)
            drawCenteredText("подтверждает, что", at: CGPoint(x: pageRect.midX, y: 180), fontSize: 18)
            drawCenteredText("\(user.firstName) \(user.lastName)", at: CGPoint(x: pageRect.midX, y: 240), fontSize: 36, weight: .semibold)
            drawCenteredText("успешно завершил(а) курс", at: CGPoint(x: pageRect.midX, y: 300), fontSize: 18)
            drawCenteredText(certificate.courseName, at: CGPoint(x: pageRect.midX, y: 360), fontSize: 28, weight: .medium)
            
            // Draw date and verification
            drawCenteredText("Дата выдачи: \(formatDate(certificate.issuedAt))", at: CGPoint(x: pageRect.midX, y: 450), fontSize: 14)
            drawCenteredText("Код верификации: \(certificate.verificationCode)", at: CGPoint(x: pageRect.midX, y: 480), fontSize: 12, color: .gray)
        }
        
        return data
    }
    
    private func generateOnboardingReportPDF(_ program: OnboardingProgram) throws -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842) // A4 size
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            // Draw header
            drawHeader("Отчет по онбордингу", in: context, at: CGPoint(x: 50, y: 50))
            
            // Draw program info
            var yPosition: CGFloat = 120
            drawText("Программа: \(program.template.name)", at: CGPoint(x: 50, y: yPosition), fontSize: 16, weight: .semibold)
            yPosition += 30
            drawText("Сотрудник: \(program.assigneeName)", at: CGPoint(x: 50, y: yPosition), fontSize: 14)
            yPosition += 25
            drawText("Прогресс: \(Int(program.overallProgress * 100))%", at: CGPoint(x: 50, y: yPosition), fontSize: 14)
            yPosition += 25
            drawText("Статус: \(program.status.rawValue)", at: CGPoint(x: 50, y: yPosition), fontSize: 14)
            yPosition += 40
            
            // Draw stages
            drawSectionHeader("Этапы программы", at: CGPoint(x: 50, y: yPosition))
            yPosition += 35
            
            for stage in program.stages {
                if yPosition > 700 {
                    context.beginPage()
                    yPosition = 50
                }
                
                let progressText = "\(Int(stage.calculateProgress() * 100))%"
                drawText("• \(stage.name) - \(progressText)", at: CGPoint(x: 70, y: yPosition), fontSize: 12)
                yPosition += 20
                
                // Draw tasks summary
                let completedTasks = stage.tasks.filter { $0.isCompleted }.count
                let totalTasks = stage.tasks.count
                drawText("  Задачи: \(completedTasks)/\(totalTasks) выполнено", at: CGPoint(x: 90, y: yPosition), fontSize: 11, color: .gray)
                yPosition += 25
            }
            
            // Draw footer
            drawFooter(in: context, pageNumber: 1)
        }
        
        return data
    }
    
    // MARK: - Drawing Helpers
    
    private func drawHeader(_ text: String, in context: UIGraphicsPDFRendererContext, at point: CGPoint) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor.black
        ]
        text.draw(at: point, withAttributes: attributes)
    }
    
    private func drawSectionHeader(_ text: String, at point: CGPoint) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
            .foregroundColor: UIColor.darkGray
        ]
        text.draw(at: point, withAttributes: attributes)
    }
    
    private func drawText(_ text: String, at point: CGPoint, fontSize: CGFloat, weight: UIFont.Weight = .regular, color: UIColor = .black) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: weight),
            .foregroundColor: color
        ]
        text.draw(at: point, withAttributes: attributes)
    }
    
    private func drawCenteredText(_ text: String, at point: CGPoint, fontSize: CGFloat, weight: UIFont.Weight = .regular, color: UIColor = .black) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: weight),
            .foregroundColor: color
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let drawPoint = CGPoint(x: point.x - textSize.width / 2, y: point.y)
        text.draw(at: drawPoint, withAttributes: attributes)
    }
    
    private func drawMultilineText(_ text: String, at point: CGPoint, width: CGFloat, fontSize: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle
        ]
        
        let textRect = CGRect(x: point.x, y: point.y, width: width, height: 200)
        text.draw(in: textRect, withAttributes: attributes)
    }
    
    private func drawFooter(in context: UIGraphicsPDFRendererContext, pageNumber: Int) {
        let footerText = "Страница \(pageNumber) | Создано в LMS App | \(formatDate(Date()))"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.gray
        ]
        
        let textSize = footerText.size(withAttributes: attributes)
        let point = CGPoint(x: (595 - textSize.width) / 2, y: 800)
        footerText.draw(at: point, withAttributes: attributes)
    }
    
    // MARK: - File Management
    
    private func savePDFToFile(_ data: Data, fileName: String) throws -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        try data.write(to: fileURL)
        return fileURL
    }
    
    // MARK: - Helpers
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

// MARK: - Export Error
enum PDFExportError: LocalizedError {
    case generationFailed
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .generationFailed:
            return "Не удалось создать PDF"
        case .saveFailed:
            return "Не удалось сохранить файл"
        }
    }
} 