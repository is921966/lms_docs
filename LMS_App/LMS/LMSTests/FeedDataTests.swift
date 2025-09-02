//
//  FeedDataTests.swift
//  LMSTests
//
//  Test feed data loading
//

import XCTest
@testable import LMS

@MainActor
final class FeedDataTests: XCTestCase {
    
    func testMockFeedServiceLoadsChannels() async throws {
        // Given
        let feedService = MockFeedService.shared
        
        // When - service initializes and loads data
        // Wait a bit for async initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        // Then
        print("\n🔍 FEED SERVICE DATA:")
        print("Total channels: \(feedService.channels.count)")
        print("Total posts: \(feedService.posts.count)")
        print("Channel posts dictionary keys: \(feedService.channelPosts.keys.sorted())")
        
        // Check each channel
        for channel in feedService.channels {
            let posts = feedService.channelPosts[channel.id] ?? []
            print("\n📁 Channel: \(channel.name) (id: \(channel.id))")
            print("   Type: \(channel.type)")
            print("   Posts count: \(posts.count)")
            print("   Unread: \(channel.unreadCount)")
            
            if posts.isEmpty {
                print("   ⚠️ WARNING: No posts in channel!")
            } else {
                print("   First post: \(posts.first?.content.prefix(50) ?? "")...")
            }
        }
        
        // Assertions
        XCTAssertGreaterThan(feedService.channels.count, 0, "Should have channels")
        XCTAssertGreaterThan(feedService.posts.count, 0, "Should have posts")
        
        // Check specific channels
        let releasesChannel = feedService.channels.first { $0.type == .releases }
        XCTAssertNotNil(releasesChannel, "Should have releases channel")
        
        if let releasesChannel = releasesChannel {
            let releasesPosts = feedService.channelPosts[releasesChannel.id] ?? []
            print("\n🚀 RELEASES CHANNEL DETAILS:")
            print("Channel ID: \(releasesChannel.id)")
            print("Posts in channel: \(releasesPosts.count)")
            XCTAssertGreaterThan(releasesPosts.count, 0, "Releases channel should have posts")
        }
    }
    
    func testRealDataFeedServiceLoadsReleases() async throws {
        // Test RealDataFeedService directly
        let realDataService = RealDataFeedService.shared
        
        print("\n📂 TESTING RealDataFeedService:")
        
        // Load release notes
        let releaseNotes = await realDataService.loadReleaseNotes()
        print("Release notes loaded: \(releaseNotes.count)")
        
        for (index, post) in releaseNotes.prefix(3).enumerated() {
            print("\nRelease \(index + 1):")
            print("  ID: \(post.id)")
            print("  Content: \(post.content.prefix(100))...")
            print("  Created: \(post.createdAt)")
        }
        
        XCTAssertGreaterThan(releaseNotes.count, 0, "Should load release notes")
        
        // Load all channel posts
        let allChannelPosts = await realDataService.loadAllChannelPosts()
        print("\n📊 All channels summary:")
        for (channelType, posts) in allChannelPosts {
            print("  \(channelType.rawValue): \(posts.count) posts")
        }
        
        // Check releases channel specifically
        let releasesInChannels = allChannelPosts[.releases] ?? []
        XCTAssertEqual(releasesInChannels.count, releaseNotes.count, 
                      "Releases in channels should match direct load")
    }
    
    func testChannelPostsMapping() async throws {
        // Test the channel ID to posts mapping
        let feedService = MockFeedService.shared
        
        // Wait for initialization
        try await Task.sleep(nanoseconds: 100_000_000)
        
        print("\n🗺️ CHANNEL ID MAPPING TEST:")
        
        // Expected channel IDs based on our fix
        let expectedChannelIds = [
            "channel-releases",
            "channel-sprints", 
            "channel-methodology",
            "channel-courses",
            "channel-admin",
            "channel-hr",
            "channel-my_courses",
            "channel-user_posts"
        ]
        
        for channelId in expectedChannelIds {
            let posts = feedService.channelPosts[channelId] ?? []
            print("Channel \(channelId): \(posts.count) posts")
            
            // Find corresponding channel object
            let channel = feedService.channels.first { $0.id == channelId }
            if let channel = channel {
                print("  ✅ Channel object found: \(channel.name)")
            } else {
                print("  ❌ No channel object with this ID!")
            }
        }
        
        // Critical assertion - channel IDs must match
        for channel in feedService.channels {
            let posts = feedService.channelPosts[channel.id]
            XCTAssertNotNil(posts, "Channel \(channel.id) should have posts entry")
        }
    }
} 