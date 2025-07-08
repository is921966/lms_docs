//
//  NotificationListView.swift
//  LMS
//

import SwiftUI

struct NotificationListView: View {
    var body: some View {
        VStack {
            Text("Уведомления")
                .font(.largeTitle)
                .padding()
            
            Text("Нет новых уведомлений")
                .foregroundColor(.secondary)
                .padding()
            
            Spacer()
        }
        .navigationTitle("Уведомления")
    }
}
