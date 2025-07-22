import SwiftUI

struct EmployeeDetailView: View {
    let employee: OrgEmployee
    @StateObject private var service = OrgStructureService.shared
    @State private var showingCallOptions = false
    @State private var showingEmailOptions = false
    
    var department: Department? {
        service.getDepartment(by: employee.departmentId)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with avatar
                headerSection
                
                // Contact info
                contactSection
                
                // Department info
                departmentSection
                
                // Additional info
                additionalInfoSection
            }
            .padding()
        }
        .navigationTitle("Сотрудник")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    if let phone = employee.phone {
                        Button(action: { callPhone(phone) }) {
                            Label("Позвонить", systemImage: "phone")
                        }
                    }
                    
                    if let email = employee.email {
                        Button(action: { sendEmail(email) }) {
                            Label("Написать", systemImage: "envelope")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)
                
                Text(employee.initials)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Name and position
            VStack(spacing: 8) {
                Text(employee.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(employee.position)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Label(employee.tabNumber, systemImage: "number")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Contact Section
    
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Контакты")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                if let email = employee.email {
                    ContactRow(
                        icon: "envelope.fill",
                        title: "Email",
                        value: email,
                        color: .blue,
                        action: { sendEmail(email) }
                    )
                }
                
                if let phone = employee.phone {
                    ContactRow(
                        icon: "phone.fill",
                        title: "Телефон",
                        value: employee.formattedPhone ?? phone,
                        color: .green,
                        action: { callPhone(phone) }
                    )
                }
                
                if employee.email == nil && employee.phone == nil {
                    Text("Контактная информация не указана")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Department Section
    
    private var departmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Подразделение")
                .font(.headline)
                .padding(.horizontal)
            
            if let dept = department {
                NavigationLink(destination: DepartmentDetailView(department: dept)) {
                    HStack {
                        Image(systemName: "building.2.fill")
                            .foregroundColor(.orange)
                            .frame(width: 40, height: 40)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dept.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(dept.code)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                
                // Department path
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(service.getDepartmentPath(for: dept.id).enumerated()), id: \.offset) { index, pathDept in
                            HStack(spacing: 4) {
                                if index > 0 {
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(pathDept.name)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - Additional Info Section
    
    private var additionalInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Дополнительно")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                OrgInfoRow(title: "ID сотрудника", value: employee.id)
                
                if let dept = department {
                    OrgInfoRow(title: "Уровень в структуре", value: "Уровень \(dept.level)")
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Actions
    
    private func callPhone(_ phone: String) {
        if let url = URL(string: "tel://\(phone)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func sendEmail(_ email: String) {
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Supporting Views

struct ContactRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(value)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right.square")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OrgInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Preview

struct EmployeeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EmployeeDetailView(employee: OrgEmployee.allMockEmployees.first!)
        }
    }
} 