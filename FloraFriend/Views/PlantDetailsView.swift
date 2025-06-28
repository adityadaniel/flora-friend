//
//  PlantDetailsView.swift
//  FloraFriend
//
//  Created by Daniel Aditya Istyana on 13/06/25.
//

import SwiftUI
import StoreKit


struct PlantDetailsView: View {
    enum Source {
        case history
        case camera
    }
    
    let plant: PlantIdentification
    let source: Source
    
    @State private var showingRemoveAlert = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                quickInfoSection
                descriptionSection
                careGuideSection
                characteristicsSection
                safetySection
                habitatSection
                classificationSection
                usesSection
                removeButton
            }
            .padding()
            .padding(.bottom, 80)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbarBackground(self.source == .camera ? .hidden : .automatic, for: .navigationBar)
        .toolbar {
            if source == .camera {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.green500)
                    }
                }
            }
        }
        .overlay(alignment: .bottom) {
            chatButton
        }
        .alert("Remove from Collection", isPresented: $showingRemoveAlert) {
            Button("Remove", role: .destructive) {
                // Handle removal
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to remove this plant from your collection?")
        }
        .background(Color(uiColor: self.colorScheme == .light ? .systemGroupedBackground : .systemBackground))
        }
        .onAppear {
            requestReview()
        }
    }
    
    private var headerSection: some View {
        ZStack(alignment: .bottomLeading) {
            if let imageData = plant.imageData,
               let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .cornerRadius(12)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .cornerRadius(12)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
            }
            // Gradient overlay for text legibility
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.green.opacity(0.9)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(12)
            .frame(height: 200)
            VStack(alignment: .leading, spacing: 4) {
                Text(plant.commonName)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(plant.scientificName)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.85))
                    .italic()
            }
            .padding([.leading, .bottom], 16)
        }
        .frame(height: 200)
    }
    
    private var quickInfoSection: some View {
        HStack(spacing: 20) {
            quickInfoBlock(symbol: "tag.fill", label: "Price", value: "$15 - $50 per plant", symbolColor: .green)
            quickInfoBlock(symbol: "star.fill", label: "Care Level", value: "Moderate to care for.", symbolColor: .orange)
        }
        .padding(.vertical, 4)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    private func quickInfoBlock(symbol: String, label: String, value: String, symbolColor: Color) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.title2)
                    .foregroundColor(symbolColor)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
            }
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var descriptionSection: some View {
        CollapsibleSection(title: "Description", icon: "doc.text") {
            Text(plant.plantDescription)
                .font(.body)
        }
    }
    
    private var careGuideSection: some View {
        CollapsibleSection(title: "Care Guide", icon: "heart.fill") {
            VStack(spacing: 16) {
                CareDetailRow(icon: "star.fill", title: "Care Difficulty", value: plant.careInstructions.difficulty, color: .green)
                CareDetailRow(icon: "sun.max.fill", title: "Light", value: plant.careInstructions.light, color: .orange)
                CareDetailRow(icon: "drop.fill", title: "Water", value: plant.careInstructions.water, color: .blue)
                CareDetailRow(icon: "leaf.fill", title: "Soil", value: plant.careInstructions.soil, color: .green)
                CareDetailRow(icon: "thermometer", title: "Temperature", value: plant.careInstructions.temperature, color: .red)
                CareDetailRow(icon: "humidity.fill", title: "Humidity", value: plant.careInstructions.humidity, color: .cyan)
                CareDetailRow(icon: "pills.fill", title: "Fertilizer", value: plant.careInstructions.fertilizer, color: .brown)
            }
        }
    }
    
    private var characteristicsSection: some View {
        CollapsibleSection(title: "Characteristics", icon: "ruler") {
            VStack(alignment: .leading, spacing: 16) {
                CharacteristicRow(title: "Height", value: plant.characteristics.height)
                CharacteristicRow(title: "Flowering", value: plant.characteristics.flowering)
                CharacteristicRow(title: "Leaves", value: plant.characteristics.leafDetails)
            }
        }
    }
    
    private var safetySection: some View {
        CollapsibleSection(title: "Safety Information", icon: "exclamationmark.triangle.fill") {
            VStack(alignment: .leading, spacing: 16) {
                SafetyRow(
                    icon: "person.fill",
                    title: "Humans",
                    isToxic: plant.safetyInfo.toxicToHumans
                )
                
                SafetyRow(
                    icon: "pawprint.fill",
                    title: "Pets",
                    isToxic: plant.safetyInfo.toxicToPets
                )
                
                if let details = plant.safetyInfo.toxicityDetails {
                    Text(details)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
            }
        }
    }
    
    private var habitatSection: some View {
        CollapsibleSection(title: "Habitat & Origin", icon: "globe") {
            VStack(alignment: .leading, spacing: 16) {
                CharacteristicRow(title: "Habitat", value: plant.habitat)
                CharacteristicRow(title: "Origin", value: plant.origin)
            }
        }
    }
    
    private var classificationSection: some View {
        CollapsibleSection(title: "Scientific Classification", icon: "books.vertical") {
            VStack(alignment: .leading, spacing: 16) {
                CharacteristicRow(title: "Kingdom", value: plant.classification.kingdom)
                CharacteristicRow(title: "Family", value: plant.classification.family)
                CharacteristicRow(title: "Genus", value: plant.classification.genus)
                CharacteristicRow(title: "Species", value: plant.classification.species)
            }
        }
    }
    
    private var usesSection: some View {
        CollapsibleSection(title: "Uses", icon: "hand.raised.fill") {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(self.plant.plantUse, id: \.use) { usage in
                    UsesRow(title: usage.use, isChecked: usage.applicable)
                }
            }
        }
    }
    
    private var removeButton: some View {
        Button(action: { showingRemoveAlert = true }) {
            Text("Remove from my collection")
                .font(.headline)
                .foregroundColor(.red)
                .underline()
        }
        .padding()
    }
    
    private var chatButton: some View {
        NavigationLink(destination: PlantChatView(plant: plant)) {
            HStack {
                Image(systemName: "message.fill")
                Text("Ask about this plant")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(25)
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
        .background(
            LinearGradient(
                colors: [Color.clear, Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct CollapsibleSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    @State private var isExpanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.green)
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }
            
            if isExpanded {
                content
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct CareItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.green)
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct CharacteristicRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .foregroundStyle(.secondary)
            
            Text(value)
                
        }
    }
}

struct SafetyRow: View {
    let icon: String
    let title: String
    let isToxic: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isToxic ? .red : .green)
            
            Text(title)
            
            Spacer()
            
            Text(isToxic ? "Toxic" : "Safe")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isToxic ? Color.red : Color.green)
                .cornerRadius(8)
        }
    }
}

struct CareDetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
        }
    }
}

struct UsesRow: View {
    let title: String
    let isChecked: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isChecked ? .purple : .gray)
            
            Text(title)
                .font(.body)
            
            Spacer()
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        PlantDetailsView(plant: PlantIdentification.sampleData[0], source: .camera)
    }
}
#endif
