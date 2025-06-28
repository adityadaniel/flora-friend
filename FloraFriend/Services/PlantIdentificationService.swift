//
//  PlantIdentificationService.swift
//  FloraFriend
//
//  Created by Daniel Aditya Istyana on 13/06/25.
//

import Foundation
import UIKit
import AIProxy
import SwiftData

struct PlantIdentificationResponse: Codable {
    let commonName: String
    let scientificName: String
    let plantDescription: String
    let confidence: Double
    let careInstructions: CareInstructions
    let characteristics: PlantCharacteristics
    let safetyInfo: SafetyInformation
    let habitat: String
    let origin: String
    let classification: ScientificClassification
    let uses: [PlantUse]
    let priceRange: PriceRange
    let careLevel: String
}

struct PlantUse: Codable {
    let use: String
    let applicable: Bool
}

struct PriceRange: Codable {
    let min: Double
    let max: Double
    let unit: String
}

class PlantIdentificationService: ObservableObject {
    private let openAIService = AIProxy.openAIService(
        partialKey: PlantIdentificationConfig.partialKey,
        serviceURL: PlantIdentificationConfig.serviceURL
    )
    
    init() {}
    
    func identifyPlant(from image: UIImage) async throws -> PlantIdentification {
        guard let imageURL = AIProxy.encodeImageAsURL(image: image, compressionQuality: 0.8) else {
            throw PlantIdentificationError.imageProcessingFailed
        }
        
        let message = [
            OpenAIChatCompletionRequestBody.Message.user(
                content: .parts([
                    .text("You are a plant identification expert. Analyze the provided plant image and return detailed information in the specified JSON format. Be accurate and comprehensive in your identification."),
                    .imageURL(imageURL)
                ]), 
                name: nil
            )
        ]
        
        let requestBody = OpenAIChatCompletionRequestBody(
            model: "gpt-4o",
            messages: message,
            responseFormat: .jsonSchema(name: "plantID", description: nil, schema: PlantIdentificationConfig.schema, strict: true)
        )
        
        do {
            let response = try await openAIService.chatCompletionRequest(body: requestBody)
            
            guard let content = response.choices.first?.message.content,
                  let jsonData = content.data(using: .utf8) else {
                throw PlantIdentificationError.decodingError
            }
            
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(PlantIdentificationResponse.self, from: jsonData)
            
            // Map PlantIdentificationResponse to PlantIdentification
            let plant = PlantIdentification(
                imageData: image.jpegData(compressionQuality: 0.8), // Save the original image
                commonName: decodedResponse.commonName,
                scientificName: decodedResponse.scientificName,
                plantDescription: decodedResponse.plantDescription,
                careInstructions: decodedResponse.careInstructions,
                characteristics: decodedResponse.characteristics,
                safetyInfo: decodedResponse.safetyInfo,
                habitat: decodedResponse.habitat,
                origin: decodedResponse.origin,
                plantUse: decodedResponse.uses,
                classification: decodedResponse.classification
            )
            return plant
            
        } catch is DecodingError {
            throw PlantIdentificationError.decodingError
        } catch {
            // Handle specific AIProxy errors
            if error.localizedDescription.contains("rate limit") {
                throw PlantIdentificationError.rateLimitExceeded
            } else if error.localizedDescription.contains("authentication") || error.localizedDescription.contains("unauthorized") {
                throw PlantIdentificationError.authenticationFailed
            } else {
                throw PlantIdentificationError.aiProxyError
            }
        }
    }
}

enum PlantIdentificationError: Error {
    case imageProcessingFailed
    case invalidURL
    case serverError
    case decodingError
    case aiProxyError
    case rateLimitExceeded
    case authenticationFailed
    
    var localizedDescription: String {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process the image"
        case .invalidURL:
            return "Invalid server URL"
        case .serverError:
            return "Server error occurred"
        case .decodingError:
            return "Failed to decode response"
        case .aiProxyError:
            return "AI service error occurred"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later"
        case .authenticationFailed:
            return "Authentication failed. Please check your API configuration"
        }
    }
}

// MARK: - Configuration
struct PlantIdentificationConfig {
    static let partialKey = "REPLACE_WITH_ACTUAL_AIPROXY_PARTIAL_KEY" // Replace with your actual AIProxy partial key
    static let serviceURL = "REPLACE_WITH_ACTUAL_AIPROXY_SERVICE_URL" // Replace with your actual AIProxy service URL
    
