import SwiftUI

struct CourseListView: View {
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<5) { index in
                    CourseRowView(courseName: "Курс \(index + 1)")
                }
            }
            .navigationTitle("Курсы")
        }
    }
}

struct CourseRowView: View {
    let courseName: String
    
    var body: some View {
        HStack {
            Image(systemName: "book.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(courseName)
                    .font(.headline)
                Text("Описание курса")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
