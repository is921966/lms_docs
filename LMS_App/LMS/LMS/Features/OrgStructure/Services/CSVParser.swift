import Foundation

/// Парсер для CSV файлов
class CSVParser {
    
    // MARK: - Error Types
    
    enum ParsingError: LocalizedError {
        case invalidFile
        case noDataFound
        case missingRequiredColumns
        case invalidDataFormat(row: Int, reason: String)
        case encodingError
        
        var errorDescription: String? {
            switch self {
            case .invalidFile:
                return "Недействительный файл CSV"
            case .noDataFound:
                return "В файле не найдены данные"
            case .missingRequiredColumns:
                return "Отсутствуют обязательные колонки. Требуются: Код, Вышестоящий Код, Название подразделения, Табельный номер, ФИО, Должность"
            case .invalidDataFormat(let row, let reason):
                return "Ошибка в строке \(row): \(reason)"
            case .encodingError:
                return "Ошибка кодировки файла. Используйте UTF-8"
            }
        }
    }
    
    // MARK: - Data Models
    
    struct ParsedDepartment {
        let code: String
        let parentCode: String?
        let name: String
    }
    
    struct ParsedEmployee {
        let tabNumber: String
        let name: String
        let position: String
        let departmentCode: String
        let email: String?
        let phone: String?
    }
    
    struct ImportResult {
        let departments: [ParsedDepartment]
        let employees: [ParsedEmployee]
    }
    
    // MARK: - Properties
    
    private let fileManager = FileManager.default
    
    // MARK: - Public Methods
    
    /// Создает шаблон CSV файла для импорта
    func createTemplateFile() throws -> URL {
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputURL = documentsURL.appendingPathComponent("org_structure_template.csv")
        
        // CSV заголовки и примеры данных
        let csvContent = """
        Код,Вышестоящий Код,Название подразделения,Табельный номер,ФИО,Должность,Email,Телефон
        АП,,ЦУМ,АР00000001,Иванов Иван Иванович,Генеральный директор,ivanov@tsum.ru,+7 (495) 123-45-67
        АП.1,АП,Департамент продаж,АР00000002,Петров Петр Петрович,Директор департамента,petrov@tsum.ru,+7 (495) 123-45-68
        АП.1.1,АП.1,Отдел розничных продаж,АР00000003,Сидоров Сидор Сидорович,Начальник отдела,sidorov@tsum.ru,+7 (495) 123-45-69
        АП.1.1,АП.1,Отдел розничных продаж,АР00000004,Кузнецов Алексей Викторович,Менеджер по продажам,kuznetsov@tsum.ru,
        АП.1.1,АП.1,Отдел розничных продаж,АР00000005,Смирнова Елена Сергеевна,Менеджер по продажам,smirnova@tsum.ru,
        АП.2,АП,Департамент маркетинга,АР00000006,Морозов Дмитрий Андреевич,Директор департамента,morozov@tsum.ru,+7 (495) 123-45-70
        АП.2.1,АП.2,Отдел рекламы,АР00000007,Волкова Анна Николаевна,Начальник отдела,volkova@tsum.ru,
        """
        
        // Сохраняем файл
        try csvContent.write(to: outputURL, atomically: true, encoding: .utf8)
        
        return outputURL
    }
    
    /// Создает шаблон CSV файла в указанном месте
    func createTemplateFileAt(url: URL) throws {
        let csvContent = """
        Код,Вышестоящий Код,Название подразделения,Табельный номер,ФИО,Должность,Email,Телефон
        АП,,ЦУМ,АР00000001,Иванов Иван Иванович,Генеральный директор,ivanov@tsum.ru,+7 (495) 123-45-67
        АП.1,АП,Департамент продаж,АР00000002,Петров Петр Петрович,Директор департамента,petrov@tsum.ru,+7 (495) 123-45-68
        АП.1.1,АП.1,Отдел розничных продаж,АР00000003,Сидоров Сидор Сидорович,Начальник отдела,sidorov@tsum.ru,+7 (495) 123-45-69
        АП.1.1,АП.1,Отдел розничных продаж,АР00000004,Кузнецов Алексей Викторович,Менеджер по продажам,kuznetsov@tsum.ru,
        АП.1.1,АП.1,Отдел розничных продаж,АР00000005,Смирнова Елена Сергеевна,Менеджер по продажам,smirnova@tsum.ru,
        АП.2,АП,Департамент маркетинга,АР00000006,Морозов Дмитрий Андреевич,Директор департамента,morozov@tsum.ru,+7 (495) 123-45-70
        АП.2.1,АП.2,Отдел рекламы,АР00000007,Волкова Анна Николаевна,Начальник отдела,volkova@tsum.ru,
        """
        
        try csvContent.write(to: url, atomically: true, encoding: .utf8)
    }
    
