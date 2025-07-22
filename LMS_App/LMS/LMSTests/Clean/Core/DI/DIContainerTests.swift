import XCTest
@testable import LMS

// MARK: - Mock Services

protocol TestServiceProtocol {
    var identifier: String { get }
}

class TestService: TestServiceProtocol {
    let identifier = UUID().uuidString
}

class SingletonTestService: TestServiceProtocol {
    static var instanceCount = 0
    let identifier: String
    
    init() {
        SingletonTestService.instanceCount += 1
        self.identifier = UUID().uuidString
    }
}

// MARK: - Tests

final class DIContainerTests: XCTestCase {
    var sut: DIContainer!
    
    override func setUp() {
        super.setUp()
        sut = DIContainer()
        SingletonTestService.instanceCount = 0
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Registration Tests
    
    func testRegisterAndResolveFactory() {
        // Given
        sut.register(TestServiceProtocol.self, scope: .factory) { _ in
            TestService()
        }
        
        // When
        let service1 = sut.resolve(TestServiceProtocol.self)
        let service2 = sut.resolve(TestServiceProtocol.self)
        
        // Then
        XCTAssertNotNil(service1)
        XCTAssertNotNil(service2)
        XCTAssertNotEqual(service1?.identifier, service2?.identifier, "Factory should create new instances")
    }
    
    func testRegisterAndResolveSingleton() {
        // Given
        sut.register(TestServiceProtocol.self, scope: .singleton) { _ in
            SingletonTestService()
        }
        
        // When
        let service1 = sut.resolve(TestServiceProtocol.self)
        let service2 = sut.resolve(TestServiceProtocol.self)
        
        // Then
        XCTAssertNotNil(service1)
        XCTAssertNotNil(service2)
        XCTAssertEqual(service1?.identifier, service2?.identifier, "Singleton should return same instance")
        XCTAssertEqual(SingletonTestService.instanceCount, 1, "Only one instance should be created")
    }
    
    func testResolveUnregisteredTypeReturnsNil() {
        // When
        let service = sut.resolve(TestServiceProtocol.self)
        
        // Then
        XCTAssertNil(service)
    }
    
    // MARK: - Thread Safety Tests
    
    func testThreadSafetyForSingletonRegistration() {
        // Given
        let expectation = expectation(description: "All operations completed")
        let iterationCount = 100
        var resolvedServices: [TestServiceProtocol] = []
        let syncQueue = DispatchQueue(label: "test.sync")
        
        sut.register(TestServiceProtocol.self, scope: .singleton) { _ in
            SingletonTestService()
        }
        
        // When
        let group = DispatchGroup()
        
        for _ in 0..<iterationCount {
            group.enter()
            DispatchQueue.global().async {
                if let service = self.sut.resolve(TestServiceProtocol.self) {
                    syncQueue.sync {
                        resolvedServices.append(service)
                    }
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertEqual(resolvedServices.count, iterationCount)
        
        // All instances should have the same identifier (singleton)
        let firstIdentifier = resolvedServices.first?.identifier
        let allSame = resolvedServices.allSatisfy { $0.identifier == firstIdentifier }
        XCTAssertTrue(allSame, "All resolved instances should be the same singleton")
        XCTAssertEqual(SingletonTestService.instanceCount, 1, "Only one instance should be created")
    }
    
    func testThreadSafetyForFactoryRegistration() {
        // Given
        let expectation = expectation(description: "All operations completed")
        let iterationCount = 100
        var resolvedServices: [TestServiceProtocol] = []
        let syncQueue = DispatchQueue(label: "test.sync")
        
        sut.register(TestServiceProtocol.self, scope: .factory) { _ in
            TestService()
        }
        
        // When
        let group = DispatchGroup()
        
        for _ in 0..<iterationCount {
            group.enter()
            DispatchQueue.global().async {
                if let service = self.sut.resolve(TestServiceProtocol.self) {
                    syncQueue.sync {
                        resolvedServices.append(service)
                    }
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertEqual(resolvedServices.count, iterationCount)
        
        // All instances should have different identifiers (factory)
        let identifiers = Set(resolvedServices.map { $0.identifier })
        XCTAssertEqual(identifiers.count, iterationCount, "Factory should create unique instances")
    }
    
    // MARK: - Dependency Resolution Tests
    
    func testResolveDependencyWithContainer() {
        // Given
        class DependentService {
            let testService: TestServiceProtocol
            
            init(testService: TestServiceProtocol) {
                self.testService = testService
            }
        }
        
        sut.register(TestServiceProtocol.self, scope: .singleton) { _ in
            TestService()
        }
        
        sut.register(DependentService.self, scope: .factory) { container in
            DependentService(testService: container.resolve(TestServiceProtocol.self)!)
        }
        
        // When
        let dependentService = sut.resolve(DependentService.self)
        
        // Then
        XCTAssertNotNil(dependentService)
        XCTAssertNotNil(dependentService?.testService)
    }
    
    // MARK: - Override Registration Tests
    
    func testOverrideRegistration() {
        // Given
        class AlternativeTestService: TestServiceProtocol {
            let identifier = "alternative"
        }
        
        sut.register(TestServiceProtocol.self, scope: .singleton) { _ in
            TestService()
        }
        
        // When
        sut.register(TestServiceProtocol.self, scope: .singleton) { _ in
            AlternativeTestService()
        }
        
        let service = sut.resolve(TestServiceProtocol.self)
        
        // Then
        XCTAssertEqual(service?.identifier, "alternative", "Later registration should override earlier one")
    }
} 