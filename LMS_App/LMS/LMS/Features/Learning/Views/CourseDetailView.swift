import SwiftUI

struct CourseDetailView: View {
    let course: Course
    @State private var selectedModule: Module?
    @State private var showingLesson = false
    @State private var showingAssignment = false
    @State private var showingCertificate = false
    @State private var courseProgress: Double = 0.0
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

                    ForEach(course.modules) { module in
                        ModuleCard(module: module) {
                            selectedModule = module
                            showingLesson = true
                        }
                    }
                }

                // Action buttons
                VStack(spacing: 12) {
                    // Certificate button (if course completed)
                    if course.hasCertificate {
                        Button(action: { showingCertificate = true }) {
                            HStack {
                                Image(systemName: "seal.fill")
                                Text("Посмотреть сертификат")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        }
                    }

                    // Start/Continue button
                    Button(action: {
                        if let firstModule = course.modules.first {
                            selectedModule = firstModule
                            showingLesson = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text(courseProgress == 0 ? "Начать обучение" : "Продолжить обучение")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
                    .disabled(courseProgress == 1.0)
                    .opacity(courseProgress == 1.0 ? 0.6 : 1.0)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    // Assign course button (for admins/managers)
                    if MockAuthService.shared.currentUser?.roles.contains("admin") == true ||
                       MockAuthService.shared.currentUser?.roles.contains("manager") == true {
                        Button(action: { showingAssignment = true }) {
                            Image(systemName: "person.badge.plus")
                        }
                    }

                    Button(action: {}) {
                        Image(systemName: "bookmark")
                    }
                }
            }
        }
        .sheet(isPresented: $showingLesson) {
            if let module = selectedModule {
                LessonView(module: module)
            }
        }
        .sheet(isPresented: $showingAssignment) {
            CourseAssignmentView(course: course)
        }
        .sheet(isPresented: $showingCertificate) {
            if let certificate = generateCertificate(),
               let template = CertificateTemplate.mockTemplates.first {
                CertificateView(certificate: certificate, template: template)
            }
        }
    }

    private func generateCertificate() -> Certificate? {
        guard let user = MockAuthService.shared.currentUser else { return nil }

        return Certificate(
            userId: UUID(),
            courseId: UUID(), // Convert course.id to UUID in real app
            templateId: UUID(),
            certificateNumber: Certificate.generateCertificateNumber(),
            courseName: course.title,
            courseDescription: course.description,
            courseDuration: course.duration,
            userName: "\(user.firstName) \(user.lastName)",
            userEmail: user.email,
            completedAt: Date(),
            score: 92,
            totalScore: 100,
            percentage: 92,
            isPassed: true,
            issuedAt: Date(),
            expiresAt: nil,
            verificationCode: Certificate.generateVerificationCode(),
            pdfUrl: nil
        )
    }
}

// MARK: - Course Header
struct CourseHeaderView: View {
    let course: Course

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background image
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 200)

            VStack(alignment: .leading, spacing: 10) {
                Text(course.category?.displayName ?? "Обучение")
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
                    Label("\(course.modules.count) модулей", systemImage: "square.stack.3d.up")
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
    let module: Module
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    // Module number
                    Text("1")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.blue)
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

                    if false { // TODO: Add completion tracking
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else if false { // TODO: Add locking logic
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                    } else {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }

                // Progress bar
                // TODO: Add progress tracking
                if false {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue)
                                .frame(width: geometry.size.width * 0.5, height: 4)
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
    }
}

// MARK: - Course Extensions
extension Course {
    var fullDescription: String {
        // Use description if it's already detailed
        if description.count > 100 {
            return description
        }

        // Fallback descriptions
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
        // TODO: Check certificate template when available
        title.contains("VIP") || title.contains("продвинутый")
    }
}

#Preview {
    NavigationView {
        CourseDetailView(
            course: Course.createMockCourses().first!
        )
    }
}
