import SwiftUI

struct DepartmentTreeView: View {
    let department: Department
    @Binding var selectedDepartment: Department?
    let service: OrgStructureService
    @State private var isExpanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Department header
            Button(action: toggleExpanded) {
                HStack(spacing: 8) {
                    // Expand/collapse icon
                    if department.hasChildren {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption)
                            .frame(width: 16)
                            .foregroundColor(.secondary)
                    } else {
                        Color.clear
                            .frame(width: 16)
                    }
                    
                    // Department icon
                    Image(systemName: "building.2")
                        .foregroundColor(.blue)
                    
                    // Department info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(department.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 8) {
                            Text(department.code)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Label("\(service.getTotalEmployeeCount(for: department))", systemImage: "person.2")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Navigation arrow
                    NavigationLink(destination: DepartmentDetailView(department: department)) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedDepartment?.id == department.id ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Children
            if isExpanded && department.hasChildren {
                HStack(spacing: 0) {
                    // Vertical line
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 1)
                        .padding(.leading, 8)
                    
                    // Child departments
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(department.children ?? []) { child in
                            DepartmentTreeView(
                                department: child,
                                selectedDepartment: $selectedDepartment,
                                service: service
                            )
                        }
                    }
                    .padding(.leading, 16)
                }
            }
        }
    }
    
    private func toggleExpanded() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isExpanded.toggle()
        }
    }
}

// MARK: - Compact Tree Item

struct CompactDepartmentTreeItem: View {
    let department: Department
    let service: OrgStructureService
    @State private var isExpanded = false
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(department.children ?? []) { child in
                CompactDepartmentTreeItem(department: child, service: service)
            }
        } label: {
            NavigationLink(destination: DepartmentDetailView(department: department)) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(department.name)
                            .font(.headline)
                        Text("\(department.code) • \(service.getTotalEmployeeCount(for: department)) сотрудников")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Preview

struct DepartmentTreeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ScrollView {
                DepartmentTreeView(
                    department: Department.mockRoot,
                    selectedDepartment: .constant(nil),
                    service: OrgStructureService.shared
                )
                .padding()
            }
        }
    }
} 