//
//  CertificateView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct CertificateView: View {
    let certificate: Certificate
    let template: CertificateTemplate
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var renderedImage: UIImage?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Certificate preview
                    CertificatePreview(certificate: certificate, template: template)
                        .frame(height: 600)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding()
                        .onAppear {
                            generateImage()
                        }

                    // Certificate info
                    VStack(alignment: .leading, spacing: 16) {
                        CertificateInfoRow(
                            icon: "number",
                            title: "Номер сертификата",
                            value: certificate.formattedCertificateNumber
                        )

                        CertificateInfoRow(
                            icon: "checkmark.shield",
                            title: "Код верификации",
                            value: certificate.verificationCode
                        )

                        CertificateInfoRow(
                            icon: "calendar",
                            title: "Дата выдачи",
                            value: formatDate(certificate.issuedAt)
                        )

                        if let expiresAt = certificate.expiresAt {
                            CertificateInfoRow(
                                icon: "clock.badge.exclamationmark",
                                title: "Действителен до",
                                value: formatDate(expiresAt)
                            )
                        }

                        CertificateInfoRow(
                            icon: "percent",
                            title: "Результат",
                            value: "\(Int(certificate.percentage))%"
                        )
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .padding(.horizontal)

                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: { showingShareSheet = true }) {
                            Label("Поделиться", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        Button(action: downloadPDF) {
                            Label("Скачать PDF", systemImage: "arrow.down.doc")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        Button(action: printCertificate) {
                            Label("Печать", systemImage: "printer")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Сертификат")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let image = renderedImage {
                    ShareSheet(items: [image, certificate.shareText])
                }
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }

    private func generateImage() {
        let renderer = ImageRenderer(content: CertificatePreview(certificate: certificate, template: template))
        renderer.scale = 3.0
        renderedImage = renderer.uiImage
    }

    private func downloadPDF() {
        // In real app, would generate and download PDF
        print("Downloading PDF...")
    }

    private func printCertificate() {
        // In real app, would print certificate
        print("Printing certificate...")
    }
}

// MARK: - Certificate Preview
struct CertificatePreview: View {
    let certificate: Certificate
    let template: CertificateTemplate

    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            template.primarySwiftUIColor.opacity(0.1),
                            template.secondarySwiftUIColor.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(template.primarySwiftUIColor, lineWidth: 3)
                )

            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "seal.fill")
                        .font(.system(size: 60))
                        .foregroundColor(template.primarySwiftUIColor)

                    Text(template.titleTemplate)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(template.primarySwiftUIColor)
                }

                // Body
                Text(formatBodyText())
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .foregroundColor(.primary)

                // Course details
                VStack(spacing: 8) {
                    Text(certificate.courseName)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(template.primarySwiftUIColor)

                    Text("Продолжительность: \(certificate.courseDuration)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Signature
                VStack(spacing: 20) {
                    Divider()
                        .frame(width: 200)

                    VStack(spacing: 4) {
                        Text(template.signerName)
                            .font(.headline)
                        Text(template.signerTitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(template.organizationName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Footer
                Text(formatFooterText())
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            }
            .padding(30)
        }
        .aspectRatio(0.7, contentMode: .fit)
    }

    private func formatBodyText() -> String {
        template.bodyTemplate
            .replacingOccurrences(of: "{userName}", with: certificate.userName)
            .replacingOccurrences(of: "{courseName}", with: certificate.courseName)
            .replacingOccurrences(of: "{score}", with: String(Int(certificate.percentage)))
    }

    private func formatFooterText() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ru_RU")
        let dateString = formatter.string(from: certificate.issuedAt)

        return template.footerTemplate
            .replacingOccurrences(of: "{date}", with: dateString)
    }
}

// MARK: - Certificate Info Row
struct CertificateInfoRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    CertificateView(
        certificate: Certificate(
            userId: UUID(),
            courseId: UUID(),
            templateId: UUID(),
            certificateNumber: Certificate.generateCertificateNumber(),
            courseName: "Основы продаж в ЦУМ",
            courseDescription: "Базовый курс по техникам продаж",
            courseDuration: "8 часов",
            userName: "Иван Иванов",
            userEmail: "ivan@company.com",
            completedAt: Date(),
            score: 85,
            totalScore: 100,
            percentage: 85,
            isPassed: true,
            issuedAt: Date(),
            expiresAt: nil,
            verificationCode: Certificate.generateVerificationCode(),
            pdfUrl: nil
        ),
        template: CertificateTemplate.mockTemplates[0]
    )
}
