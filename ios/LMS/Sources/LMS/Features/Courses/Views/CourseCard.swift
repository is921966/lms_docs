import SwiftUI

struct CourseCard: View {
    let course: Course
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Placeholder
            ZStack {
                Rectangle()
                    .fill(course.category.color.opacity(0.2))
                    .frame(height: 160)
                
                VStack(spacing: 8) {
                    Image(systemName: course.category.icon)
                        .font(.largeTitle)
                        .foregroundColor(course.category.color)
                    
                    Text(course.category.rawValue)
                        .font(.caption)
                        .foregroundColor(course.category.color)
                }
                
                // Progress Overlay for enrolled courses
                if course.isEnrolled && course.progress > 0 {
                    VStack {
                        Spacer()
                        ProgressView(value: course.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
                            .background(Color.black.opacity(0.3))
                    }
                }
                
                // Featured Badge
                if course.isFeatured {
                    VStack {
                        HStack {
                            Spacer()
                            Text("Featured")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.yellow)
                                .foregroundColor(.black)
                                .cornerRadius(4)
                                .padding(8)
                        }
                        Spacer()
                    }
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                // Title
                Text(course.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                // Instructor
                Text(course.instructor)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Stats Row
                HStack(spacing: 16) {
                    // Rating
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", course.rating))
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    
                    // Duration
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text("\(course.duration / 60)h \(course.duration % 60)m")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    // Difficulty
                    Text(course.difficulty.rawValue)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(course.difficulty.color.opacity(0.2))
                        .foregroundColor(course.difficulty.color)
                        .cornerRadius(4)
                }
                
                // Bottom Row
                HStack {
                    if course.isEnrolled {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Enrolled")
                                .fontWeight(.medium)
                            if course.progress > 0 {
                                Text("• \(Int(course.progress * 100))%")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .font(.caption)
                    } else {
                        Text("$\(String(format: "%.2f", course.price))")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Students count
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.caption2)
                        Text("\(course.enrolledCount)")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - List Style Card
struct CourseListCard: View {
    let course: Course
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(course.category.color.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: course.category.icon)
                    .font(.title2)
                    .foregroundColor(course.category.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(course.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(course.instructor)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    // Rating
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", course.rating))
                            .font(.caption)
                    }
                    
                    // Lessons
                    Text("\(course.lessonsCount) lessons")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if course.isEnrolled {
                        Text("\(Int(course.progress * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    } else {
                        Text("$\(String(format: "%.0f", course.price))")
                            .font(.callout)
                            .fontWeight(.semibold)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
        .onTapGesture {
            onTap()
        }
    }
} 