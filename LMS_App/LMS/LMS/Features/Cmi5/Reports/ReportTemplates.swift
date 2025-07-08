//
//  ReportTemplates.swift
//  LMS
//
//  Created on Sprint 42 Day 3 - Report Templates
//

import Foundation

/// Предопределенные шаблоны для различных типов отчетов
public struct ReportTemplate {
    public let name: String
    public let sections: [Section]
    
    public struct Section {
        public let title: String
        public let template: String
        public let type: ReportSection.SectionType
    }
    
    // MARK: - Predefined Templates
    
    public static let progressTemplate = ReportTemplate(
        name: "Progress Report",
        sections: [
            Section(
                title: "Executive Summary",
                template: """
                Course: {{courseName}}
                Learner: {{userName}}
                Period: {{startDate}} - {{endDate}}
                
                Overall Progress: {{completion}}
                Activities Completed: {{activities}}
                Time Invested: {{totalTime}}
                """,
                type: .text
            ),
            Section(
                title: "Detailed Progress",
                template: """
                Weekly Progress:
                Week 1: {{week1Progress}}
                Week 2: {{week2Progress}}
                Week 3: {{week3Progress}}
                Week 4: {{week4Progress}}
                
                Current Streak: {{currentStreak}} days
                Longest Streak: {{longestStreak}} days
                """,
                type: .table
            ),
            Section(
                title: "Completion Timeline",
                template: "Chart: Progress over time",
                type: .chart
            ),
            Section(
                title: "Next Steps",
                template: """
                Estimated completion date: {{estimatedCompletion}}
                Remaining activities: {{remainingActivities}}
                Recommended daily commitment: {{recommendedTime}}
                """,
                type: .text
            )
        ]
    )
    
    public static let performanceTemplate = ReportTemplate(
        name: "Performance Report",
        sections: [
            Section(
                title: "Performance Overview",
                template: """
                Average Score: {{averageScore}}
                Success Rate: {{successRate}}
                Performance Level: {{performanceLevel}}
                
                Highest Score: {{highestScore}} ({{highestScoreActivity}})
                Lowest Score: {{lowestScore}} ({{lowestScoreActivity}})
                """,
                type: .text
            ),
            Section(
                title: "Score Distribution",
                template: "Chart: Score distribution",
                type: .chart
            ),
            Section(
                title: "Module Performance",
                template: """
                {{#modules}}
                Module: {{moduleName}}
                Score: {{moduleScore}}
                Status: {{moduleStatus}}
                {{/modules}}
                """,
                type: .table
            ),
            Section(
                title: "Areas of Excellence",
                template: """
                Top performing areas:
                {{#topAreas}}
                - {{areaName}}: {{areaScore}}
                {{/topAreas}}
                """,
                type: .text
            ),
            Section(
                title: "Areas for Improvement",
                template: """
                Focus areas:
                {{#focusAreas}}
                - {{areaName}}: {{areaScore}} (Target: {{targetScore}})
                {{/focusAreas}}
                
                Recommended resources:
                {{#resources}}
                - {{resourceName}}
                {{/resources}}
                """,
                type: .text
            )
        ]
    )
    
    public static let engagementTemplate = ReportTemplate(
        name: "Engagement Report",
        sections: [
            Section(
                title: "Engagement Summary",
                template: """
                Active Days: {{activeDays}} out of {{totalDays}}
                Engagement Rate: {{engagementRate}}
                Consistency Score: {{consistencyScore}}
                """,
                type: .text
            ),
            Section(
                title: "Learning Patterns",
                template: """
                Preferred Learning Time: {{preferredTime}}
                Average Session Duration: {{avgSessionDuration}}
                Sessions per Week: {{sessionsPerWeek}}
                
                Most Productive Day: {{mostProductiveDay}}
                Peak Performance Hour: {{peakHour}}
                """,
                type: .text
            ),
            Section(
                title: "Activity Heatmap",
                template: "Chart: Learning activity by day and hour",
                type: .chart
            ),
            Section(
                title: "Engagement Trends",
                template: "Chart: Engagement over time",
                type: .chart
            ),
            Section(
                title: "Recommendations",
                template: """
                Based on your learning patterns:
                
                ✅ Schedule study sessions at {{recommendedTime}}
                ✅ Aim for {{recommendedDuration}} minute sessions
                ✅ Maintain a {{recommendedFrequency}} day streak
                
                {{additionalTips}}
                """,
                type: .text
            )
        ]
    )
    
