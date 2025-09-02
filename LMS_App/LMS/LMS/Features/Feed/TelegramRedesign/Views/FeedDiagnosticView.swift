//
//  FeedDiagnosticView.swift
//  LMS
//
//  Diagnostic view for debugging Feed issues
//

import SwiftUI

struct FeedDiagnosticView: View {
    @StateObject private var feedService = MockFeedService.shared
    @State private var refreshCount = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Text("Feed Diagnostics")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button("Refresh") {
                        feedService.refresh()
                        refreshCount += 1
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                // Summary
                GroupBox("Summary") {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("\(feedService.channels.count) channels", systemImage: "folder")
                        Label("\(feedService.posts.count) total posts", systemImage: "doc.text")
                        Label("\(feedService.channelPosts.count) channel mappings", systemImage: "link")
                        Label("Refresh count: \(refreshCount)", systemImage: "arrow.clockwise")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Channel Posts Mapping
                GroupBox("Channel → Posts Mapping") {
                    if feedService.channelPosts.isEmpty {
                        Text("No channel posts mappings!")
                            .foregroundColor(.red)
                    } else {
                        ForEach(feedService.channelPosts.keys.sorted(), id: \.self) { key in
                            HStack {
                                Text(key)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Spacer()
                                Text("\(feedService.channelPosts[key]?.count ?? 0) posts")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                
                // Channels Detail
                GroupBox("Channels Detail") {
                    ForEach(feedService.channels) { channel in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "folder.fill")
                                    .foregroundColor(.blue)
                                Text(channel.name)
                                    .fontWeight(.semibold)
                            }
                            
                            Text("ID: \(channel.id)")
                                .font(.caption2)
                                .foregroundColor(.orange)
                            
                            Text("Type: \(channel.type.rawValue)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            
                            let postsCount = feedService.channelPosts[channel.id]?.count ?? 0
                            Text("Posts: \(postsCount)")
                                .font(.caption)
                                .foregroundColor(postsCount > 0 ? .green : .red)
                                .fontWeight(postsCount > 0 ? .regular : .bold)
                            
                            Divider()
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Raw Data
                GroupBox("Raw Channel IDs") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("From channels array:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        ForEach(feedService.channels.map { $0.id }, id: \.self) { id in
                            Text("• \(id)")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                        
                        Divider()
                        
                        Text("From channelPosts keys:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        ForEach(Array(feedService.channelPosts.keys).sorted(), id: \.self) { key in
                            Text("• \(key)")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            // Force a refresh on appear
            feedService.refresh()
        }
    }
}

#Preview {
    FeedDiagnosticView()
} 