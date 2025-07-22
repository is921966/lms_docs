import SwiftUI

struct MethodologyDetailView: View {
    let versions: [MethodologyVersion]
    let onBack: () -> Void
    
    @State private var expandedVersions: Set<UUID> = []
    
    var body: some View {
        ZStack {
            Color("TelegramBackground", bundle: nil)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("📚 Методология TDD")
                        .font(.headline)
                    
                    Spacer()
                    
                    // Placeholder for balance
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .opacity(0)
                }
                .padding()
                .background(Color("TelegramHeaderBackground", bundle: nil))
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(versions) { version in
                            MethodologyVersionCard(
                                version: version,
                                isExpanded: expandedVersions.contains(version.id),
                                onToggle: {
                                    withAnimation {
                                        if expandedVersions.contains(version.id) {
                                            expandedVersions.remove(version.id)
                                        } else {
                                            expandedVersions.insert(version.id)
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct MethodologyVersionCard: View {
    let version: MethodologyVersion
    let isExpanded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(version.version)
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        if version.version == "v2.0.0" {
                            Text("CURRENT")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(version.title)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(version.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if isExpanded {
                Divider()
                
                // Breaking Changes
                if !version.breakingChanges.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("🚨 Критические изменения")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                        
                        ForEach(version.breakingChanges, id: \.self) { change in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundColor(.red)
                                Text(change)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }
                
                // Improvements
                if !version.improvements.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("✨ Улучшения")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                        
                        ForEach(version.improvements, id: \.self) { improvement in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundColor(.green)
                                Text(improvement)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }
                
                // Changes
                if !version.changes.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("📝 Изменения")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        ForEach(version.changes, id: \.self) { change in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundColor(.blue)
                                Text(change)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color("TelegramCardBackground", bundle: nil))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .onTapGesture {
            onToggle()
        }
    }
} 