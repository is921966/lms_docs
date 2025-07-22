import SwiftUI

struct EmployeeRowView: View {
    let employee: OrgEmployee
    let service: OrgStructureService
    
    var department: Department? {
        service.getDepartment(by: employee.departmentId)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Text(employee.initials)
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            // Employee info
            VStack(alignment: .leading, spacing: 4) {
                Text(employee.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(employee.position)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Label(employee.tabNumber, systemImage: "number")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let dept = department {
                        Label(dept.name, systemImage: "building.2")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            // Contact icons
            VStack(spacing: 8) {
                if employee.email != nil {
                    Image(systemName: "envelope.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                if employee.phone != nil {
                    Image(systemName: "phone.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Preview

struct EmployeeRowView_Previews: PreviewProvider {
    static var previews: some View {
        EmployeeRowView(
            employee: OrgEmployee.allMockEmployees.first!,
            service: OrgStructureService.shared
        )
        .padding()
    }
} 