    /// Парсит CSV файл и возвращает структурированные данные
    func parseFile(at url: URL) throws -> ImportResult {
        // Читаем файл
        let csvString: String
        do {
            csvString = try String(contentsOf: url, encoding: .utf8)
        } catch {
            // Пробуем другие кодировки
            if let windowsString = try? String(contentsOf: url, encoding: .windowsCP1251) {
                csvString = windowsString
            } else {
                throw ParsingError.encodingError
            }
        }
        
        // Разбиваем на строки
        let lines = csvString.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        guard lines.count > 1 else {
            throw ParsingError.noDataFound
        }
        
        // Парсим заголовки
        let headers = parseCSVLine(lines[0])
        let columnMap = detectColumns(from: headers)
        
        // Проверяем обязательные колонки
        if columnMap.codeIndex < 0 {
            throw ParsingError.missingRequiredColumns
        }
        
        // Парсим данные
        var departments: [ParsedDepartment] = []
        var employees: [ParsedEmployee] = []
        var departmentSet = Set<String>()
        
        for (index, line) in lines.enumerated() {
            if index == 0 { continue } // Пропускаем заголовки
            
            let row = parseCSVLine(line)
            if row.isEmpty { continue }
            
            // Извлекаем данные
            let code = row[safe: columnMap.codeIndex]?.trimmingCharacters(in: .whitespaces) ?? ""
            let parentCode = row[safe: columnMap.parentCodeIndex]?.trimmingCharacters(in: .whitespaces)
            let departmentName = row[safe: columnMap.departmentIndex]?.trimmingCharacters(in: .whitespaces) ?? ""
            let tabNumber = row[safe: columnMap.tabNumberIndex]?.trimmingCharacters(in: .whitespaces) ?? ""
            let employeeName = row[safe: columnMap.nameIndex]?.trimmingCharacters(in: .whitespaces) ?? ""
            let position = row[safe: columnMap.positionIndex]?.trimmingCharacters(in: .whitespaces) ?? ""
            let email = row[safe: columnMap.emailIndex]?.trimmingCharacters(in: .whitespaces)
            let phone = row[safe: columnMap.phoneIndex]?.trimmingCharacters(in: .whitespaces)
            
            // Пропускаем полностью пустые строки
            if code.isEmpty && tabNumber.isEmpty && employeeName.isEmpty { continue }
            
            // Валидация
            guard !code.isEmpty else {
                throw ParsingError.invalidDataFormat(row: index + 1, reason: "Пустой код подразделения")
            }
            
            // Если есть табельный номер - это сотрудник
            if !tabNumber.isEmpty {
                guard !employeeName.isEmpty else {
                    throw ParsingError.invalidDataFormat(row: index + 1, reason: "Пустое ФИО сотрудника")
                }
                
                employees.append(ParsedEmployee(
                    tabNumber: tabNumber,
                    name: employeeName,
                    position: position,
                    departmentCode: code,
                    email: email?.isEmpty == false ? email : nil,
                    phone: phone?.isEmpty == false ? phone : nil
                ))
            }
            
            // Создаем департамент если еще не существует
            if !departmentSet.contains(code) && !departmentName.isEmpty {
                departmentSet.insert(code)
                departments.append(ParsedDepartment(
                    code: code,
                    parentCode: parentCode?.isEmpty == false ? parentCode : nil,
                    name: departmentName
                ))
            }
        }
        
        guard !departments.isEmpty || !employees.isEmpty else {
            throw ParsingError.noDataFound
        }
        
        return ImportResult(departments: departments, employees: employees)
    }
    
    // MARK: - Private Methods
    
    private func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var currentField = ""
        var inQuotes = false
        
        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                result.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }
        }
        
        // Добавляем последнее поле
        result.append(currentField)
        
        return result
    }
    
    private struct ColumnMap {
        let codeIndex: Int
        let parentCodeIndex: Int
        let departmentIndex: Int
        let tabNumberIndex: Int
        let nameIndex: Int
        let positionIndex: Int
        let emailIndex: Int
        let phoneIndex: Int
    }
    
    private func detectColumns(from headers: [String]) -> ColumnMap {
        let normalizedHeaders = headers.map { $0.lowercased().trimmingCharacters(in: .whitespaces) }
        
        return ColumnMap(
            codeIndex: normalizedHeaders.firstIndex(where: { $0.contains("код") && !$0.contains("вышестоящий") }) ?? -1,
            parentCodeIndex: normalizedHeaders.firstIndex(where: { $0.contains("вышестоящий") || $0.contains("parent") }) ?? -1,
            departmentIndex: normalizedHeaders.firstIndex(where: { $0.contains("название") || $0.contains("подразделение") }) ?? -1,
            tabNumberIndex: normalizedHeaders.firstIndex(where: { $0.contains("табельный") || $0.contains("номер") }) ?? -1,
            nameIndex: normalizedHeaders.firstIndex(where: { $0.contains("фио") || $0.contains("имя") }) ?? -1,
            positionIndex: normalizedHeaders.firstIndex(where: { $0.contains("должность") || $0.contains("position") }) ?? -1,
            emailIndex: normalizedHeaders.firstIndex(where: { $0.contains("email") || $0.contains("почта") }) ?? -1,
            phoneIndex: normalizedHeaders.firstIndex(where: { $0.contains("телефон") || $0.contains("phone") }) ?? -1
        )
    }
}

// MARK: - Array Extension
// Removed - using common extension from ArrayExtensions.swift 