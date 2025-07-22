import SwiftUI

struct OrgStructureView: View {
    @StateObject private var service = OrgStructureService.shared
    @State private var selectedDepartment: Department?
    @State private var searchText = ""
    @State private var showingImport = false
    @State private var viewMode: ViewMode = .tree
    
    enum ViewMode: String, CaseIterable {
        case tree = "Дерево"
        case list = "Список"
        
        var icon: String {
            switch self {
            case .tree: return "tree"
            case .list: return "list.bullet"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // View mode picker
                Picker("Режим просмотра", selection: $viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Label(mode.rawValue, systemImage: mode.icon)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content
                Group {
                    switch viewMode {
                    case .tree:
                        treeView
                    case .list:
                        listView
                    }
                }
            }
            .navigationTitle("Оргструктура")
            .searchable(text: $searchText, prompt: "Поиск сотрудников")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingImport = true }) {
                        Label("Импорт", systemImage: "square.and.arrow.down")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { service.loadOrganizationStructure() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(service.isLoading)
                }
            }
            .sheet(isPresented: $showingImport) {
                OrgImportView()
            }
            .overlay {
                if service.isLoading {
                    ProgressView("Загрузка...")
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    // MARK: - Tree View
    
    @ViewBuilder
    private var treeView: some View {
        if searchText.isEmpty {
            ScrollView {
                if let root = service.rootDepartment {
                    DepartmentTreeView(
                        department: root,
                        selectedDepartment: $selectedDepartment,
                        service: service
                    )
                    .padding()
                }
            }
        } else {
            searchResultsView
        }
    }
    
    // MARK: - List View
    
    private var listView: some View {
        List {
            if searchText.isEmpty {
                if let root = service.rootDepartment {
                    // Используем компактный вид дерева вместо рекурсивных секций
                    CompactDepartmentTreeItem(department: root, service: service)
                }
            } else {
                searchResultsInList
            }
        }
    }
    
    // MARK: - Search Results
    
    private var searchResultsView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(service.searchEmployees(query: searchText)) { employee in
                    NavigationLink(destination: EmployeeDetailView(employee: employee)) {
                        EmployeeRowView(employee: employee, service: service)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
    
    private var searchResultsInList: some View {
        ForEach(service.searchEmployees(query: searchText)) { employee in
            NavigationLink(destination: EmployeeDetailView(employee: employee)) {
                EmployeeRowView(employee: employee, service: service)
            }
        }
    }
}

// MARK: - Preview

struct OrgStructureView_Previews: PreviewProvider {
    static var previews: some View {
        OrgStructureView()
    }
} 