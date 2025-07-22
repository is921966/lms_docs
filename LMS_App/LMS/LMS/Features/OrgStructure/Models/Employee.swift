import Foundation

struct OrgEmployee: Identifiable, Codable, Equatable {
    let id: String
    let tabNumber: String
    let name: String
    let position: String
    let departmentId: String
    let email: String?
    let phone: String?
    let photoUrl: String?
    
    init(id: String = UUID().uuidString,
         tabNumber: String,
         name: String,
         position: String,
         departmentId: String,
         email: String? = nil,
         phone: String? = nil,
         photoUrl: String? = nil) {
        self.id = id
        self.tabNumber = tabNumber
        self.name = name
        self.position = position
        self.departmentId = departmentId
        self.email = email
        self.phone = phone
        self.photoUrl = photoUrl
    }
    
    // Computed properties
    var initials: String {
        let components = name.components(separatedBy: " ")
        let firstInitial = components.first?.first.map(String.init) ?? ""
        let lastInitial = components.count > 1 ? components[1].first.map(String.init) ?? "" : ""
        return firstInitial + lastInitial
    }
    
    var formattedPhone: String? {
        guard let phone = phone else { return nil }
        // Format Russian phone number
        if phone.starts(with: "+7") && phone.count == 12 {
            let digits = phone.dropFirst(2)
            let index1 = digits.index(digits.startIndex, offsetBy: 3)
            let index2 = digits.index(index1, offsetBy: 3)
            let index3 = digits.index(index2, offsetBy: 2)
            
            return "+7 (\(digits[..<index1])) \(digits[index1..<index2])-\(digits[index2..<index3])-\(digits[index3...])"
        }
        return phone
    }
}

// MARK: - Mock Data
extension OrgEmployee {
    static let mockEmployees: [String: [OrgEmployee]] = [
        "1": [ // ЦУМ
            OrgEmployee(
                tabNumber: "АР21000001",
                name: "Иванов Иван Иванович",
                position: "Генеральный директор",
                departmentId: "1",
                email: "ivanov@tsum.ru",
                phone: "+79991234567"
            ),
            OrgEmployee(
                tabNumber: "АР21000002",
                name: "Петрова Мария Сергеевна",
                position: "Заместитель генерального директора",
                departmentId: "1",
                email: "petrova@tsum.ru",
                phone: "+79991234568"
            )
        ],
        "5": [ // IT Департамент
            OrgEmployee(
                tabNumber: "АР21000612",
                name: "Сидоров Алексей Николаевич",
                position: "Руководитель IT департамента",
                departmentId: "5",
                email: "sidorov@tsum.ru",
                phone: "+79991234569"
            )
        ],
        "6": [ // Отдел Разработки
            OrgEmployee(
                tabNumber: "АР21000620",
                name: "Козлов Дмитрий Андреевич",
                position: "Ведущий разработчик",
                departmentId: "6",
                email: "kozlov@tsum.ru",
                phone: "+79991234570"
            ),
            OrgEmployee(
                tabNumber: "АР21000621",
                name: "Новикова Елена Владимировна",
                position: "iOS разработчик",
                departmentId: "6",
                email: "novikova@tsum.ru",
                phone: "+79991234571"
            ),
            OrgEmployee(
                tabNumber: "АР21000622",
                name: "Морозов Павел Игоревич",
                position: "Backend разработчик",
                departmentId: "6",
                email: "morozov@tsum.ru",
                phone: "+79991234572"
            )
        ],
        "8": [ // HR Департамент
            OrgEmployee(
                tabNumber: "АР21000800",
                name: "Федорова Ольга Михайловна",
                position: "Руководитель HR департамента",
                departmentId: "8",
                email: "fedorova@tsum.ru",
                phone: "+79991234573"
            ),
            OrgEmployee(
                tabNumber: "АР21000801",
                name: "Романова Анна Петровна",
                position: "HR менеджер",
                departmentId: "8",
                email: "romanova@tsum.ru",
                phone: "+79991234574"
            )
        ]
    ]
    
    static func mockEmployees(for departmentId: String) -> [OrgEmployee] {
        return mockEmployees[departmentId] ?? []
    }
    
    static let allMockEmployees: [OrgEmployee] = {
        mockEmployees.values.flatMap { $0 }
    }()
} 