    public static let comparisonTemplate = ReportTemplate(
        name: "Comparison Report",
        sections: [
            Section(
                title: "Performance Comparison",
                template: """
                Your Score: {{userScore}}
                Group Average: {{groupAverage}}
                Difference: {{difference}}
                
                Your Rank: {{rank}} out of {{totalUsers}}
                Percentile: {{percentile}}
                """,
                type: .text
            ),
            Section(
                title: "Comparative Analysis",
                template: "Chart: Your performance vs group",
                type: .chart
            ),
            Section(
                title: "Strengths and Weaknesses",
                template: """
                Areas where you excel:
                {{#strengths}}
                - {{area}}: {{aboveAverage}}% above average
                {{/strengths}}
                
                Areas to improve:
                {{#weaknesses}}
                - {{area}}: {{belowAverage}}% below average
                {{/weaknesses}}
                """,
                type: .table
            ),
            Section(
                title: "Peer Insights",
                template: """
                Top performers' habits:
                - Average study time: {{topPerformersTime}}
                - Completion rate: {{topPerformersCompletion}}
                - Retry attempts: {{topPerformersRetries}}
                
                Your comparative metrics:
                - Study time: {{userStudyTime}}
                - Completion rate: {{userCompletion}}
                - Retry attempts: {{userRetries}}
                """,
                type: .text
            )
        ]
    )
    
    public static let completionTemplate = ReportTemplate(
        name: "Completion Certificate",
        sections: [
            Section(
                title: "Certificate of Completion",
                template: """
                This certifies that
                
                {{userName}}
                
                has successfully completed
                
                {{courseName}}
                
                Date: {{completionDate}}
                Score: {{finalScore}}
                Duration: {{courseDuration}}
                """,
                type: .text
            ),
            Section(
                title: "Achievement Details",
                template: """
                Modules Completed: {{modulesCompleted}}
                Total Learning Time: {{totalTime}}
                Average Score: {{averageScore}}
                Performance Level: {{performanceLevel}}
                """,
                type: .table
            ),
            Section(
                title: "Skills Acquired",
                template: """
                {{#skills}}
                ✓ {{skillName}}
                {{/skills}}
                """,
                type: .text
            ),
            Section(
                title: "Verification",
                template: """
                Certificate ID: {{certificateId}}
                Issued by: {{issuer}}
                Verification URL: {{verificationUrl}}
                """,
                type: .text
            )
        ]
    )
    
    // MARK: - Template Helpers
    
    /// Validates that all required variables are present in the data
    public static func validateData(_ data: [String: String], for template: ReportTemplate) -> [String] {
        var missingVariables: Set<String> = []
        
        for section in template.sections {
            let variables = extractVariables(from: section.template)
            for variable in variables {
                if data[variable] == nil {
                    missingVariables.insert(variable)
                }
            }
        }
        
        return Array(missingVariables).sorted()
    }
    
    /// Extracts variable names from template string
    private static func extractVariables(from template: String) -> [String] {
        let pattern = "\\{\\{([^}]+)\\}\\}"
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: template, range: NSRange(template.startIndex..., in: template))
        
        return matches.compactMap { match in
            guard let range = Range(match.range(at: 1), in: template) else { return nil }
            return String(template[range]).trimmingCharacters(in: .whitespaces)
        }
    }
} 