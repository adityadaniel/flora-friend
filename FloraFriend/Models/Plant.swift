//
//  Plant.swift
//  FloraFriend
//
//  Created by Daniel Aditya Istyana on 13/06/25.
//

import Foundation
import SwiftData

@Model
class PlantIdentification {
    @Attribute(.unique) var id: UUID
    var imageData: Data?
    var commonName: String
    var scientificName: String
    var plantDescription: String
    var careInstructions: CareInstructions
    var characteristics: PlantCharacteristics
    var safetyInfo: SafetyInformation
    var habitat: String
    var origin: String
    var classification: ScientificClassification
    var plantUse: [PlantUse]
    var timestamp: Date
    
    @Relationship(deleteRule: .cascade, inverse: \PlantChatMessage.plant)
    var chatMessages: [PlantChatMessage] = []
    
    init(
        imageData: Data? = nil,
        commonName: String,
        scientificName: String,
        plantDescription: String,
        careInstructions: CareInstructions,
        characteristics: PlantCharacteristics,
        safetyInfo: SafetyInformation,
        habitat: String,
        origin: String,
        plantUse: [PlantUse],
        classification: ScientificClassification
    ) {
        self.id = UUID()
        self.imageData = imageData
        self.commonName = commonName
        self.scientificName = scientificName
        self.plantDescription = plantDescription
        self.careInstructions = careInstructions
        self.characteristics = characteristics
        self.safetyInfo = safetyInfo
        self.habitat = habitat
        self.origin = origin
        self.classification = classification
        self.plantUse = plantUse
        self.timestamp = Date()
    }
}

struct CareInstructions: Codable {
    let difficulty: String
    let light: String
    let water: String
    let soil: String
    let temperature: String
    let humidity: String
    let fertilizer: String
}

struct PlantCharacteristics: Codable {
    let height: String
    let flowering: String
    let leafDetails: String
}

struct SafetyInformation: Codable {
    let toxicToHumans: Bool
    let toxicToPets: Bool
    let toxicityDetails: String?
}

struct ScientificClassification: Codable {
    let kingdom: String
    let family: String
    let genus: String
    let species: String
}

@Model
class PlantChatMessage {
    @Attribute(.unique) var id: UUID
    var content: String
    var isUser: Bool
    var timestamp: Date
    
    var plant: PlantIdentification?
    
    init(content: String, isUser: Bool, timestamp: Date = Date()) {
        self.id = UUID()
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
}

// Intermediary struct for decoding API response before saving to CoreData model
struct DecodedWrapper<T: Codable>: Codable {
    let data: T
}
struct DecodedPlantIdentification: Codable {
    let imageData: Data?
    let commonName: String
    let scientificName: String
    let plantDescription: String
    let careInstructions: CareInstructions
    let characteristics: PlantCharacteristics
    let safetyInfo: SafetyInformation
    let habitat: String
    let origin: String
    let classification: ScientificClassification
}

#if DEBUG
extension PlantIdentification {
    static let sampleData: [PlantIdentification] = [
        PlantIdentification(
            imageData: Data(),
            commonName: "Phalaenopsis Orchid",
            scientificName: "Phalaenopsis amabilis",
            plantDescription: "Phalaenopsis orchids, commonly known as moth orchids, are among the most popular and widely cultivated orchids in the world. These elegant epiphytic plants are native to Southeast Asia and are prized for their long-lasting, graceful flowers that can bloom for several months. The broad, leathery leaves form a rosette pattern, and the arching flower spikes display stunning blooms in various colors including white, pink, purple, and yellow with intricate patterns.",
            careInstructions: CareInstructions(
                difficulty: "Easy to care",
                light: "Bright, indirect light. Avoid direct sunlight which can scorch the leaves. East or north-facing windows are ideal.",
                water: "Water weekly by soaking the roots in lukewarm water for 15 minutes, then drain completely. Never let roots sit in standing water.",
                soil: "Well-draining orchid bark mix with sphagnum moss. Never use regular potting soil.",
                temperature: "65-80°F (18-27°C) during the day, with a 10-15°F drop at night to encourage blooming.",
                humidity: "50-70% humidity. Use a humidity tray or humidifier in dry environments.",
                fertilizer: "Diluted orchid fertilizer every other week during growing season, monthly during dormancy."
            ),
            characteristics: PlantCharacteristics(
                height: "8-16 inches tall with flower spikes reaching 12-24 inches",
                flowering: "Blooms typically last 2-6 months, occurring once or twice per year. Flowers are 2-5 inches across with five petals and a distinctive lip.",
                leafDetails: "3-6 broad, thick, leathery leaves in a rosette pattern. Leaves are typically 4-12 inches long, dark green with a glossy surface."
            ),
            safetyInfo: SafetyInformation(
                toxicToHumans: false,
                toxicToPets: false,
                toxicityDetails: "Phalaenopsis orchids are generally considered non-toxic to humans and pets, making them safe houseplants for families with children and animals."
            ),
            habitat: "Tropical rainforests of Southeast Asia, growing as epiphytes on trees in humid, warm environments with filtered light.",
            origin: "Native to Southeast Asia, including the Philippines, Indonesia, Taiwan, and northern Australia.",
            plantUse: [
                PlantUse(use: "Decoration", applicable: true),
                PlantUse(use: "Medication", applicable: true),
            ],
            classification: ScientificClassification(
                kingdom: "Plantae",
                family: "Orchidaceae",
                genus: "Phalaenopsis",
                species: "P. amabilis"
            )
        )
    ]
}
#endif
