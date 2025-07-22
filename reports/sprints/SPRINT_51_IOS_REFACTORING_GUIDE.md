# iOS Clean Architecture Refactoring Guide - Sprint 51

**Sprint**: 51  
**День**: 165 (День 2/5)  
**Дата**: 17 июля 2025

## 🏗️ Пошаговая миграция на Clean Architecture

### Шаг 1: Создание DI Container

```swift
// Core/DI/Container.swift
protocol DIContainerProtocol {
    func register<T>(_ type: T.Type, factory: @escaping () -> T)
    func resolve<T>(_ type: T.Type) -> T
}

final class DIContainer: DIContainerProtocol {
    static let shared = DIContainer()
    private var factories = [String: Any]()
    
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        factories[key] = factory
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        guard let factory = factories[key] as? () -> T else {
            fatalError("Dependency \(T.self) not registered")
        }
        return factory()
    }
}

// Core/DI/AppAssembly.swift
final class AppAssembly {
    static func configure(_ container: DIContainer) {
        // Network
        container.register(NetworkServiceProtocol.self) {
            NetworkService()
        }
        
        // Repositories
        container.register(CourseRepositoryProtocol.self) {
            CourseRepository(
                networkService: container.resolve(NetworkServiceProtocol.self),
                cacheService: container.resolve(CacheServiceProtocol.self)
            )
        }
        
        // Use Cases
        container.register(FetchCoursesUseCaseProtocol.self) {
            FetchCoursesUseCase(
                repository: container.resolve(CourseRepositoryProtocol.self)
            )
        }
    }
}
```

### Шаг 2: Domain Layer

```swift
// Domain/Entities/Course.swift
struct Course: Equatable {
    let id: String
    let title: String
    let description: String
    let modules: [Module]
    let instructor: Instructor
    let duration: TimeInterval
    let isCmi5: Bool
}

// Domain/UseCases/FetchCoursesUseCase.swift
protocol FetchCoursesUseCaseProtocol {
    func execute() async throws -> [Course]
}

final class FetchCoursesUseCase: FetchCoursesUseCaseProtocol {
    private let repository: CourseRepositoryProtocol
    
    init(repository: CourseRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [Course] {
        return try await repository.fetchCourses()
    }
}

// Domain/Repositories/CourseRepositoryProtocol.swift
protocol CourseRepositoryProtocol {
    func fetchCourses() async throws -> [Course]
    func fetchCourse(id: String) async throws -> Course
    func enrollInCourse(courseId: String, userId: String) async throws
}
```

### Шаг 3: Data Layer

```swift
// Data/Network/NetworkService.swift
protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let request = try endpoint.asURLRequest()
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}

// Data/Repositories/CourseRepository.swift
final class CourseRepository: CourseRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let cacheService: CacheServiceProtocol
    
    init(networkService: NetworkServiceProtocol, 
         cacheService: CacheServiceProtocol) {
        self.networkService = networkService
        self.cacheService = cacheService
    }
    
    func fetchCourses() async throws -> [Course] {
        // Check cache first
        if let cached: [Course] = cacheService.get(key: "courses"),
           !cacheService.isExpired(key: "courses") {
            return cached
        }
        
        // Fetch from network
        let dto: CoursesResponseDTO = try await networkService.request(
            CoursesEndpoint.list
        )
        
        let courses = dto.courses.map { $0.toDomain() }
        
        // Cache results
        cacheService.set(courses, key: "courses", ttl: 3600)
        
        return courses
    }
}
```

### Шаг 4: Presentation Layer (MVVM-C)

```swift
// Presentation/Scenes/CourseList/CourseListViewModel.swift
@MainActor
final class CourseListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var courses: [Course] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published var searchText = ""
    
    // MARK: - Dependencies
    private let fetchCoursesUseCase: FetchCoursesUseCaseProtocol
    private let enrollCourseUseCase: EnrollCourseUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var filteredCourses: [Course] {
        guard !searchText.isEmpty else { return courses }
        return courses.filter { 
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Init
    init(fetchCoursesUseCase: FetchCoursesUseCaseProtocol,
         enrollCourseUseCase: EnrollCourseUseCaseProtocol) {
        self.fetchCoursesUseCase = fetchCoursesUseCase
        self.enrollCourseUseCase = enrollCourseUseCase
        setupBindings()
    }
    
    // MARK: - Public Methods
    func loadCourses() {
        Task {
            await fetchCourses()
        }
    }
    
    func enrollInCourse(_ course: Course) {
        Task {
            do {
                try await enrollCourseUseCase.execute(courseId: course.id)
                // Handle success
            } catch {
                self.error = error
            }
        }
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func fetchCourses() async {
        isLoading = true
        error = nil
        
        do {
            courses = try await fetchCoursesUseCase.execute()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}
```

### Шаг 5: Coordinator Pattern

```swift
// Presentation/Navigation/Coordinator.swift
protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

extension Coordinator {
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}

// Presentation/Scenes/CourseList/CourseListCoordinator.swift
final class CourseListCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let container: DIContainer
    
    init(navigationController: UINavigationController,
         container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let viewModel = CourseListViewModel(
            fetchCoursesUseCase: container.resolve(FetchCoursesUseCaseProtocol.self),
            enrollCourseUseCase: container.resolve(EnrollCourseUseCaseProtocol.self)
        )
        
        let viewController = CourseListViewController(
            viewModel: viewModel,
            coordinator: self
        )
        
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func showCourseDetail(_ course: Course) {
        let coordinator = CourseDetailCoordinator(
            navigationController: navigationController,
            container: container,
            course: course
        )
        addChild(coordinator)
        coordinator.start()
    }
}
```

### Шаг 6: Миграция существующего кода

#### Before (MVC):
```swift
class CourseListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var courses: [Course] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCourses()
    }
    
    func loadCourses() {
        // Прямой вызов API
        APIClient.shared.getCourses { [weak self] result in
            switch result {
            case .success(let courses):
                self?.courses = courses
                self?.tableView.reloadData()
            case .failure(let error):
                self?.showError(error)
            }
        }
    }
}
```

#### After (MVVM-C):
```swift
final class CourseListViewController: UIViewController {
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(CourseCell.self, forCellReuseIdentifier: CourseCell.identifier)
        return table
    }()
    
    // MARK: - Properties
    private let viewModel: CourseListViewModel
    private weak var coordinator: CourseListCoordinator?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(viewModel: CourseListViewModel, coordinator: CourseListCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.loadCourses()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupBindings() {
        viewModel.$filteredCourses
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.showLoadingIndicator(isLoading)
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }
}

// MARK: - UITableViewDataSource
extension CourseListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.filteredCourses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CourseCell.identifier, for: indexPath) as! CourseCell
        let course = viewModel.filteredCourses[indexPath.row]
        cell.configure(with: course)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CourseListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let course = viewModel.filteredCourses[indexPath.row]
        coordinator?.showCourseDetail(course)
    }
}
```

## 📋 Чеклист миграции модуля

- [ ] Создать Domain entities
- [ ] Определить Use Cases
- [ ] Создать Repository protocols
- [ ] Реализовать Data layer
- [ ] Создать ViewModel
- [ ] Рефакторить ViewController
- [ ] Добавить Coordinator
- [ ] Написать Unit тесты
- [ ] Написать UI тесты
- [ ] Обновить DI регистрацию 