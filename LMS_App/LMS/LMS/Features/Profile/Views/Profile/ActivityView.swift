import SwiftUI
import Charts

struct ActivityView: View {
    let weeklyData = WeeklyActivity.mockData

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Активность за неделю")
                .font(.headline)
                .padding(.horizontal)

            // Chart
            Chart(weeklyData) { item in
                BarMark(
                    x: .value("День", item.day),
                    y: .value("Минуты", item.minutes)
                )
                .foregroundStyle(Color.blue.gradient)
            }
            .frame(height: 200)
            .padding(.horizontal)

            // Activity list
            VStack(alignment: .leading, spacing: 15) {
                Text("Последняя активность")
                    .font(.headline)

                ForEach(Activity.mockActivities) { activity in
                    HStack {
                        Image(systemName: activity.icon)
                            .foregroundColor(activity.color)
                            .frame(width: 30)

                        VStack(alignment: .leading) {
                            Text(activity.title)
                                .font(.subheadline)
                            Text(activity.time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
}
