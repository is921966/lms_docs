//
//  AnalyticsDashboardView.swift
//  LMS
//
//  Created on Sprint 42 Day 3 - Analytics Dashboard
//

import SwiftUI

struct AnalyticsDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Аналитика Cmi5")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Здесь будет отображаться статистика по использованию Cmi5 контента")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Mock stats
            VStack(spacing: 16) {
                StatRow(title: "Всего сессий:", value: "1,234")
                StatRow(title: "Уникальных пользователей:", value: "456")
                StatRow(title: "Средний прогресс:", value: "78%")
                StatRow(title: "Среднее время:", value: "45 мин")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Аналитика")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Закрыть") {
                    dismiss()
                }
            }
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    NavigationView {
        AnalyticsDashboardView()
    }
} 