import SwiftUI

struct ReleaseNotesDetailView: View {
    let releaseNotes: [ReleaseNote]
    let onBack: () -> Void
    
    @State private var selectedRelease: ReleaseNote?
    
    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .medium))
                            Text("Назад")
                                .font(.system(size: 17))
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("🚀 Релизы LMS")
                            .font(.system(size: 17, weight: .semibold))
                        Text("\(releaseNotes.count) версий")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Button(action: {}) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 20))
                    }
                    .opacity(0)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                
                // Release Notes List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(releaseNotes) { release in
                            ReleaseNoteCard(release: release)
                                .onTapGesture {
                                    selectedRelease = release
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(item: $selectedRelease) { release in
            ReleaseDetailSheet(release: release)
        }
    }
}

struct ReleaseNoteCard: View {
    let release: ReleaseNote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(release.title)
                        .font(.system(size: 17, weight: .semibold))
                    
                    if let version = release.version, let build = release.buildNumber {
                        Text("Версия \(version) (Build \(build))")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Text(release.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            // Summary
            Text(release.content.replacingOccurrences(of: "**", with: ""))
                .font(.system(size: 15))
                .lineLimit(3)
                .foregroundColor(.primary.opacity(0.9))
            
            // Feature tags
            if !release.features.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(release.features.prefix(3), id: \.self) { feature in
                            Text(feature)
                                .font(.system(size: 12))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(14)
                                .lineLimit(1)
                        }
                        
                        if release.features.count > 3 {
                            Text("+\(release.features.count - 3)")
                                .font(.system(size: 12))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.gray.opacity(0.1))
                                .foregroundColor(.gray)
                                .cornerRadius(14)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8)
    }
}

struct ReleaseDetailSheet: View {
    let release: ReleaseNote
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Version info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(release.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        if let version = release.version, let build = release.buildNumber {
                            Text("Версия \(version) (Build \(build))")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(release.date.formatted(date: .long, time: .omitted))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Content
                    Text(release.content.replacingOccurrences(of: "**", with: ""))
                        .font(.body)
                    
                    if !release.features.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Новые функции", systemImage: "sparkles")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            ForEach(release.features, id: \.self) { feature in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 14))
                                    Text(feature)
                                        .font(.system(size: 15))
                                }
                            }
                        }
                    }
                    
                    if !release.fixes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Исправления", systemImage: "wrench.and.screwdriver")
                                .font(.headline)
                                .foregroundColor(.orange)
                            
                            ForEach(release.fixes, id: \.self) { fix in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "hammer.circle.fill")
                                        .foregroundColor(.orange)
                                        .font(.system(size: 14))
                                    Text(fix)
                                        .font(.system(size: 15))
                                }
                            }
                        }
                    }
                    
                    if !release.improvements.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Улучшения", systemImage: "arrow.up.circle")
                                .font(.headline)
                                .foregroundColor(.purple)
                            
                            ForEach(release.improvements, id: \.self) { improvement in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "star.circle.fill")
                                        .foregroundColor(.purple)
                                        .font(.system(size: 14))
                                    Text(improvement)
                                        .font(.system(size: 15))
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
} 