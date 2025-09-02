//
//  CreateFolderView.swift
//  LMS
//
//  View for creating custom folders with channel selection
//

import SwiftUI

struct CreateFolderView: View {
    @ObservedObject var viewModel: TelegramFeedViewModel
    let onDismiss: () -> Void
    
    @State private var folderName = ""
    @State private var selectedIcon = "folder"
    @State private var selectedChannels: Set<String> = []
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                nameSectionView
                iconSectionView
                channelsSectionView
            }
            .navigationTitle("Новая папка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Создать") {
                        createFolder()
                    }
                    .disabled(folderName.isEmpty || selectedChannels.isEmpty)
                }
            }
        }
        .onAppear {
            ComprehensiveLogger.shared.log(.ui, .info, "CreateFolderView appeared")
        }
    }
    
    private var nameSectionView: some View {
        Section("Название папки") {
            TextField("Введите название", text: $folderName)
        }
    }
    
    private var iconSectionView: some View {
        Section("Иконка") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(folderIcons, id: \.self) { icon in
                        iconButton(for: icon)
                    }
                }
                .padding(.vertical)
            }
        }
    }
    
    private func iconButton(for icon: String) -> some View {
        Image(systemName: icon)
            .font(.system(size: 30))
            .foregroundColor(selectedIcon == icon ? .blue : .gray)
            .onTapGesture {
                selectedIcon = icon
            }
    }
    
    private var channelsSectionView: some View {
        Section("Каналы в папке") {
            ForEach(viewModel.channels) { channel in
                channelRow(for: channel)
            }
        }
    }
    
    private func channelRow(for channel: FeedChannel) -> some View {
        HStack {
            // Отображаем аватар канала в зависимости от типа
            ZStack {
                Circle()
                    .fill(channel.avatar.backgroundColor)
                    .frame(width: 30, height: 30)
                
                switch channel.avatar.type {
                case .image(let imageName):
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                case .icon(let systemName):
                    Image(systemName: systemName)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                case .text(let text):
                    Text(text)
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .medium))
                }
            }
            .frame(width: 30, height: 30)
            
            Text(channel.name)
            
            Spacer()
            
            if selectedChannels.contains(channel.id) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if selectedChannels.contains(channel.id) {
                selectedChannels.remove(channel.id)
            } else {
                selectedChannels.insert(channel.id)
            }
        }
    }
    
    private var folderIcons: [String] {
        ["folder", "folder.fill", "star", "star.fill", "heart", "heart.fill", 
         "bookmark", "bookmark.fill", "tag", "tag.fill", "bell", "bell.fill",
         "flag", "flag.fill", "paperplane", "paperplane.fill"]
    }
    
    private func createFolder() {
        ComprehensiveLogger.shared.log(.data, .info, "Creating new folder", details: [
            "name": folderName,
            "icon": selectedIcon,
            "channelsCount": selectedChannels.count
        ])
        
        viewModel.createCustomFolder(
            name: folderName,
            icon: selectedIcon,
            channelIds: Array(selectedChannels)
        )
        
        dismiss()
    }
} 