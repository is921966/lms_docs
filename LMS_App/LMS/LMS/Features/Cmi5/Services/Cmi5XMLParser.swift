//
//  Cmi5XMLParser.swift
//  LMS
//
//  Created on Sprint 40 Day 2 - XML Parsing
//

import Foundation

/// XML парсер для Cmi5 манифестов
public final class Cmi5XMLParser: NSObject {
    
    // MARK: - Result Type
    
    public struct ParseResult {
        public let manifest: Cmi5Manifest
        public let activities: [Cmi5Activity]
        public let extendedCourse: Cmi5FullParser.Cmi5ExtendedCourse
    }
    
    // MARK: - Public Methods
    
    public func parseManifest(_ data: Data, baseURL: URL) throws -> ParseResult {
        let parser = XMLParser(data: data)
        let delegate = Cmi5XMLParserDelegate(baseURL: baseURL)
        parser.delegate = delegate
        
        guard parser.parse() else {
            let error = parser.parserError?.localizedDescription ?? "Unknown XML parsing error"
            throw Cmi5Parser.ParsingError.xmlParsingError(error)
        }
        
        guard let result = delegate.buildResult() else {
            throw Cmi5Parser.ParsingError.invalidManifest
        }
        
        return result
    }
}

// MARK: - XML Parser Delegate

private class Cmi5XMLParserDelegate: NSObject, XMLParserDelegate {
    
    // MARK: - Properties
    
    private let baseURL: URL
    private var currentElement = ""
    private var currentText = ""
    private var elementStack: [String] = []
    
    // Course structure
    private var courseId = ""
    private var courseTitle = ""
    private var courseDescription = ""
    
    // Manifest
    private var manifestId = ""
    private var manifestTitle = ""
    private var manifestDescription: String?
    private var manifestVersion: String?
    
    // Metadata
    private var metadata: [String: String] = [:]
    
    // Structure building
    private var nodeStack: [NodeBuilder] = []
    private var rootNodes: [Cmi5FullParser.Cmi5CourseNode] = []
    private var allActivities: [Cmi5Activity] = []
    
    // Current activity being parsed
    private var currentActivity: ActivityBuilder?
    
    // Current block being parsed
    private var currentBlock: BlockBuilder?
    
    // Objectives accumulator
    private var currentObjectives: [String] = []
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    // MARK: - Builder Types
    
    private class NodeBuilder {
        var children: [Cmi5FullParser.Cmi5CourseNode] = []
    }
    
    private class BlockBuilder: NodeBuilder {
        let id: String
        var title = ""
        var description: String?
        var objectives: [String] = []
        
        init(id: String) {
            self.id = id
        }
        
        func build() -> Cmi5FullParser.Cmi5Block {
            return Cmi5FullParser.Cmi5Block(
                id: id,
                title: title,
                description: description,
                objectives: objectives,
                children: children
            )
        }
    }
    
    private class ActivityBuilder {
        let id: String
        var title = ""
        var description: String?
        var url = ""
        var launchMethod = "AnyWindow"
        var moveOn = "CompletedOrPassed"
        var masteryScore: Double?
        var activityType = "http://adlnet.gov/expapi/activities/module"
        var duration: String?
        
        init(id: String) {
            self.id = id
        }
        
        func build() -> Cmi5Activity {
            return Cmi5Activity(
                id: UUID(),
                packageId: UUID(),
                activityId: id,
                title: title,
                description: description,
                launchUrl: url,
                launchMethod: parseLaunchMethod(launchMethod),
                moveOn: parseMoveOn(moveOn),
                masteryScore: masteryScore,
                activityType: activityType,
                duration: duration
            )
        }
        
        private func parseLaunchMethod(_ value: String) -> Cmi5Activity.LaunchMethod {
            switch value {
            case "OwnWindow":
                return .ownWindow
            default:
                return .anyWindow
            }
        }
        
        private func parseMoveOn(_ value: String) -> Cmi5Activity.MoveOnCriteria {
            switch value {
            case "Passed":
                return .passed
            case "Completed":
                return .completed
            case "CompletedAndPassed":
                return .completedAndPassed
            case "NotApplicable":
                return .notApplicable
            default:
                return .completedOrPassed
            }
        }
    }
    
    // MARK: - XMLParserDelegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        elementStack.append(elementName)
        currentElement = elementName
        currentText = ""
        
