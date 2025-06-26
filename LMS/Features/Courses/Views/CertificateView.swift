//
//  CertificateView.swift
//  LMS
//
//  Created on 19/01/2025.
//

import SwiftUI

struct CertificateView: View {
    let certificateId: String
    @State private var showShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Certificate preview
                ZStack {
                    // Certificate background
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(
                            colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(height: 500)
                        .shadow(radius: 10)
                    
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 10) {
                            Image(systemName: "seal.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                            
                            Text("СЕРТИФИКАТ")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("об успешном завершении курса")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.5))
                            .padding(.horizontal, 40)
                        
                        // Certificate details
                        VStack(spacing: 15) {
                            Text("Настоящим удостоверяется, что")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("Иван Иванов")
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text("успешно завершил курс")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("iOS разработка с Swift")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            HStack(spacing: 30) {
                                VStack {
                                    Text("Дата выдачи")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                    Text("14 января 2025")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                }
                                
                                VStack {
                                    Text("Результат")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                    Text("92%")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.top)
                        }
                        
                        Spacer()
                        
                        // Certificate ID
                        Text("ID: \(certificateId)")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(30)
                }
                .padding()
                
                // Action buttons
                VStack(spacing: 15) {
                    Button(action: { showShareSheet = true }) {
                        Label("Поделиться", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: downloadCertificate) {
                        Label("Скачать PDF", systemImage: "arrow.down.doc")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: verifyCertificate) {
                        Label("Проверить подлинность", systemImage: "checkmark.shield")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Сертификат")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: ["Посмотрите мой сертификат! ID: \(certificateId)"])
        }
    }
    
    private func downloadCertificate() {
        // Placeholder for download functionality
        print("Downloading certificate...")
    }
    
    private func verifyCertificate() {
        // Placeholder for verification
        print("Verifying certificate...")
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 