import Foundation

struct PendingUser: Identifiable {
    let id: String
    let vkId: String
    let email: String
    let firstName: String
    let lastName: String
    let avatar: String?
    let registeredAt: String
    var isSelected: Bool = false

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
