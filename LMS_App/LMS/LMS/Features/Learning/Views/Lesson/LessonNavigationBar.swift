import SwiftUI

struct LessonNavigationBar: View {
    let currentIndex: Int
    let totalLessons: Int
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 15) {
            if currentIndex > 0 {
                Button(action: onPrevious) {
                    Label("Назад", systemImage: "chevron.left")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            Button(action: onNext) {
                if currentIndex < totalLessons - 1 {
                    Label("Далее", systemImage: "chevron.right")
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Завершить модуль")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -2)
    }
}
