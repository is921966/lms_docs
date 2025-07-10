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
    
    private let service = Cmi5Service()
    
    // MARK: - Initialization
    
    init() {
        Task {
            await loadPackages()
        }
    }
    
    // MARK: - Public Methods
    
    func loadPackages() async {
        isLoading = true
        error = nil
        
        do {
            await service.loadPackages()
            packages = service.packages
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deletePackage(_ package: Cmi5Package) async {
        do {
            try await service.deletePackage(id: package.id)
            await loadPackages()
        } catch {
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