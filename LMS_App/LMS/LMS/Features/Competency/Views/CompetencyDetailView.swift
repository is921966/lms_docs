import SwiftUI

struct CompetencyDetailView: View {
    let competency: Competency
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingEditSheet = false
    @State private var selectedLevel: CompetencyLevel?
    @StateObject private var viewModel = CompetencyViewModel()
    
    var isAdmin: Bool {
        authViewModel.currentUser?.role == .admin || 
        authViewModel.currentUser?.role == .superAdmin
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with color
                headerSection
                
                // Description
                descriptionSection
                
                // Levels
                levelsSection
                
                // Related positions
                if !competency.relatedPositions.isEmpty {
                    relatedPositionsSection
                }
                
                // Metadata
                metadataSection
            }
            .padding()
        }
        .navigationTitle(competency.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isAdmin {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Редактировать") {
                        showingEditSheet = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                CompetencyEditView(competency: competency) { updatedCompetency in
                    viewModel.updateCompetency(updatedCompetency)
                }
            }
        }
        .sheet(item: $selectedLevel) { level in
            levelDetailSheet(level)
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Color bar
            RoundedRectangle(cornerRadius: 8)
                .fill(competency.swiftUIColor)
                .frame(height: 6)
            
            HStack {
                // Category badge
                HStack(spacing: 6) {
                    Image(systemName: competency.category.icon)
                    Text(competency.category.rawValue)
                }
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.systemGray5))
                .cornerRadius(20)
                
                Spacer()
                
                // Status badge
                if !competency.isActive {
                    Text("Неактивна")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(20)
                }
            }
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Описание")
                .font(.headline)
            
            Text(competency.description.isEmpty ? "Описание не указано" : competency.description)
                .font(.body)
                .foregroundColor(competency.description.isEmpty ? .secondary : .primary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var levelsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Уровни компетенции")
                .font(.headline)
            
            ForEach(competency.levels) { level in
                LevelCard(level: level, color: competency.swiftUIColor)
                    .onTapGesture {
                        selectedLevel = level
                    }
            }
        }
    }
    
    private var relatedPositionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Связанные должности")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(competency.relatedPositions, id: \.self) { position in
                        HStack(spacing: 6) {
                            Image(systemName: "person.fill")
                            Text(position)
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                        .cornerRadius(20)
                    }
                }
            }
        }
    }
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Информация")
                .font(.headline)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Цвет категории:")
                        .foregroundColor(.secondary)
                    Spacer()
                    HStack(spacing: 6) {
                        Circle()
                            .fill(competency.swiftUIColor)
                            .frame(width: 16, height: 16)
                        Text(competency.color.name)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Дата создания:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(competency.createdAt.formatted(date: .abbreviated, time: .omitted))
                }
                
                Divider()
                
                HStack {
                    Text("Последнее обновление:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(competency.updatedAt.formatted(date: .abbreviated, time: .omitted))
                }
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Level Detail Sheet
    
    private func levelDetailSheet(_ level: CompetencyLevel) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Progress indicator
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Уровень \(level.level) из \(competency.maxLevel)")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(Int(level.progressPercentage))%")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        ProgressView(value: level.progressPercentage / 100)
                            .tint(Color(hex: level.progressColor))
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Описание")
                            .font(.headline)
                        
                        Text(level.description)
                            .font(.body)
                    }
                    
                    // Behaviors
                    if !level.behaviors.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Ключевые индикаторы")
                                .font(.headline)
                            
                            ForEach(level.behaviors, id: \.self) { behavior in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                    
                                    Text(behavior)
                                        .font(.subheadline)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(level.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        selectedLevel = nil
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct LevelCard: View {
    let level: CompetencyLevel
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Level number
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Text("\(level.level)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(level.name)
                    .font(.headline)
                
                Text(level.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Preview
struct CompetencyDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CompetencyDetailView(
                competency: Competency(
                    name: "iOS разработка",
                    description: "Разработка мобильных приложений для платформы iOS",
                    category: .technical,
                    color: .blue,
                    relatedPositions: ["iOS Developer", "Mobile Lead"]
                )
            )
            .environmentObject(AuthViewModel())
        }
    }
} 