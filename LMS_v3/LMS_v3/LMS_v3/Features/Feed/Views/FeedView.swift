import SwiftUI

struct FeedView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0..<5) { index in
                        FeedItemView(title: "Новость \(index + 1)")
                    }
                }
                .padding()
            }
            .navigationTitle("Лента")
        }
    }
}

struct FeedItemView: View {
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            Text("Описание новости...")
                .font(.body)
                .foregroundColor(.secondary)
            Text("2 часа назад")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
