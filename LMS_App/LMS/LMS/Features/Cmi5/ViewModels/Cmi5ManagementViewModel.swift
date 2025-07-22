import Foundation
import SwiftUI

/// ViewModel для управления Cmi5 пакетами
@MainActor
final class Cmi5ManagementViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var packages: [Cmi5Package] = []
    @Published var isLoading = false
    @Published var error: String?
    
    // MARK: - Computed Properties
    
    var activePackagesCount: Int {
        packages.filter { $0.isActive }.count
    }
    
    // MARK: - Properties
    
    // Используем shared instance для синхронизации данных
    private let service = Cmi5Service.shared
    
    // MARK: - Initialization
    
    init() {
        print("🔍 CMI5 MGMT VM: Initializing...")
        Task {
            await loadPackages()
        }
    }
    
    // MARK: - Public Methods
    
    func loadPackages() async {
        print("🔍 CMI5 MGMT VM: Loading packages...")
        isLoading = true
        error = nil
        
        do {
            await service.loadPackages()
            packages = service.packages
            print("🔍 CMI5 MGMT VM: Loaded \(packages.count) packages")
            for package in packages {
                print("  - \(package.title)")
            }
        } catch {
            print("🔍 CMI5 MGMT VM: Error loading packages: \(error)")
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deletePackage(_ package: Cmi5Package) async {
        print("🔍 CMI5 MGMT VM: Deleting package: \(package.title)")
        do {
            try await service.deletePackage(id: package.id)
            await loadPackages()
        } catch {
            print("🔍 CMI5 MGMT VM: Error deleting package: \(error)")
            self.error = error.localizedDescription
        }
    }
    
    func togglePackageStatus(_ package: Cmi5Package) async {
        // TODO: Implement status toggle
        await loadPackages()
    }
}

// Extension to add computed properties to Cmi5Package
extension Cmi5Package {
    var activities: [Cmi5Activity] {
        guard let rootBlock = manifest.rootBlock else { return [] }
        
        var activities: [Cmi5Activity] = []
        
        func collectFromBlock(_ block: Cmi5Block) {
            activities.append(contentsOf: block.activities)
            for childBlock in block.blocks {
                collectFromBlock(childBlock)
            }
        }
        
        collectFromBlock(rootBlock)
        return activities
    }
} 