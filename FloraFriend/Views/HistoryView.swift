//
//  HistoryView.swift
//  FloraFriend
//
//  Created by Daniel Aditya Istyana on 13/06/25.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PlantIdentification.timestamp, order: .reverse) private var plants: [PlantIdentification]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if plants.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(plants) { plant in
                        NavigationLink(destination: PlantDetailsView(plant: plant, source: .history)) {
                            PlantHistoryRow(plant: plant)
                        }
                    }
                    .onDelete(perform: deletePlants)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Plants Identified Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start identifying plants to see your history here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private func deletePlants(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(plants[index])
            }
            try? modelContext.save()
        }
    }
}

struct PlantHistoryRow: View {
    let plant: PlantIdentification
    
    var body: some View {
        HStack(spacing: 12) {
            plantImage
            
            VStack(alignment: .leading, spacing: 4) {
                Text(plant.commonName)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(plant.scientificName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
                    .lineLimit(1)
                
                Text(plant.timestamp.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private var plantImage: some View {
        Group {
            if let imageData = plant.imageData,
               let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                    )
            }
        }
    }
}