        switch elementName {
        case "courseStructure":
            manifestId = attributeDict["id"] ?? ""
            
        case "course":
            courseId = attributeDict["id"] ?? ""
            
        case "block":
            let blockId = attributeDict["id"] ?? UUID().uuidString
            let block = BlockBuilder(id: blockId)
            currentBlock = block
            nodeStack.append(block)
            
        case "au":
            let activityId = attributeDict["id"] ?? UUID().uuidString
            currentActivity = ActivityBuilder(id: activityId)
            
            // Parse attributes
            if let launchMethod = attributeDict["launchMethod"] {
                currentActivity?.launchMethod = launchMethod
            }
            if let moveOn = attributeDict["moveOn"] {
                currentActivity?.moveOn = moveOn
            }
            if let masteryScoreStr = attributeDict["masteryScore"],
               let masteryScore = Double(masteryScoreStr) {
                currentActivity?.masteryScore = masteryScore
            }
            
        case "objective":
            // Objectives are handled by their content
            break
            
        case "metadata":
            // Metadata section started
            break
            
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        elementStack.removeLast()
        
        switch elementName {
        case "title":
            handleTitle()
            
        case "description":
            handleDescription()
            
        case "url":
            currentActivity?.url = currentText
            
        case "activityType":
            currentActivity?.activityType = currentText
            
        case "duration":
            currentActivity?.duration = currentText
            
        case "objective":
            if !currentText.isEmpty {
                currentObjectives.append(currentText)
            }
            
        case "objectives":
            currentBlock?.objectives = currentObjectives
            currentObjectives = []
            
        case "publisher":
            metadata["publisher"] = currentText
            
        case "rights":
            metadata["rights"] = currentText
            
        case "version":
            manifestVersion = currentText
            
        case "au":
            if let activity = currentActivity?.build() {
                allActivities.append(activity)
                
                // Add to current container
                if let currentNode = nodeStack.last {
                    currentNode.children.append(.activity(activity))
                } else {
                    rootNodes.append(.activity(activity))
                }
            }
            currentActivity = nil
            
        case "block":
            if let block = (nodeStack.popLast() as? BlockBuilder)?.build() {
                // Add to parent or root
                if let parent = nodeStack.last {
                    parent.children.append(.block(block))
                } else {
                    rootNodes.append(.block(block))
                }
            }
            currentBlock = nodeStack.last as? BlockBuilder
            
        case "course":
            // Course parsing complete
            if manifestTitle.isEmpty {
                manifestTitle = courseTitle
            }
            if manifestDescription == nil {
                manifestDescription = courseDescription
            }
            
        default:
            break
        }
        
        currentText = ""
    }
    
    // MARK: - Helper Methods
    
    private func handleTitle() {
        let parentElement = elementStack.dropLast().last ?? ""
        
        switch parentElement {
        case "course":
            courseTitle = currentText
        case "courseStructure":
            manifestTitle = currentText
        case "block":
            currentBlock?.title = currentText
        case "au":
            currentActivity?.title = currentText
        default:
            break
        }
    }
    
    private func handleDescription() {
        let parentElement = elementStack.dropLast().last ?? ""
        
        switch parentElement {
        case "course":
            courseDescription = currentText
        case "courseStructure":
            manifestDescription = currentText
        case "block":
            currentBlock?.description = currentText
        case "au":
            currentActivity?.description = currentText
        default:
            break
        }
    }
    
    func buildResult() -> Cmi5XMLParser.ParseResult? {
        guard !manifestId.isEmpty else { return nil }
        
        // Найдем первый блок в rootNodes
        var firstBlock: Cmi5Block?
        if let firstNode = rootNodes.first {
            if case .block(let block) = firstNode {
                firstBlock = convertToNewBlock(block)
            }
        }
        
        let manifest = Cmi5Manifest(
            identifier: manifestId,
            title: manifestTitle,
            description: manifestDescription,
            course: Cmi5Course(
                id: courseId,
                title: courseTitle.isEmpty ? nil : [Cmi5LangString(lang: "en", value: courseTitle)],
                description: courseDescription.isEmpty ? nil : [Cmi5LangString(lang: "en", value: courseDescription)],
                auCount: allActivities.count,
                rootBlock: firstBlock
            )
        )
        
        let extendedCourse = Cmi5FullParser.Cmi5ExtendedCourse(
            manifest: manifest,
            structure: rootNodes,
            metadata: nil
        )
        
        return Cmi5XMLParser.ParseResult(
            manifest: manifest,
            activities: allActivities,
            extendedCourse: extendedCourse
        )
    }

    // Вспомогательная функция для конвертации старого блока в новый
    private func convertToNewBlock(_ oldBlock: Cmi5FullParser.Cmi5Block) -> Cmi5Block {
        var subBlocks: [Cmi5Block] = []
        var activities: [Cmi5Activity] = []
        
        for child in oldBlock.children {
            switch child {
            case .block(let block):
                subBlocks.append(convertToNewBlock(block))
            case .activity(let activity):
                activities.append(activity)
            }
        }
        
        return Cmi5Block(
            id: oldBlock.id,
            title: [Cmi5LangString(lang: "en", value: oldBlock.title)],
            description: oldBlock.description.map { [Cmi5LangString(lang: "en", value: $0)] },
            blocks: subBlocks,
            activities: activities
        )
    }
} 