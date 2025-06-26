import SwiftUI

struct LessonProgressBar: View {
    let current: Int
    let total: Int
    
    var progress: Double {
        Double(current) / Double(total)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: geometry.size.width * progress)
                    .animation(.easeInOut, value: progress)
            }
        }
        .frame(height: 4)
    }
}
