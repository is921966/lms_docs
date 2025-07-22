import SwiftUI

struct DepartmentDetailView: View {
    let department: Department
    @StateObject private var service = OrgStructureService.shared
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                headerSection
                
                // Breadcrumb
                breadcrumbSection
                
                // Statistics
                statisticsSection
                
                // Tab selection
                Picker("", selection: $selectedTab) {
                    Text("Сотрудники").tag(0)
                    Text("Подразделения").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Content based on selected tab
                if selectedTab == 0 {
                    employeesSection
                } else {
                    subdepartmentsSection
                }
            }
        }
        .navigationTitle("Подразделение")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "building.2.fill")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(department.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(department.code)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Breadcrumb Section
    
    private var breadcrumbSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(service.getDepartmentPath(for: department.id).enumerated()), id: \.offset) { index, dept in
                    HStack(spacing: 4) {
                        if index > 0 {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        NavigationLink(destination: DepartmentDetailView(department: dept)) {
                            Text(dept.name)
                                .font(.caption)
                                .foregroundColor(dept.id == department.id ? .primary : .blue)
                                .fontWeight(dept.id == department.id ? .semibold : .regular)
                        }
                        .disabled(dept.id == department.id)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        HStack(spacing: 16) {
            OrgStatCard(
                title: "Сотрудников",
                value: "\(service.getEmployeeCount(for: department.id))",
                icon: "person.2",
                color: .blue
            )
            
            OrgStatCard(
                title: "Всего в структуре",
                value: "\(service.getTotalEmployeeCount(for: department))",
                icon: "person.3",
                color: .green
            )
            
            OrgStatCard(
                title: "Подразделений",
                value: "\(department.children?.count ?? 0)",
                icon: "building.2",
                color: .orange
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Employees Section
    
    private var employeesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            let employees = service.getEmployees(for: department.id)
            
            if employees.isEmpty {
                Text("В подразделении нет сотрудников")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                ForEach(employees) { employee in
                    NavigationLink(destination: EmployeeDetailView(employee: employee)) {
                        EmployeeRowView(employee: employee, service: service)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Subdepartments Section
    
    private var subdepartmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let children = department.children, !children.isEmpty {
                ForEach(children) { child in
                    NavigationLink(destination: DepartmentDetailView(department: child)) {
                        DepartmentRowView(department: child, service: service)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            } else {
                Text("Нет дочерних подразделений")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Supporting Views

struct OrgStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct DepartmentRowView: View {
    let department: Department
    let service: OrgStructureService
    
    var body: some View {
        HStack {
            Image(systemName: "building.2")
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(department.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    Text(department.code)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label("\(service.getTotalEmployeeCount(for: department))", systemImage: "person.2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let childCount = department.children?.count, childCount > 0 {
                        Label("\(childCount)", systemImage: "building.2")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Preview

struct DepartmentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DepartmentDetailView(department: Department.mockRoot)
        }
    }
} 