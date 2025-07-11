//
//  FeedAttachmentTests.swift
//  LMSTests
//
//  Created by LMS Team on 13.01.2025.
//

import XCTest
@testable import LMS

final class FeedAttachmentTests: XCTestCase {
    
    // MARK: - Creation Tests
    
    func testDocumentAttachmentCreation() {
        let attachment = FeedAttachment(
            id: "doc-1",
            type: .document,
            url: "https://example.com/document.pdf",
            name: "Important Document.pdf",
            size: 1024 * 1024 * 2, // 2MB
            thumbnailUrl: nil
        )
        
        XCTAssertEqual(attachment.id, "doc-1")
        XCTAssertEqual(attachment.type, .document)
        XCTAssertEqual(attachment.url, "https://example.com/document.pdf")
        XCTAssertEqual(attachment.name, "Important Document.pdf")
        XCTAssertEqual(attachment.size, 2097152)
        XCTAssertNil(attachment.thumbnailUrl)
    }
    
    func testVideoAttachmentCreation() {
        let attachment = FeedAttachment(
            id: "video-1",
            type: .video,
            url: "https://example.com/video.mp4",
            name: "Training Video.mp4",
            size: 1024 * 1024 * 50, // 50MB
            thumbnailUrl: "https://example.com/video_thumb.jpg"
        )
        
        XCTAssertEqual(attachment.type, .video)
        XCTAssertNotNil(attachment.thumbnailUrl)
        XCTAssertEqual(attachment.thumbnailUrl, "https://example.com/video_thumb.jpg")
    }
    
    func testLinkAttachmentCreation() {
        let attachment = FeedAttachment(
            id: "link-1",
            type: .link,
            url: "https://example.com/article",
            name: "Interesting Article",
            size: nil, // Links don't have size
            thumbnailUrl: "https://example.com/preview.jpg"
        )
        
        XCTAssertEqual(attachment.type, .link)
        XCTAssertNil(attachment.size)
        XCTAssertNotNil(attachment.thumbnailUrl)
    }
    
    func testCourseAttachmentCreation() {
        let attachment = FeedAttachment(
            id: "course-1",
            type: .course,
            url: "course-uuid-12345",
            name: "Advanced Swift Programming",
            size: nil,
            thumbnailUrl: nil
        )
        
        XCTAssertEqual(attachment.type, .course)
        XCTAssertEqual(attachment.url, "course-uuid-12345")
    }
    
    func testTestAttachmentCreation() {
        let attachment = FeedAttachment(
            id: "test-1",
            type: .test,
            url: "test-uuid-67890",
            name: "Final Exam",
            size: nil,
            thumbnailUrl: nil
        )
        
        XCTAssertEqual(attachment.type, .test)
        XCTAssertEqual(attachment.name, "Final Exam")
    }
    
    // MARK: - AttachmentType Tests
    
    func testAllAttachmentTypes() {
        let types: [FeedAttachment.AttachmentType] = [.document, .video, .link, .course, .test]
        
        for type in types {
            let attachment = FeedAttachment(
                id: "\(type)-id",
                type: type,
                url: "url",
                name: "Name",
                size: type == .document || type == .video ? 1024 : nil,
                thumbnailUrl: nil
            )
            
            XCTAssertEqual(attachment.type, type)
        }
    }
    
    func testAttachmentTypeRawValues() {
        XCTAssertEqual(FeedAttachment.AttachmentType.document.rawValue, "document")
        XCTAssertEqual(FeedAttachment.AttachmentType.video.rawValue, "video")
        XCTAssertEqual(FeedAttachment.AttachmentType.link.rawValue, "link")
        XCTAssertEqual(FeedAttachment.AttachmentType.course.rawValue, "course")
        XCTAssertEqual(FeedAttachment.AttachmentType.test.rawValue, "test")
    }
    
    // MARK: - Size Tests
    
    func testVariousFileSizes() {
        let sizes: [(Int64, String)] = [
            (1024, "1KB"),
            (1024 * 1024, "1MB"),
            (1024 * 1024 * 10, "10MB"),
            (1024 * 1024 * 1024, "1GB")
        ]
        
        for (size, description) in sizes {
            let attachment = FeedAttachment(
                id: "size-test",
                type: .document,
                url: "file.pdf",
                name: "\(description) File",
                size: size,
                thumbnailUrl: nil
            )
            
            XCTAssertEqual(attachment.size, size)
        }
    }
    
    func testZeroSize() {
        let attachment = FeedAttachment(
            id: "1",
            type: .document,
            url: "empty.txt",
            name: "Empty File",
            size: 0,
            thumbnailUrl: nil
        )
        
        XCTAssertEqual(attachment.size, 0)
    }
    
    func testNilSize() {
        let attachment = FeedAttachment(
            id: "1",
            type: .link,
            url: "https://example.com",
            name: "Link",
            size: nil,
            thumbnailUrl: nil
        )
        
        XCTAssertNil(attachment.size)
    }
    
    // MARK: - URL Tests
    
    func testVariousURLFormats() {
        let urls = [
            "https://example.com/file.pdf",
            "http://example.com/file.pdf",
            "file:///local/path/file.pdf",
            "/relative/path/file.pdf",
            "course-uuid-12345",
            "test-uuid-67890"
        ]
        
        for url in urls {
            let attachment = FeedAttachment(
                id: "1",
                type: .document,
                url: url,
                name: "File",
                size: nil,
                thumbnailUrl: nil
            )
            
            XCTAssertEqual(attachment.url, url)
        }
    }
    