    static let schema: [String: AIProxyJSONValue] = [
        "type": .string("object"),
        "properties": .object([
            "commonName": .object([
                "type": .string("string"),
                "description": .string("Common name of the plant")
            ]),
            "scientificName": .object([
                "type": .string("string"), 
                "description": .string("Scientific name of the plant")
            ]),
            "plantDescription": .object([
                "type": .string("string"),
                "description": .string("Detailed description of the plant")
            ]),
            "confidence": .object([
                "type": .string("number"),
                "description": .string("Confidence level of identification (0-1)"),
                "minimum": .double(0),
                "maximum": .double(1)
            ]),
            "careInstructions": .object([
                "type": .string("object"),
                "properties": .object([
                    "difficulty": .object([
                        "type": .string("string"),
                        "description": .string("Plant Care difficulty")
                    ]),
                    "light": .object([
                        "type": .string("string"),
                        "description": .string("Light requirements")
                    ]),
                    "water": .object([
                        "type": .string("string"),
                        "description": .string("Watering needs")
                    ]),
                    "soil": .object([
                        "type": .string("string"),
                        "description": .string("Soil requirements")
                    ]),
                    "temperature": .object([
                        "type": .string("string"),
                        "description": .string("Temperature requirements")
                    ]),
                    "humidity": .object([
                        "type": .string("string"),
                        "description": .string("Humidity requirements")
                    ]),
                    "fertilizer": .object([
                        "type": .string("string"),
                        "description": .string("Fertilizer recommendations")
                    ])
                ]),
                "required": .array([
                    .string("difficulty"),
                    .string("light"),
                    .string("water"),
                    .string("soil"),
                    .string("temperature"),
                    .string("humidity"),
                    .string("fertilizer")
                ]),
                "additionalProperties": .bool(false)
            ]),
            "characteristics": .object([
                "type": .string("object"),
                "properties": .object([
                    "height": .object([
                        "type": .string("string"),
                        "description": .string("Expected height range")
                    ]),
                    "flowering": .object([
                        "type": .string("string"),
                        "description": .string("Flowering characteristics")
                    ]),
                    "leafDetails": .object([
                        "type": .string("string"),
                        "description": .string("Leaf characteristics")
                    ])
                ]),
                "required": .array([
                    .string("height"),
                    .string("flowering"),
                    .string("leafDetails")
                ]),
                "additionalProperties": .bool(false)
            ]),
            "safetyInfo": .object([
                "type": .string("object"),
                "properties": .object([
                    "toxicToHumans": .object([
                        "type": .string("boolean"),
                        "description": .string("Whether toxic to humans")
                    ]),
                    "toxicToPets": .object([
                        "type": .string("boolean"),
                        "description": .string("Whether toxic to pets")
                    ]),
                    "toxicityDetails": .object([
                        "anyOf": .array([
                            .object([
                                "type": .string("string")
                            ]),
                            .object([
                                "type": .string("null")
                            ])
                        ]),
                        "description": .string("Details about toxicity (can be null if no specific details)")
                    ])
                ]),
                "required": .array([
                    .string("toxicToHumans"),
                    .string("toxicToPets"),
                    .string("toxicityDetails")
                ]),
                "additionalProperties": .bool(false)
            ]),
            "habitat": .object([
                "type": .string("string"),
                "description": .string("Natural habitat")
            ]),
            "origin": .object([
                "type": .string("string"),
                "description": .string("Geographic origin")
            ]),
            "classification": .object([
                "type": .string("object"),
                "properties": .object([
                    "kingdom": .object([
                        "type": .string("string"),
                        "description": .string("Kingdom classification")
                    ]),
                    "family": .object([
                        "type": .string("string"),
                        "description": .string("Family classification")
                    ]),
                    "genus": .object([
                        "type": .string("string"),
                        "description": .string("Genus classification")
                    ]),
                    "species": .object([
                        "type": .string("string"),
                        "description": .string("Species classification")
                    ])
                ]),
                "required": .array([
                    .string("kingdom"),
                    .string("family"),
                    .string("genus"),
                    .string("species")
                ]),
                "additionalProperties": .bool(false)
            ]),
            "uses": .object([
                "type": .string("array"),
                "description": .string("Common uses for this plant"),
                "items": .object([
                    "type": .string("object"),
                    "properties": .object([
                        "use": .object([
                            "type": .string("string"),
                            "description": .string("Common use for the plant")
                        ]),
                        "applicable": .object([
                            "type": .string("boolean"),
                            "description": .string("Whether this use applies to this plant")
                        ])
                    ]),
                    "required": .array([
                        .string("use"),
                        .string("applicable")
                    ]),
                    "additionalProperties": .bool(false)
                ])
            ]),
            "priceRange": .object([
                "type": .string("object"),
                "properties": .object([
                    "min": .object([
                        "type": .string("number"),
                        "description": .string("Minimum typical price in USD")
                    ]),
                    "max": .object([
                        "type": .string("number"),
                        "description": .string("Maximum typical price in USD")
                    ]),
                    "unit": .object([
                        "type": .string("string"),
                        "description": .string("Price unit (e.g., 'per plant')")
                    ])
                ]),
                "required": .array([
                    .string("min"),
                    .string("max"),
                    .string("unit")
                ]),
                "additionalProperties": .bool(false)
            ]),
            "careLevel": .object([
                "type": .string("string"),
                "description": .string("Overall difficulty of care"),
                "enum": .array([
                    .string("Easy"),
                    .string("Moderate"),
                    .string("Difficult")
                ])
            ])
        ]),
        "required": .array([
            .string("commonName"),
            .string("scientificName"),
            .string("plantDescription"),
            .string("confidence"),
            .string("careInstructions"),
            .string("characteristics"),
            .string("safetyInfo"),
            .string("habitat"),
            .string("origin"),
            .string("classification"),
            .string("uses"),
            .string("priceRange"),
            .string("careLevel")
        ]),
        "additionalProperties": .bool(false)
    ]
}
