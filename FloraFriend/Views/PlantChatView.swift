//
//  PlantChatView.swift
//  FloraFriend
//
//  Created by Daniel Aditya Istyana on 13/06/25.
//

import SwiftUI

struct PlantChatView: View {
    @StateObject private var chatService = PlantChatService()
    @State private var messageText = ""
    @State private var showingSuggestions = true
    @Environment(\.modelContext) private var modelContext
    
    let plant: PlantIdentification
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(chatService.messages) { message in
                            ChatBubbleView(message: message)
                                .id(message.id)
                        }
                        
                        if chatService.isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Thinking...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                }
                .onChange(of: chatService.messages.count) { _ in
                    if let lastMessage = chatService.messages.last {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Suggestions (show when no user messages yet)
            if showingSuggestions && chatService.messages.filter({ $0.isUser }).isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(chatService.getSuggestedQuestions(), id: \.self) { suggestion in
                            Button(action: {
                                messageText = suggestion
                                showingSuggestions = false
                                sendMessage()
                            }) {
                                Text(suggestion)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.green500.opacity(0.1))
                                    .foregroundColor(.green500)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
            }
            
            // Input area
            HStack(spacing: 12) {
                TextField("Ask about your \(plant.commonName)...", text: $messageText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(1...4)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .green500)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatService.isLoading)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle("Chat about \(plant.commonName)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            chatService.setCurrentPlant(plant, modelContext: modelContext)
        }
    }
    
    private func sendMessage() {
        let message = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        
        messageText = ""
        showingSuggestions = false
        
        Task {
            await chatService.sendMessage(message)
        }
    }
}

struct ChatBubbleView: View {
    let message: PlantChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 50)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.green500)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 50)
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#if DEBUG
#Preview {
    NavigationView {
        PlantChatView(plant: PlantIdentification.sampleData[0])
    }
}
#endif
