//
//  ChatView.swift
//  FloraFriend
//
//  Created by Daniel Aditya Istyana on 13/06/25.
//

import SwiftUI

struct ChatView: View {
    let plant: PlantIdentification
    @StateObject private var chatService = ChatService()
    @State private var messageText = ""
    @Environment(\.dismiss) private var dismiss
    
    private let suggestedQuestions = [
        "How much water does it need?",
        "What kind of light is best?",
        "Is it safe for pets?",
        "How often should I fertilize?",
        "What are common problems?"
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            plantContextHeader
                            
                            if chatService.messages.isEmpty {
                                suggestedQuestionsView
                            }
                            
                            ForEach(chatService.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if chatService.isLoading {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Thinking...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.leading)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: chatService.messages.count) { _, _ in
                        if let lastMessage = chatService.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                messageInputView
            }
            .navigationTitle("Plant Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            chatService.setPlantContext(plant)
        }
    }
    
    private var plantContextHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let imageData = plant.imageData,
                   let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .cornerRadius(8)
                        .clipped()
                } else {
                    Image(systemName: "leaf.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                        .frame(width: 40, height: 40)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(plant.commonName)
                        .font(.headline)
                    Text(plant.scientificName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
                
                Spacer()
            }
            
            Text("Ask me anything about caring for this plant!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var suggestedQuestionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Suggested Questions")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ForEach(suggestedQuestions, id: \.self) { question in
                Button(action: { sendMessage(question) }) {
                    Text(question)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                }
            }
        }
    }
    
    private var messageInputView: some View {
        HStack {
            TextField("Ask about this plant...", text: $messageText, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(1...4)
            
            Button(action: { sendMessage(messageText) }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(messageText.isEmpty ? .gray : .green)
            }
            .disabled(messageText.isEmpty || chatService.isLoading)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private func sendMessage(_ text: String) {
        guard !text.isEmpty else { return }
        
        chatService.sendMessage(text)
        messageText = ""
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(message.isUser ? Color.green : Color(.systemGray5))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(16)
                
                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
}

class ChatService: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    
    private var plantContext: PlantIdentification?
    private let baseURL = "YOUR_BACKEND_URL_HERE" // Replace with your actual backend URL
    
    func setPlantContext(_ plant: PlantIdentification) {
        plantContext = plant
    }
    
    func sendMessage(_ content: String) {
        let userMessage = ChatMessage(content: content, isUser: true, timestamp: Date())
        messages.append(userMessage)
        
        isLoading = true
        
        Task {
            do {
                let response = try await getChatResponse(for: content)
                DispatchQueue.main.async {
                    let botMessage = ChatMessage(content: response, isUser: false, timestamp: Date())
                    self.messages.append(botMessage)
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    let errorMessage = ChatMessage(
                        content: "I'm sorry, I'm having trouble responding right now. Please try again.",
                        isUser: false,
                        timestamp: Date()
                    )
                    self.messages.append(errorMessage)
                    self.isLoading = false
                }
            }
        }
    }
    
    private func getChatResponse(for message: String) async throws -> String {
        guard let plant = plantContext else {
            throw ChatError.noPlantContext
        }
        
        let contextPrompt = """
        You are an expert botanist helping with care advice for a specific plant. 
        The plant is: \(plant.commonName) (\(plant.scientificName))
        Description: \(plant.plantDescription)
        Current care instructions: Light: \(plant.careInstructions.light), Water: \(plant.careInstructions.water), Soil: \(plant.careInstructions.soil)
        
        User question: \(message)
        
        Please provide helpful, specific advice for this plant.
        """
        
        let requestBody = [
            "message": contextPrompt,
            "plant_context": [
                "common_name": plant.commonName,
                "scientific_name": plant.scientificName
            ]
        ] as [String: Any]
        
        guard let url = URL(string: "\(baseURL)/chat") else {
            throw ChatError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ChatError.serverError
        }
        
        let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
        return chatResponse.message
    }
}

struct ChatResponse: Codable {
    let message: String
}

enum ChatError: Error {
    case noPlantContext
    case invalidURL
    case serverError
}
