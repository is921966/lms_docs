import Foundation

/// Управление TDD инфраструктурой проекта
/// 
/// Этот класс обеспечивает соблюдение TDD практик в проекте,
/// включая ограничения на количество тестов и проверку готовности инфраструктуры.
///
/// - Note: Создан в рамках Sprint 39 - TDD Excellence
/// - Since: v2.0.0
public final class TDDInfrastructure {
    
    // MARK: - Constants
    
    /// Максимальное количество тестов в день согласно новым правилам TDD v2.0.0
    /// 
    /// После анализа Sprint 33-38 установлено жесткое ограничение:
    /// - Sprint 33 создал 301 тест за 20 минут - это недопустимо!
    /// - Качество важнее количества
    public let maximumTestsPerDay = 10
    
    /// Целевое время для одного TDD цикла (в минутах)
    public let targetCycleTime = 30
    
    /// Минимальный процент рефакторинга в TDD циклах
    public let minimumRefactoringRate = 50
    
    // MARK: - Properties
    
    /// Текущее количество созданных тестов сегодня
    private var todayTestCount = 0
    
    /// Время начала текущего TDD цикла
    private var cycleStartTime: Date?
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Public Methods
    
    /// Проверяет готовность TDD инфраструктуры
    /// 
    /// Инфраструктура считается готовой, если:
    /// - Pre-commit hook установлен
    /// - CI/CD настроен
    /// - Test runner доступен
    public func isInfrastructureReady() -> Bool {
        return checkPreCommitHook() && checkCIPipeline() && checkTestRunner()
    }
    
    /// Начинает новый TDD цикл
    public func startTDDCycle() {
        cycleStartTime = Date()
    }
    
    /// Завершает TDD цикл и возвращает метрики
    public func completeTDDCycle() -> TDDCycleMetrics {
        guard let startTime = cycleStartTime else {
            return TDDCycleMetrics(duration: 0, isCompliant: false)
        }
        
        let duration = Date().timeIntervalSince(startTime)
        let isCompliant = duration <= Double(targetCycleTime * 60)
        
        cycleStartTime = nil
        
        return TDDCycleMetrics(duration: duration, isCompliant: isCompliant)
    }
    
    /// Проверяет, можно ли создать новый тест сегодня
    public func canCreateNewTest() -> Bool {
        return todayTestCount < maximumTestsPerDay
    }
    
    /// Регистрирует создание нового теста
    public func registerNewTest() {
        todayTestCount += 1
    }
    
    // MARK: - Private Methods
    
    private func checkPreCommitHook() -> Bool {
        let fileManager = FileManager.default
        let hookPath = ".git/hooks/pre-commit"
        return fileManager.fileExists(atPath: hookPath)
    }
    
    private func checkCIPipeline() -> Bool {
        let fileManager = FileManager.default
        let workflowPath = ".github/workflows/tdd-compliance.yml"
        return fileManager.fileExists(atPath: workflowPath)
    }
    
    private func checkTestRunner() -> Bool {
        let fileManager = FileManager.default
        let runnerPath = "scripts/run-all-tests.sh"
        return fileManager.fileExists(atPath: runnerPath)
    }
}

// MARK: - Supporting Types

/// Метрики TDD цикла
public struct TDDCycleMetrics {
    /// Продолжительность цикла в секундах
    public let duration: TimeInterval
    
    /// Соответствует ли цикл целевому времени
    public let isCompliant: Bool
    
    /// Форматированная продолжительность
    public var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)м \(seconds)с"
    }
} 