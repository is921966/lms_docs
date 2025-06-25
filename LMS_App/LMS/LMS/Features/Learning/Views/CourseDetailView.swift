import SwiftUI

struct CourseDetailView: View {
    let course: Course
    @State private var selectedModule: CourseModule?
    @State private var showingLesson = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Course header
                CourseHeaderView(course: course)
                
                // Course info cards
                CourseInfoCards(course: course)
                
                // Description
                VStack(alignment: .leading, spacing: 10) {
                    Text("О курсе")
                        .font(.headline)
                    
                    Text(course.fullDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
                
                // Modules
                VStack(alignment: .leading, spacing: 15) {
                    Text("Программа курса")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(course.courseModules) { module in
                        ModuleCard(module: module) {
                            selectedModule = module
                            showingLesson = true
                        }
                    }
                }
                
                // Start button
                Button(action: {
                    if let firstModule = course.courseModules.first {
                        selectedModule = firstModule
                        showingLesson = true
                    }
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text(course.progress == 0 ? "Начать обучение" : "Продолжить обучение")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "bookmark")
                }
            }
        }
        .sheet(isPresented: $showingLesson) {
            if let module = selectedModule {
                LessonView(module: module)
            }
        }
    }
}

// MARK: - Course Header
struct CourseHeaderView: View {
    let course: Course
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background image
            LinearGradient(
                gradient: Gradient(colors: [course.color, course.color.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 200)
            
            VStack(alignment: .leading, spacing: 10) {
                Text(course.category)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
                
                Text(course.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                HStack {
                    Label(course.duration, systemImage: "clock")
                    Label("\(course.courseModules.count) модулей", systemImage: "square.stack.3d.up")
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
            }
            .padding()
        }
    }
}

// MARK: - Course Info Cards
struct CourseInfoCards: View {
    let course: Course
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                InfoCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Уровень",
                    value: course.level,
                    color: .green
                )
                
                InfoCard(
                    icon: "person.3.fill",
                    title: "Студентов",
                    value: "\(course.enrolledCount)",
                    color: .blue
                )
                
                InfoCard(
                    icon: "star.fill",
                    title: "Рейтинг",
                    value: String(format: "%.1f", course.rating),
                    color: .orange
                )
                
                InfoCard(
                    icon: "rosette",
                    title: "Сертификат",
                    value: course.hasCertificate ? "Да" : "Нет",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 100)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Module Card
struct ModuleCard: View {
    let module: CourseModule
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    // Module number
                    Text("\(module.orderIndex)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(module.isCompleted ? Color.green : Color.gray)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(module.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("\(module.lessons.count) уроков • \(module.duration) мин")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if module.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if module.isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                    } else {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                
                // Progress bar
                if module.progress > 0 && !module.isCompleted {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue)
                                .frame(width: geometry.size.width * module.progress, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
        .disabled(module.isLocked)
    }
}

// MARK: - Course Extensions
extension Course {
    var category: String {
        switch title {
        case "Основы продаж", "Основы продаж в ЦУМ":
            return "Продажи"
        case "Товароведение":
            return "Товары"
        case "Работа с кассой":
            return "Операции"
        case "Визуальный мерчандайзинг":
            return "Дизайн"
        case "Клиентский сервис VIP":
            return "Сервис"
        default:
            return "Обучение"
        }
    }
    
    var fullDescription: String {
        switch title {
        case "Основы продаж", "Основы продаж в ЦУМ":
            return "Курс научит вас эффективным техникам продаж, работе с возражениями клиентов, выявлению потребностей и презентации товара. Вы освоите психологию покупателя и научитесь строить долгосрочные отношения с клиентами."
        case "Товароведение":
            return "Изучите ассортимент магазина, характеристики товаров, правила хранения и выкладки. Научитесь консультировать покупателей о свойствах товаров и помогать им в выборе."
        case "Работа с кассой":
            return "Освойте все операции с кассовым аппаратом, научитесь проводить различные типы оплаты, оформлять возвраты и обмены. Изучите кассовую дисциплину и правила работы с денежными средствами."
        case "Визуальный мерчандайзинг":
            return "Создание привлекательных витрин и организация торгового пространства для максимизации продаж. Изучите основы композиции, работу с цветом и светом."
        case "Клиентский сервис VIP":
            return "Особенности работы с VIP-клиентами, персональный подход, дополнительные услуги. Научитесь создавать эксклюзивный опыт покупок."
        default:
            return description
        }
    }
    
    var level: String {
        switch title {
        case "Основы продаж", "Основы продаж в ЦУМ", "Работа с кассой":
            return "Начальный"
        case "Товароведение", "Визуальный мерчандайзинг":
            return "Средний"
        case "Клиентский сервис VIP":
            return "Продвинутый"
        default:
            return "Начальный"
        }
    }
    
    var enrolledCount: Int {
        Int.random(in: 150...500)
    }
    
    var rating: Double {
        Double.random(in: 4.3...5.0)
    }
    
    var hasCertificate: Bool {
        progress == 1.0 || title.contains("VIP")
    }
    
    var courseModules: [CourseModule] {
        switch title {
        case "Основы продаж", "Основы продаж в ЦУМ":
            return [
                CourseModule(
                    id: UUID(),
                    title: "Введение в продажи",
                    orderIndex: 1,
                    duration: 30,
                    isCompleted: true,
                    isLocked: false,
                    progress: 1.0,
                    lessons: mockLessons(count: 3)
                ),
                CourseModule(
                    id: UUID(),
                    title: "Типы клиентов",
                    orderIndex: 2,
                    duration: 45,
                    isCompleted: true,
                    isLocked: false,
                    progress: 1.0,
                    lessons: mockLessons(count: 4)
                ),
                CourseModule(
                    id: UUID(),
                    title: "Работа с возражениями",
                    orderIndex: 3,
                    duration: 60,
                    isCompleted: false,
                    isLocked: false,
                    progress: 0.6,
                    lessons: mockLessons(count: 5)
                ),
                CourseModule(
                    id: UUID(),
                    title: "Завершение сделки",
                    orderIndex: 4,
                    duration: 40,
                    isCompleted: false,
                    isLocked: true,
                    progress: 0,
                    lessons: mockLessons(count: 3)
                )
            ]
        case "Товароведение":
            return [
                CourseModule(
                    id: UUID(),
                    title: "Категории товаров",
                    orderIndex: 1,
                    duration: 40,
                    isCompleted: false,
                    isLocked: false,
                    progress: 0.3,
                    lessons: mockLessons(count: 4)
                ),
                CourseModule(
                    id: UUID(),
                    title: "Правила хранения",
                    orderIndex: 2,
                    duration: 30,
                    isCompleted: false,
                    isLocked: true,
                    progress: 0,
                    lessons: mockLessons(count: 3)
                )
            ]
        default:
            return []
        }
    }
    
    private func mockLessons(count: Int) -> [Lesson] {
        (1...count).map { index in
            Lesson(
                id: UUID(),
                title: "Урок \(index)",
                type: index == 1 ? .video : (index == count ? .quiz : .text),
                duration: Int.random(in: 5...15),
                isCompleted: false
            )
        }
    }
}

// MARK: - Models
struct CourseModule: Identifiable {
    let id: UUID
    let title: String
    let orderIndex: Int
    let duration: Int
    let isCompleted: Bool
    let isLocked: Bool
    let progress: Double
    let lessons: [Lesson]
}

struct Lesson: Identifiable {
    let id: UUID
    let title: String
    let type: LessonType
    let duration: Int
    let isCompleted: Bool
    
    enum LessonType {
        case video, text, quiz, interactive
    }
}

#Preview {
    NavigationView {
        CourseDetailView(
            course: Course.mockCourses.first!
        )
    }
} 