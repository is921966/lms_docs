//
//  CertificateListView.swift
//  LMS
//
//  Created on 26/01/2025.
//

import SwiftUI

struct CertificateListView: View {
    @State private var certificates: [Certificate] = []
    @State private var searchText = ""
    @State private var selectedCertificate: Certificate?
    @State private var showingCertificate = false
    
    var filteredCertificates: [Certificate] {
        if searchText.isEmpty {
            return certificates
        }
        return certificates.filter { certificate in
            certificate.courseName.localizedCaseInsensitiveContains(searchText) ||
            certificate.certificateNumber.localizedCaseInsensitiveContains(searchText) ||
            certificate.verificationCode.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if certificates.isEmpty {
                    EmptyStateView(icon: "seal", title: "Нет сертификатов", subtitle: "Завершите курсы чтобы получить сертификаты")
                } else {
                    List {
                        // Statistics
                        CertificateStatsView(certificates: certificates)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Поиск сертификатов", text: $searchText)
                        }
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .listRowInsets(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                        .listRowSeparator(.hidden)
                        
                        // Certificates
                        ForEach(filteredCertificates) { certificate in
                            CertificateRowView(certificate: certificate)
                                .onTapGesture {
                                    selectedCertificate = certificate
                                    showingCertificate = true
                                }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Мои сертификаты")
            .onAppear {
                loadCertificates()
            }
            .sheet(isPresented: $showingCertificate) {
                if let certificate = selectedCertificate,
                   let template = CertificateTemplate.mockTemplates.first {
                    CertificateView(certificate: certificate, template: template)
                }
            }
        }
    }
    
    private func loadCertificates() {
        // Mock certificates
        certificates = [
            Certificate(
                userId: UUID(),
                courseId: UUID(),
                templateId: UUID(),
                certificateNumber: Certificate.generateCertificateNumber(),
                courseName: "Основы продаж в ЦУМ",
                courseDescription: "Базовый курс по техникам продаж",
                courseDuration: "8 часов",
                userName: "Иван Иванов",
                userEmail: "ivan@company.com",
                completedAt: Date().addingTimeInterval(-30*24*60*60),
                score: 92,
                totalScore: 100,
                percentage: 92,
                isPassed: true,
                issuedAt: Date().addingTimeInterval(-30*24*60*60),
                expiresAt: nil,
                verificationCode: Certificate.generateVerificationCode(),
                pdfUrl: nil
            ),
            Certificate(
                userId: UUID(),
                courseId: UUID(),
                templateId: UUID(),
                certificateNumber: Certificate.generateCertificateNumber(),
                courseName: "Клиентский сервис VIP",
                courseDescription: "Работа с премиальными клиентами",
                courseDuration: "12 часов",
                userName: "Иван Иванов",
                userEmail: "ivan@company.com",
                completedAt: Date().addingTimeInterval(-7*24*60*60),
                score: 88,
                totalScore: 100,
                percentage: 88,
                isPassed: true,
                issuedAt: Date().addingTimeInterval(-7*24*60*60),
                expiresAt: Date().addingTimeInterval(365*24*60*60),
                verificationCode: Certificate.generateVerificationCode(),
                pdfUrl: nil
            ),
            Certificate(
                userId: UUID(),
                courseId: UUID(),
                templateId: UUID(),
                certificateNumber: Certificate.generateCertificateNumber(),
                courseName: "Товароведение",
                courseDescription: "Знание ассортимента",
                courseDuration: "16 часов",
                userName: "Иван Иванов",
                userEmail: "ivan@company.com",
                completedAt: Date().addingTimeInterval(-60*24*60*60),
                score: 95,
                totalScore: 100,
                percentage: 95,
                isPassed: true,
                issuedAt: Date().addingTimeInterval(-60*24*60*60),
                expiresAt: nil,
                verificationCode: Certificate.generateVerificationCode(),
                pdfUrl: nil
            )
        ]
    }
}

// MARK: - Certificate Stats View
struct CertificateStatsView: View {
    let certificates: [Certificate]
    
    var activeCertificates: Int {
        certificates.filter { $0.isValid }.count
    }
    
    var averageScore: Double {
        guard !certificates.isEmpty else { return 0 }
        let totalScore = certificates.reduce(0) { $0 + $1.percentage }
        return totalScore / Double(certificates.count)
    }
    
    var body: some View {
        HStack(spacing: 20) {
            CertificateStatCard(
                title: "Всего",
                value: "\(certificates.count)",
                icon: "doc.text.fill",
                color: .blue
            )
            
            CertificateStatCard(
                title: "Активных",
                value: "\(activeCertificates)",
                icon: "checkmark.seal.fill",
                color: .green
            )
            
            CertificateStatCard(
                title: "Средний балл",
                value: String(format: "%.0f%%", averageScore),
                icon: "percent",
                color: .orange
            )
        }
        .padding()
    }
}

// MARK: - Certificate Stat Card
struct CertificateStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Certificate Row View
struct CertificateRowView: View {
    let certificate: Certificate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Certificate icon
                ZStack {
                    Circle()
                        .fill(certificate.isValid ? Color.green : Color.orange)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: certificate.isValid ? "seal.fill" : "seal")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(certificate.courseName)
                        .font(.headline)
                    
                    Text(certificate.formattedCertificateNumber)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Label("\(Int(certificate.percentage))%", systemImage: "percent")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        if let expiresAt = certificate.expiresAt {
                            Label(formatExpiryDate(expiresAt), systemImage: "clock")
                                .font(.caption)
                                .foregroundColor(Date() > expiresAt ? .red : .secondary)
                        }
                    }
                }
                
                Spacer()
                
                VStack {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if certificate.isValid {
                        Text("Действителен")
                            .font(.caption2)
                            .foregroundColor(.green)
                    } else {
                        Text("Истёк")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private func formatExpiryDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Empty State View
private struct CertificateEmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("Нет сертификатов")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Завершите курсы с проходным баллом,\nчтобы получить сертификаты")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            NavigationLink(destination: LearningListView()) {
                Text("Перейти к курсам")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

#Preview {
    CertificateListView()
} 