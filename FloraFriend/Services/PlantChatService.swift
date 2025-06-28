//
//  PlantChatService.swift
//  FloraFriend
//
//  Created by Daniel Aditya Istyana on 13/06/25.
//

import Foundation
import AIProxy
import SwiftUI
import SwiftData

class PlantChatService: ObservableObject {
    @Published var messages: [PlantChatMessage] = []
    @Published var isLoading = false
    
    private let openAIService = AIProxy.openAIService(
        partialKey: PlantIdentificationConfig.partialKey,
        serviceURL: PlantIdentificationConfig.serviceURL
    )
    
    private var currentPlant: PlantIdentification?
    private var modelContext: ModelContext?
    
    init() {}
    
    func setCurrentPlant(_ plant: PlantIdentification, modelContext: ModelContext) {
        self.currentPlant = plant
        self.modelContext = modelContext
        
        // Load existing chat messages for this plant
        loadChatHistory()
        
        // If no messages exist, add welcome message
        if messages.isEmpty {
            let welcomeMessage = PlantChatMessage(
                content: "Hi! I'm here to help you with questions about your \(plant.commonName) (\(plant.scientificName)). Ask me anything about plant care, characteristics, or any specific concerns you might have!",
                isUser: false,
                timestamp: Date.now
            )
            welcomeMessage.plant = plant
            plant.chatMessages.append(welcomeMessage)
            messages.append(welcomeMessage)
            
            try? modelContext.save()
        }
    }
    
    private func loadChatHistory() {
        guard let plant = currentPlant else { return }
        messages = plant.chatMessages.sorted { $0.timestamp < $1.timestamp }
    }
    
    func sendMessage(_ messageContent: String) async {
        guard let plant = currentPlant, let modelContext = modelContext else { return }
        
        let userMessage = PlantChatMessage(content: messageContent, isUser: true, timestamp: Date.now)
        userMessage.plant = plant
        plant.chatMessages.append(userMessage)
        
        await MainActor.run {
            self.messages.append(userMessage)
            isLoading = true
        }
        
        // Save user message
        await MainActor.run {
            try? modelContext.save()
        }
        
        let systemPrompt = """
        You are a helpful plant care assistant. You are currently helping with questions about a \(plant.commonName) (\(plant.scientificName)).
        
        Plant Details:
        - Common Name: \(plant.commonName)
        - Scientific Name: \(plant.scientificName)
        - Description: \(plant.plantDescription)
        - Care Level: \(plant.careInstructions.difficulty)
        - Light Requirements: \(plant.careInstructions.light)
        - Water Requirements: \(plant.careInstructions.water)
        - Soil Requirements: \(plant.careInstructions.soil)
        - Temperature: \(plant.careInstructions.temperature)
        - Humidity: \(plant.careInstructions.humidity)
        - Fertilizer: \(plant.careInstructions.fertilizer)
        - Height: \(plant.characteristics.height)
        - Flowering: \(plant.characteristics.flowering)
        - Leaf Details: \(plant.characteristics.leafDetails)
        - Habitat: \(plant.habitat)
        - Origin: \(plant.origin)
        - Toxic to Humans: \(plant.safetyInfo.toxicToHumans ? "Yes" : "No")
        - Toxic to Pets: \(plant.safetyInfo.toxicToPets ? "Yes" : "No")
        
        IMPORTANT RULES:
        1. Only answer questions related to this specific plant or general plant care
        2. If asked about anything unrelated to plants or plant care, politely redirect the conversation back to the plant
        3. Use the provided plant information to give accurate, helpful advice
        4. Keep responses concise and practical
        5. If you don't have specific information about this plant, provide general plant care advice but mention it's general guidance
        
        Be friendly, helpful, and knowledgeable about plant care.
        """
        
        let apiMessages = [
            OpenAIChatCompletionRequestBody.Message.system(content: .text(systemPrompt), name: nil),
            OpenAIChatCompletionRequestBody.Message.user(content: .text(messageContent), name: nil)
        ]
        
        let requestBody = OpenAIChatCompletionRequestBody(
            model: "gpt-4o-mini",
            messages: apiMessages
        )
        
        do {
            let response = try await openAIService.chatCompletionRequest(body: requestBody)
            
            if let content = response.choices.first?.message.content {
                let aiMessage = PlantChatMessage(content: content, isUser: false, timestamp: .now)
                aiMessage.plant = plant
                plant.chatMessages.append(aiMessage)
                
                await MainActor.run {
                    withAnimation {
                        self.messages.append(aiMessage)
                        self.isLoading = false
                    }
                    // Save AI response
                    try? self.modelContext?.save()
                }
            }
        } catch {
            let errorMessage = PlantChatMessage(
                content: "Sorry, I'm having trouble responding right now. Please try again later.",
                isUser: false,
                timestamp: Date.now
            )
            errorMessage.plant = plant
            plant.chatMessages.append(errorMessage)
            
            await MainActor.run {
                withAnimation {
                    self.messages.append(errorMessage)
                    self.isLoading = false
                }
                // Save error message
                try? self.modelContext?.save()
            }
        }
    }
    
    func getSuggestedQuestions() -> [String] {
        return [
            "How often should I water this plant?",
            "What kind of light does it need?",
            "How do I know if it's healthy?",
            "When should I repot it?",
            "What are common problems with this plant?",
            "How do I propagate this plant?",
            "Is this plant safe for pets?",
            "What fertilizer should I use?",
            "Why are the leaves turning yellow?",
            "How big will this plant get?"
        ]
    }
}
