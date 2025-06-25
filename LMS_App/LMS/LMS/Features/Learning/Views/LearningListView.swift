import SwiftUI

struct LearningListView: View {
    @State private var searchText = ""
    @State private var selectedCategory = "Все"
    @State private var courses: [Course] = Course.mockCourses
    
    let categories = ["Все", "В процессе", "Назначенные", "Завершенные"]
    
    var filteredCourses: [Course] {
        var filtered = courses
        
        // Filter by category
        if selectedCategory != "Все" {
            switch selectedCategory {
            case "В процессе":
                filtered = filtered.filter { $0.progress > 0 && $0.progress < 1 }
            case "Назначенные":
                filtered = filtered.filter { $0.progress == 0 }
            case "Завершенные":
                filtered = filtered.filter { $0.progress == 1 }
            default:
                break
            }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Поиск курсов", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding()
            
            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(categories, id: \.self) { category in
                        CategoryChip(
                            title: category,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
            
            // Course list
            if filteredCourses.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("Курсы не найдены")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(filteredCourses) { course in
                            NavigationLink(destination: CourseDetailView(course: course)) {
                                CourseCard(course: course)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Обучение")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - Course Card
struct CourseCard: View {
    let course: Course
    
    var body: some View {
        HStack(spacing: 15) {
            // Course icon
            Image(systemName: course.icon)
                .font(.system(size: 40))
                .foregroundColor(course.color)
                .frame(width: 60, height: 60)
                .background(course.color.opacity(0.1))
                .cornerRadius(15)
            
            // Course info
            VStack(alignment: .leading, spacing: 8) {
                Text(course.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(course.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(course.color)
                            .frame(width: geometry.size.width * course.progress, height: 4)
                    }
                }
                .frame(height: 4)
                
                HStack {
                    Text("\(Int(course.progress * 100))% завершено")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(course.duration)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Course Model
struct Course: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let progress: Double
    let icon: String
    let color: Color
    let duration: String
    let modules: [Module]
    
    static let mockCourses = [
        Course(
            title: "Основы продаж в ЦУМ",
            description: "Изучите основные техники продаж и работы с клиентами в премиум-сегменте",
            progress: 0.75,
            icon: "cart.fill",
            color: .blue,
            duration: "4 часа",
            modules: Module.mockModulesForSales
        ),
        Course(
            title: "Товароведение",
            description: "Глубокое погружение в ассортимент товаров и их характеристики",
            progress: 0.3,
            icon: "tag.fill",
            color: .green,
            duration: "6 часов",
            modules: Module.mockModulesForProducts
        ),
        Course(
            title: "Работа с кассой",
            description: "Полное руководство по работе с кассовым оборудованием и проведению операций",
            progress: 1.0,
            icon: "creditcard.fill",
            color: .orange,
            duration: "2 часа",
            modules: Module.mockModulesForCashier
        ),
        Course(
            title: "Визуальный мерчандайзинг",
            description: "Создание привлекательных витрин и организация торгового пространства",
            progress: 0.0,
            icon: "eye.fill",
            color: .purple,
            duration: "5 часов",
            modules: Module.mockModulesForVisual
        ),
        Course(
            title: "Клиентский сервис VIP",
            description: "Особенности работы с VIP-клиентами и персональное обслуживание",
            progress: 0.5,
            icon: "star.fill",
            color: .yellow,
            duration: "3 часа",
            modules: Module.mockModulesForVIP
        )
    ]
}

// MARK: - Module Model
struct Module: Identifiable {
    let id = UUID()
    let title: String
    let duration: String
    let isCompleted: Bool
    
    static let mockModulesForSales = [
        Module(title: "Введение в продажи", duration: "30 мин", isCompleted: true),
        Module(title: "Типы клиентов", duration: "45 мин", isCompleted: true),
        Module(title: "Техники презентации товара", duration: "1 час", isCompleted: true),
        Module(title: "Работа с возражениями", duration: "1 час", isCompleted: false),
        Module(title: "Завершение сделки", duration: "45 мин", isCompleted: false)
    ]
    
    static let mockModulesForProducts = [
        Module(title: "Категории товаров", duration: "1 час", isCompleted: true),
        Module(title: "Бренды и их позиционирование", duration: "2 часа", isCompleted: false),
        Module(title: "Сезонные коллекции", duration: "1.5 часа", isCompleted: false),
        Module(title: "Уход за товарами", duration: "1.5 часа", isCompleted: false)
    ]
    
    static let mockModulesForCashier = [
        Module(title: "Интерфейс кассы", duration: "30 мин", isCompleted: true),
        Module(title: "Типы оплаты", duration: "45 мин", isCompleted: true),
        Module(title: "Возвраты и обмены", duration: "45 мин", isCompleted: true)
    ]
    
    static let mockModulesForVisual = [
        Module(title: "Основы композиции", duration: "1 час", isCompleted: false),
        Module(title: "Цветовые решения", duration: "1 час", isCompleted: false),
        Module(title: "Освещение витрин", duration: "1 час", isCompleted: false),
        Module(title: "Сезонное оформление", duration: "2 часа", isCompleted: false)
    ]
    
    static let mockModulesForVIP = [
        Module(title: "Психология VIP-клиента", duration: "45 мин", isCompleted: true),
        Module(title: "Персональный подход", duration: "1 час", isCompleted: true),
        Module(title: "Дополнительные услуги", duration: "1 час 15 мин", isCompleted: false)
    ]
}

// MARK: - Simple Course Detail View (for LearningListView)
struct SimpleCourseDetailView: View {
    let course: Course
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: course.icon)
                            .font(.system(size: 50))
                            .foregroundColor(course.color)
                        
                        Spacer()
                        
                        Text(course.duration)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(course.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(course.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(15)
                
                // Progress
                VStack(alignment: .leading, spacing: 10) {
                    Text("Прогресс")
                        .font(.headline)
                    
                    HStack {
                        Text("\(Int(course.progress * 100))%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(course.color)
                        
                        Spacer()
                        
                        Text("\(course.modules.filter { $0.isCompleted }.count) из \(course.modules.count) модулей")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(course.color)
                                .frame(width: geometry.size.width * course.progress, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                .padding()
                
                // Modules
                VStack(alignment: .leading, spacing: 15) {
                    Text("Модули")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(course.modules) { module in
                        HStack {
                            Image(systemName: module.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(module.isCompleted ? .green : .gray)
                            
                            VStack(alignment: .leading) {
                                Text(module.title)
                                    .font(.body)
                                
                                Text(module.duration)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Text(module.isCompleted ? "Повторить" : "Начать")
                                    .font(.caption)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(module.isCompleted ? Color.gray.opacity(0.2) : course.color)
                                    .foregroundColor(module.isCompleted ? .primary : .white)
                                    .cornerRadius(15)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Детали курса")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        LearningListView()
    }
}
