import AVKit
import SwiftUI

struct VideoLessonView: View {
    @State private var player = AVPlayer(url: URL(string: "https://example.com/video.mp4")!)

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Video player placeholder
            VideoPlayerSection()

            // Lesson info
            VideoLessonInfo()
        }
    }
}

struct VideoPlayerSection: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black)
                .aspectRatio(16 / 9, contentMode: .fit)

            VStack(spacing: 20) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)

                Text("Видео урок")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
}

struct VideoLessonInfo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Введение в технику продаж")
                .font(.title2)
                .fontWeight(.bold)

            HStack {
                Label("15 минут", systemImage: "clock")
                Label("Иван Петров", systemImage: "person")
            }
            .font(.caption)
            .foregroundColor(.secondary)

            Text("В этом уроке вы узнаете основные принципы успешных продаж, научитесь устанавливать контакт с клиентом и выявлять его потребности.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Key points
            VideoKeyPoints()
        }
    }
}

struct VideoKeyPoints: View {
    let points = [
        "Первое впечатление и приветствие",
        "Открытые вопросы для выявления потребностей",
        "Активное слушание",
        "Презентация преимуществ товара"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ключевые моменты:")
                .font(.headline)

            ForEach(points, id: \.self) { point in
                HStack(alignment: .top) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(point)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    ScrollView {
        VideoLessonView()
            .padding()
    }
}
