import SwiftUI

struct MoreModulesView: View {
    @StateObject private var featureRegistry = FeatureRegistryManager.shared
    @State private var selectedModule: Feature?
    @State private var showingModule = false
    
    // Модули для отображения в "Ещё"
    let additionalModules: [Feature] = [
        .tests,
        .analytics,
        .onboarding,
        .competencies,
        .positions,
        .feed,
        .cmi5
    ]
    
    // Будущие модули
    let futureModules: [Feature] = [
        .certificates,
        .gamification,
        .notifications
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Заголовок
                VStack(alignment: .leading, spacing: 8) {
                    Text("Дополнительные модули")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Все доступные функции LMS")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top)
                
                // Активные модули
                VStack(alignment: .leading, spacing: 12) {
                    Text("Доступные модули")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(additionalModules.filter { $0.isEnabled }, id: \.self) { module in
                            FeatureCard(feature: module) {
                                selectedModule = module
                                showingModule = true
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Скоро будут доступны
                if !futureModules.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Скоро будут доступны")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(futureModules, id: \.self) { module in
                                FutureFeatureCard(feature: module)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Информация для тестировщиков
                TestingInfoSection()
                    .padding(.top)
            }
            .padding(.bottom)
        }
        .navigationTitle("Ещё")
        .navigationDestination(isPresented: $showingModule) {
            if let module = selectedModule {
                module.view
            }
        }
        // Обновляем при изменении feature flags
        .onReceive(featureRegistry.$lastUpdate) { _ in
            // Триггерим обновление UI
        }
    }
}

// MARK: - Feature Card
struct FeatureCard: View {
    let feature: Feature
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: feature.icon)
                    .font(.system(size: 36))
                    .foregroundColor(.blue)
                
                Text(feature.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                if feature == .cmi5 {
                    Text("НОВОЕ")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Future Feature Card
struct FutureFeatureCard: View {
    let feature: Feature
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: feature.icon)
                .font(.system(size: 36))
                .foregroundColor(.gray)
            
            Text(feature.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Text("Скоро")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .foregroundColor(.gray.opacity(0.3))
        )
    }
}

// MARK: - Testing Info Section
struct TestingInfoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("Информация для тестировщиков")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                MoreInfoRow(icon: "1.circle.fill", text: "Все модули включены автоматически в TestFlight")
                MoreInfoRow(icon: "2.circle.fill", text: "Нажмите на модуль для перехода")
                MoreInfoRow(icon: "3.circle.fill", text: "Используйте Shake для обратной связи")
                MoreInfoRow(icon: "4.circle.fill", text: "Debug режим: Настройки → 7 тапов по версии")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct MoreInfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        MoreModulesView()
    }
} 