    func testSpecialCharactersInURL() {
        let url = "https://example.com/files/документ%20с%20пробелами.pdf"
        let attachment = FeedAttachment(
            id: "1",
            type: .document,
            url: url,
            name: "Документ с пробелами.pdf",
            size: nil,
            thumbnailUrl: nil
        )
        
        XCTAssertEqual(attachment.url, url)
    }
    
    // MARK: - Name Tests
    
    func testVariousFileNames() {
        let names = [
            "document.pdf",
            "My Document.pdf",
            "документ.pdf",
            "文档.pdf",
            "file-with-dashes.pdf",
            "file_with_underscores.pdf",
            "file.with.dots.pdf",
            "UPPERCASE.PDF"
        ]
        
        for name in names {
            let attachment = FeedAttachment(
                id: "1",
                type: .document,
                url: "url",
                name: name,
                size: nil,
                thumbnailUrl: nil
            )
            
            XCTAssertEqual(attachment.name, name)
        }
    }
    
    func testLongFileName() {
        let longName = String(repeating: "very_long_filename_", count: 20) + ".pdf"
        let attachment = FeedAttachment(
            id: "1",
            type: .document,
            url: "url",
            name: longName,
            size: nil,
            thumbnailUrl: nil
        )
        
        XCTAssertEqual(attachment.name, longName)
        XCTAssertGreaterThan(attachment.name.count, 300)
    }
    
    // MARK: - Thumbnail Tests
    
    func testThumbnailURL() {
        let thumbnailUrl = "https://example.com/thumbnails/video_thumb.jpg"
        let attachment = FeedAttachment(
            id: "1",
            type: .video,
            url: "video.mp4",
            name: "Video",
            size: nil,
            thumbnailUrl: thumbnailUrl
        )
        
        XCTAssertEqual(attachment.thumbnailUrl, thumbnailUrl)
    }
    
    func testNilThumbnail() {
        let attachment = FeedAttachment(
            id: "1",
            type: .document,
            url: "doc.pdf",
            name: "Document",
            size: nil,
            thumbnailUrl: nil
        )
        
        XCTAssertNil(attachment.thumbnailUrl)
    }
    
    // MARK: - Codable Tests
    
    func testAttachmentEncoding() throws {
        let attachment = FeedAttachment(
            id: "1",
            type: .document,
            url: "https://example.com/doc.pdf",
            name: "Document.pdf",
            size: 1024,
            thumbnailUrl: "https://example.com/thumb.jpg"
        )
        
        let encoder = JSONEncoder()
        XCTAssertNoThrow(try encoder.encode(attachment))
        
        let data = try encoder.encode(attachment)
        XCTAssertGreaterThan(data.count, 0)
    }
    
    func testAttachmentDecoding() throws {
        let attachment = FeedAttachment(
            id: "1",
            type: .video,
            url: "video.mp4",
            name: "Video.mp4",
            size: 1048576,
            thumbnailUrl: "thumb.jpg"
        )
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(attachment)
        let decodedAttachment = try decoder.decode(FeedAttachment.self, from: data)
        
        XCTAssertEqual(decodedAttachment.id, attachment.id)
        XCTAssertEqual(decodedAttachment.type, attachment.type)
        XCTAssertEqual(decodedAttachment.url, attachment.url)
        XCTAssertEqual(decodedAttachment.name, attachment.name)
        XCTAssertEqual(decodedAttachment.size, attachment.size)
        XCTAssertEqual(decodedAttachment.thumbnailUrl, attachment.thumbnailUrl)
    }
    
    func testAttachmentWithNilFieldsEncoding() throws {
        let attachment = FeedAttachment(
            id: "1",
            type: .link,
            url: "https://example.com",
            name: "Link",
            size: nil,
            thumbnailUrl: nil
        )
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(attachment)
        let decodedAttachment = try decoder.decode(FeedAttachment.self, from: data)
        
        XCTAssertNil(decodedAttachment.size)
        XCTAssertNil(decodedAttachment.thumbnailUrl)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyName() {
        let attachment = FeedAttachment(
            id: "1",
            type: .document,
            url: "file.pdf",
            name: "", // Empty name
            size: nil,
            thumbnailUrl: nil
        )
        
        XCTAssertEqual(attachment.name, "")
    }
    
    func testEmptyURL() {
        let attachment = FeedAttachment(
            id: "1",
            type: .document,
            url: "", // Empty URL
            name: "File",
            size: nil,
            thumbnailUrl: nil
        )
        
        XCTAssertEqual(attachment.url, "")
    }
    
    // MARK: - Performance Tests
    
    func testManyAttachmentsPerformance() {
        measure {
            var attachments: [FeedAttachment] = []
            
            for i in 0..<1000 {
                attachments.append(FeedAttachment(
                    id: "attach-\(i)",
                    type: i % 2 == 0 ? .document : .video,
                    url: "file\(i).pdf",
                    name: "File \(i)",
                    size: Int64(i * 1024),
                    thumbnailUrl: i % 3 == 0 ? "thumb\(i).jpg" : nil
                ))
            }
            
            XCTAssertEqual(attachments.count, 1000)
            _ = attachments.filter { $0.type == .document }.count
            _ = attachments.compactMap { $0.thumbnailUrl }.count
        }
    }
} 