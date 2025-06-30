import SwiftUI

struct ProfileHeaderView: View {
    let user: UserResponse?

    var body: some View {
        VStack(spacing: 15) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)

                Text(initials)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }

            // User info
            if let user = user {
                VStack(spacing: 5) {
                    Text("\(user.firstName) \(user.lastName)")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(user.position ?? "Сотрудник")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(user.department ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Email
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.gray)
                    Text(user.email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }

    private var initials: String {
        guard let user = user else { return "?" }
        let firstInitial = user.firstName.prefix(1)
        let lastInitial = user.lastName.prefix(1)
        return "\(firstInitial)\(lastInitial)"
    }
}
