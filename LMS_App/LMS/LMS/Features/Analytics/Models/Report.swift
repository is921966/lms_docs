//
//  Report.swift
//  LMS
//
//  Created on 26/01/2025.
//

import Foundation
import SwiftUI

// MARK: - Report
struct Report: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var type: ReportType
    var status: ReportStatus
    var period: AnalyticsPeriod
    var createdAt: Date
    var updatedAt: Date?
    var createdBy: String
    var recipients: [String]
    var format: ReportFormat
    var schedule: ReportSchedule?
    var filters: ReportFilters
    var sections: [ReportSection]
    var attachments: [String]

    init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        type: ReportType,
        status: ReportStatus = .draft,
        period: AnalyticsPeriod = .month,
        createdAt: Date = Date(),
        updatedAt: Date? = nil,
        createdBy: String,
        recipients: [String] = [],
        format: ReportFormat = .pdf,
        schedule: ReportSchedule? = nil,
        filters: ReportFilters = ReportFilters(),
        sections: [ReportSection] = [],
        attachments: [String] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.status = status
        self.period = period
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.createdBy = createdBy
        self.recipients = recipients
        self.format = format
        self.schedule = schedule
        self.filters = filters
        self.sections = sections
        self.attachments = attachments
    }
}

// MARK: - Report Type
enum ReportType: String, CaseIterable, Codable {
    case learningProgress = "Прогресс обучения"
    case testResults = "Результаты тестирования"
    case competencyMatrix = "Матрица компетенций"
    case teamPerformance = "Эффективность команды"
    case courseEffectiveness = "Эффективность курсов"
    case roi = "ROI обучения"
    case custom = "Пользовательский"

    var icon: String {
        switch self {
        case .learningProgress: return "chart.line.uptrend.xyaxis"
        case .testResults: return "checkmark.seal.fill"
        case .competencyMatrix: return "square.grid.3x3.fill"
        case .teamPerformance: return "person.3.fill"
        case .courseEffectiveness: return "book.fill"
        case .roi: return "dollarsign.circle.fill"
        case .custom: return "doc.text.fill"
        }
    }

    var color: Color {
        switch self {
        case .learningProgress: return .blue
        case .testResults: return .green
        case .competencyMatrix: return .purple
        case .teamPerformance: return .orange
        case .courseEffectiveness: return .teal
        case .roi: return .yellow
        case .custom: return .gray
        }
    }
}

// MARK: - Report Status
enum ReportStatus: String, CaseIterable, Codable {
    case draft = "Черновик"
    case generating = "Генерируется"
    case ready = "Готов"
    case sent = "Отправлен"
    case failed = "Ошибка"

    var icon: String {
        switch self {
        case .draft: return "doc.text"
        case .generating: return "arrow.clockwise"
        case .ready: return "checkmark.circle.fill"
        case .sent: return "paperplane.fill"
        case .failed: return "exclamationmark.triangle.fill"
        }
    }

    var color: Color {
        switch self {
        case .draft: return .gray
        case .generating: return .blue
        case .ready: return .green
        case .sent: return .teal
        case .failed: return .red
        }
    }
}

// MARK: - Report Format
enum ReportFormat: String, CaseIterable, Codable {
    case pdf = "PDF"
    case excel = "Excel"
    case csv = "CSV"
    case json = "JSON"
    case html = "HTML"

    var icon: String {
        switch self {
        case .pdf: return "doc.fill"
        case .excel: return "tablecells.fill"
        case .csv: return "doc.text.fill"
        case .json: return "curlybraces"
        case .html: return "globe"
        }
    }
}

// MARK: - Report Schedule
struct ReportSchedule: Codable {
    var frequency: ReportFrequency
    var dayOfWeek: Int? // 1-7 for weekly
    var dayOfMonth: Int? // 1-31 for monthly
    var time: Date // Time of day
    var isActive: Bool
    var nextRunDate: Date?
}

// MARK: - Report Frequency
enum ReportFrequency: String, CaseIterable, Codable {
    case daily = "Ежедневно"
    case weekly = "Еженедельно"
    case monthly = "Ежемесячно"
    case quarterly = "Ежеквартально"
    case yearly = "Ежегодно"
}

// MARK: - Report Filters
struct ReportFilters: Codable {
    var departments: [String]
    var positions: [String]
    var users: [String]
    var courses: [String]
    var competencies: [String]
    var dateRange: DateRange?
    var customFilters: [String: String]

    init(
        departments: [String] = [],
        positions: [String] = [],
        users: [String] = [],
        courses: [String] = [],
        competencies: [String] = [],
        dateRange: DateRange? = nil,
        customFilters: [String: String] = [:]
    ) {
        self.departments = departments
        self.positions = positions
        self.users = users
        self.courses = courses
        self.competencies = competencies
        self.dateRange = dateRange
        self.customFilters = customFilters
    }
}

// MARK: - Date Range
struct DateRange: Codable {
    var startDate: Date
    var endDate: Date
}

// MARK: - Report Section
struct ReportSection: Identifiable, Codable {
    let id: UUID
    var title: String
    var type: ReportSectionType
    var order: Int
    var data: ReportSectionData
    var isVisible: Bool

    init(
        id: UUID = UUID(),
        title: String,
        type: ReportSectionType,
        order: Int,
        data: ReportSectionData,
        isVisible: Bool = true
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.order = order
        self.data = data
        self.isVisible = isVisible
    }
}

// MARK: - Report Section Type
enum ReportSectionType: String, Codable {
    case summary = "Сводка"
    case chart = "График"
    case table = "Таблица"
    case text = "Текст"
    case metrics = "Метрики"
}

// MARK: - Report Section Data
enum ReportSectionData: Codable {
    case summary(SummaryData)
    case chart(ChartData)
    case table(TableData)
    case text(String)
    case metrics([MetricData])
}

// MARK: - Summary Data
struct SummaryData: Codable {
    var highlights: [String]
    var keyFindings: [String]
    var recommendations: [String]
}

// MARK: - Chart Data
struct ChartData: Codable {
    var type: ChartType
    var title: String
    var xAxis: String
    var yAxis: String
    var dataPoints: [DataPoint]
}

// MARK: - Chart Type
enum ChartType: String, Codable {
    case line = "Линейный"
    case bar = "Столбчатый"
    case pie = "Круговой"
    case area = "Область"
    case scatter = "Точечный"
}

// MARK: - Data Point
struct DataPoint: Identifiable, Codable {
    let id = UUID()
    var label: String
    var value: Double
    var category: String?
}

// MARK: - Table Data
struct TableData: Codable {
    var headers: [String]
    var rows: [[String]]
}

// MARK: - Metric Data
struct MetricData: Identifiable, Codable {
    let id: UUID
    var title: String
    var value: String
    var change: Double?
    var unit: String?
    var icon: String?

    init(
        id: UUID = UUID(),
        title: String,
        value: String,
        change: Double? = nil,
        unit: String? = nil,
        icon: String? = nil
    ) {
        self.id = id
        self.title = title
        self.value = value
        self.change = change
        self.unit = unit
        self.icon = icon
    }
}
