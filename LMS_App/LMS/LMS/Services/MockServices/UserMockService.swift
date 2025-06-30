import Combine
import Foundation

// MARK: - Employee Role
enum EmployeeRole: String, Codable, CaseIterable {
    case employee = "Сотрудник"
    case manager = "Менеджер"
    case hr = "HR"
    case admin = "Администратор"
}

class UserMockService: ObservableObject {
    static let shared = UserMockService()

    @Published var users: [Employee] = []

    init() {
        loadMockUsers()
    }

    private func loadMockUsers() {
        users = [
            Employee(
                id: "1",
                fullName: "Иван Иванов",
                email: "ivan.ivanov@company.ru",
                position: "Продавец",
                department: "Отдел продаж",
                role: .employee,
                isActive: true
            ),
            Employee(
                id: "2",
                fullName: "Петр Петров",
                email: "petr.petrov@company.ru",
                position: "Кассир",
                department: "Отдел продаж",
                role: .employee,
                isActive: true
            ),
            Employee(
                id: "3",
                fullName: "Мария Сидорова",
                email: "maria.sidorova@company.ru",
                position: "Мерчандайзер",
                department: "Отдел маркетинга",
                role: .employee,
                isActive: true
            ),
            Employee(
                id: "4",
                fullName: "Анна Козлова",
                email: "anna.kozlova@company.ru",
                position: "Менеджер по продажам",
                department: "Отдел продаж",
                role: .manager,
                isActive: true
            ),
            Employee(
                id: "5",
                fullName: "Сергей Смирнов",
                email: "sergey.smirnov@company.ru",
                position: "HR-менеджер",
                department: "HR",
                role: .hr,
                isActive: true
            ),
            Employee(
                id: "6",
                fullName: "Елена Николаева",
                email: "elena.nikolaeva@company.ru",
                position: "Директор магазина",
                department: "Управление",
                role: .admin,
                isActive: true
            ),
            Employee(
                id: "7",
                fullName: "Дмитрий Васильев",
                email: "dmitry.vasiliev@company.ru",
                position: "Стажер",
                department: "Отдел продаж",
                role: .employee,
                isActive: true
            ),
            Employee(
                id: "8",
                fullName: "Ольга Федорова",
                email: "olga.fedorova@company.ru",
                position: "Бухгалтер",
                department: "Финансы",
                role: .employee,
                isActive: true
            )
        ]
    }

    func getUsers() -> [Employee] {
        users
    }

    func getEmployee(by id: String) -> Employee? {
        users.first { $0.id == id }
    }

    func getUsersByRole(_ role: EmployeeRole) -> [Employee] {
        users.filter { $0.role == role }
    }

    func getUsersByDepartment(_ department: String) -> [Employee] {
        users.filter { $0.department == department }
    }

    func searchUsers(_ query: String) -> [Employee] {
        guard !query.isEmpty else { return users }

        let lowercasedQuery = query.lowercased()
        return users.filter { user in
            user.fullName.lowercased().contains(lowercasedQuery) ||
            user.email.lowercased().contains(lowercasedQuery) ||
            user.position.lowercased().contains(lowercasedQuery) ||
            user.department.lowercased().contains(lowercasedQuery)
        }
    }

    func addEmployee(_ user: Employee) {
        users.append(user)
    }

    func updateEmployee(_ user: Employee) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
        }
    }

    func deleteEmployee(by id: String) {
        users.removeAll { $0.id == id }
    }
}

// MARK: - Employee Model
struct Employee: Identifiable, Codable {
    let id: String
    var fullName: String
    var email: String
    var position: String
    var department: String
    var role: EmployeeRole
    var isActive: Bool
    var avatarUrl: String?
    var phoneNumber: String?
    var hireDate: Date?

    init(
        id: String = UUID().uuidString,
        fullName: String,
        email: String,
        position: String,
        department: String,
        role: EmployeeRole = .employee,
        isActive: Bool = true,
        avatarUrl: String? = nil,
        phoneNumber: String? = nil,
        hireDate: Date? = nil
    ) {
        self.id = id
        self.fullName = fullName
        self.email = email
        self.position = position
        self.department = department
        self.role = role
        self.isActive = isActive
        self.avatarUrl = avatarUrl
        self.phoneNumber = phoneNumber
        self.hireDate = hireDate
    }
}
