import SwiftUI

struct TableView: View {
    let data: TableData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Headers
            HStack {
                ForEach(data.headers, id: \.self) { header in
                    Text(header)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            Divider()
            
            // Rows (show only first 3)
            ForEach(data.rows.prefix(3), id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { cell in
                        Text(cell)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            
            // More indicator
            if data.rows.count > 3 {
                Text("... и еще \(data.rows.count - 3)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    TableView(
        data: TableData(
            headers: ["Курс", "Прогресс", "Статус"],
            rows: [
                ["Swift Basics", "100%", "Завершен"],
                ["iOS Development", "75%", "В процессе"],
                ["Advanced SwiftUI", "45%", "В процессе"],
                ["Testing", "0%", "Не начат"],
                ["Architecture", "0%", "Не начат"]
            ]
        )
    )
    .padding()
}
