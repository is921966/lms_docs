import SwiftUI

struct CareerPathView: View {
    let position: Position
    @StateObject private var viewModel = PositionViewModel()
    @State private var selectedPath: CareerPath?
    @State private var showingRequirements = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Current position card
                currentPositionCard
                
                // Outgoing paths
                outgoingPathsSection
                
                // Incoming paths
                incomingPathsSection
                
                // Career map visualization
                careerMapSection
            }
            .padding()
        }
        .navigationTitle("Карьерные пути")
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedPath) { path in
            NavigationStack {
                CareerPathDetailView(path: path, currentPosition: position)
            }
        }
    }
    
    // MARK: - Sections
    
    private var currentPositionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Текущая должность", systemImage: "person.crop.circle.fill")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(position.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 6) {
                            Image(systemName: position.level.icon)
                                .font(.caption)
                            Text(position.level.rawValue)
                                .font(.caption)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(position.level.color.opacity(0.2))
                        .foregroundColor(position.level.color)
                        .cornerRadius(12)
                        
                        Text(position.department)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(position.employeeCount)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("сотрудников")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [position.level.color.opacity(0.1), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(position.level.color.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(16)
    }
    
    private var outgoingPathsSection: some View {
        let paths = viewModel.getCareerPaths(for: position)
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(.green)
                Text("Возможности роста")
                    .font(.headline)
                Spacer()
                Text("\(paths.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(10)
            }
            
            if paths.isEmpty {
                emptyPathsState(isOutgoing: true)
            } else {
                ForEach(paths) { path in
                    CareerPathCard(path: path, isOutgoing: true)
                        .onTapGesture {
                            selectedPath = path
                        }
                }
            }
        }
    }
    
    private var incomingPathsSection: some View {
        let paths = viewModel.getIncomingCareerPaths(for: position)
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundColor(.blue)
                Text("Пути к этой должности")
                    .font(.headline)
                Spacer()
                Text("\(paths.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
            }
            
            if paths.isEmpty {
                emptyPathsState(isOutgoing: false)
            } else {
                ForEach(paths) { path in
                    CareerPathCard(path: path, isOutgoing: false)
                        .onTapGesture {
                            selectedPath = path
                        }
                }
            }
        }
    }
    
    private var careerMapSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Карта карьеры")
                .font(.headline)
            
            Text("Визуализация всех возможных карьерных путей")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Simple career tree visualization
            CareerTreeView(
                position: position,
                outgoingPaths: viewModel.getCareerPaths(for: position),
                incomingPaths: viewModel.getIncomingCareerPaths(for: position)
            )
            .frame(height: 300)
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
    }
    
    private func emptyPathsState(isOutgoing: Bool) -> some View {
        VStack(spacing: 12) {
            Image(systemName: isOutgoing ? "arrow.up.circle.dashed" : "arrow.down.circle.dashed")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text(isOutgoing ? "Карьерные пути не определены" : "Нет входящих путей")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(isOutgoing ? 
                "Для этой должности еще не определены возможности карьерного роста" :
                "Не определены пути, ведущие к этой должности"
            )
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Career Path Card

struct CareerPathCard: View {
    let path: CareerPath
    let isOutgoing: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isOutgoing ? "К должности:" : "Из должности:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(isOutgoing ? path.toPositionName : path.fromPositionName)
                        .font(.headline)
                }
                
                Spacer()
                
                // Success rate indicator
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(path.successRate * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(path.difficulty.color)
                    Text("успешность")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Metrics
            HStack(spacing: 16) {
                // Duration
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text(path.estimatedDuration.rawValue)
                        .font(.caption)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(.systemGray5))
                .cornerRadius(8)
                
                // Difficulty
                HStack(spacing: 6) {
                    Image(systemName: path.difficulty.icon)
                        .font(.caption)
                    Text(path.difficulty.rawValue)
                        .font(.caption)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(path.difficulty.color.opacity(0.1))
                .foregroundColor(path.difficulty.color)
                .cornerRadius(8)
                
                // Requirements count
                HStack(spacing: 6) {
                    Image(systemName: "checklist")
                        .font(.caption)
                    Text("\(path.requirements.count)")
                        .font(.caption)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(.systemGray5))
                .cornerRadius(8)
            }
            
            // Description
            if !path.description.isEmpty {
                Text(path.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Progress indicator
            HStack {
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.caption)
                    .foregroundColor(isOutgoing ? .green : .blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Career Tree View

struct CareerTreeView: View {
    let position: Position
    let outgoingPaths: [CareerPath]
    let incomingPaths: [CareerPath]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Center node - current position
                Circle()
                    .fill(position.level.color)
                    .frame(width: 80, height: 80)
                    .overlay(
                        VStack(spacing: 2) {
                            Image(systemName: position.level.icon)
                                .font(.title2)
                                .foregroundColor(.white)
                            Text(position.level.rawValue)
                                .font(.caption2)
                                .foregroundColor(.white)
                        }
                    )
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                // Outgoing paths (top)
                ForEach(Array(outgoingPaths.prefix(3).enumerated()), id: \.offset) { index, path in
                    let angle = Double(index - 1) * 30 - 90
                    let x = geometry.size.width / 2 + cos(angle * .pi / 180) * 100
                    let y = geometry.size.height / 2 + sin(angle * .pi / 180) * 100
                    
                    Path { path in
                        path.move(to: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2))
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    .stroke(Color.green, lineWidth: 2)
                    
                    Circle()
                        .fill(Color.green)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "arrow.up")
                                .font(.caption)
                                .foregroundColor(.white)
                        )
                        .position(x: x, y: y)
                }
                
                // Incoming paths (bottom)
                ForEach(Array(incomingPaths.prefix(3).enumerated()), id: \.offset) { index, path in
                    let angle = Double(index - 1) * 30 + 90
                    let x = geometry.size.width / 2 + cos(angle * .pi / 180) * 100
                    let y = geometry.size.height / 2 + sin(angle * .pi / 180) * 100
                    
                    Path { path in
                        path.move(to: CGPoint(x: x, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2))
                    }
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "arrow.down")
                                .font(.caption)
                                .foregroundColor(.white)
                        )
                        .position(x: x, y: y)
                }
            }
        }
    }
} 