//
//  CameraView.swift
//  FloraFriend
//
//  Created by Daniel Aditya Istyana on 13/06/25.
//

import SwiftUI
import SwiftData
import AVFoundation
import PhotosUI
import Lottie

struct CameraView: View {
    @EnvironmentObject private var cameraManager: CameraManager
    @EnvironmentObject private var identificationService: PlantIdentificationService
    @EnvironmentObject var subscriptionService: SubscriptionService
    @Environment(\.modelContext) private var modelContext
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showingPhotosPicker = false
    @State private var isIdentifying = false
    @State private var showingPaywall = false
    @State private var showingHistory = false
    @State private var showingSettings = false
    @State private var identifiedPlant: PlantIdentification?
    @State private var animatePro = false
    @State private var analyzingImage: UIImage?

    @State private var timer: Timer?
    
    var body: some View {
        NavigationStack {
            ZStack {
                if cameraManager.isAuthorized {
                    CameraPreview(session: cameraManager.session)
                        .ignoresSafeArea()
                    
                    // Dimmed overlay with square cutout
                    CameraOverlay()
                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            Button(action: { showingHistory = true }) {
                                Image(systemName: "clock")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                            
                            Spacer()
                            
                            Button(action: capturePhoto) {
                                Circle()
                                    .fill(Color.green500)
                                    .frame(width: 96, height: 96)
                                    .overlay(
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 84, height: 84)
                                            .overlay {
                                                Circle()
                                                    .fill(Color.green400)
                                                    .frame(width: 72, height: 72)
                                                    .overlay {
                                                        Circle()
                                                            .fill(Color.white)
                                                            .frame(width: 60, height: 60)

                                                    }
                                            }
                                    )
                                    
                            }
                            .shadow(color: Color.green300.opacity(0.8), radius: 10, x: 0, y: 0)
                            .disabled(isIdentifying)
                            
                            Spacer()
                            
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 50)
                    }
                } else {
                    VStack {
                        Image(systemName: "camera.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Camera access is required")
                            .font(.headline)
                        Button("Grant Permission") {
                            cameraManager.requestPermission()
                        }
                    }
                }
                
                if isIdentifying {
                    if let analyzingImage = analyzingImage {
                        Image(uiImage: analyzingImage)
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                            .overlay(Color.black.opacity(0.7))
                    } else {
                        Color.black.opacity(0.7)
                            .ignoresSafeArea()
                    }
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.green500))
                            .scaleEffect(1.5)
                        Text("Analyzing plant...")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding(.top)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !subscriptionService.isSubscribed {
                        Text("PRO")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green500)
                            .cornerRadius(12)
                            .scaleEffect(animatePro ? 1.1 : 1.0)
                            .animation(
                                Animation.easeInOut(duration: 1.0)
                                    .repeatForever(autoreverses: true),
                                value: animatePro
                            )
                            .onTapGesture {
                                self.showingPaywall = true
                            }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onChange(of: selectedPhoto) { _, newPhoto in
            if let newPhoto = newPhoto {
                loadSelectedPhoto(newPhoto)
            }
        }
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
        .fullScreenCover(isPresented: $showingHistory) {
            NavigationStack {
                HistoryView()
                    .navigationTitle("History")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: { self.showingHistory = false }) {
                                Label("Close", systemImage: "xmark")
                                    .foregroundColor(.green500)
                                    .labelStyle(.iconOnly)
                            }
                        }
                    }
            }
            .tint(Color.green500)
            .environment(\.modelContext, modelContext)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .fullScreenCover(item: self.$identifiedPlant, content: { identifiedPlant in
            PlantDetailsView(plant: identifiedPlant, source: .camera)
                .navigationBarBackButtonHidden()
        })
        .onAppear {
            self.animatePro = true
            cameraManager.checkPermissionStatus()
            cameraManager.startSession()
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.animatePro.toggle()
            }
        }
        .onDisappear {
            cameraManager.stopSession()
        }
    }
    
    private func capturePhoto() {
        guard subscriptionService.canIdentifyPlant() else {
            showingPaywall = true
            return
        }
        cameraManager.capturePhoto { image in
            if let image = image {
                cameraManager.stopSession()
                analyzingImage = image
                identifyPlant(image: image)
            }
        }
    }
    
    private func loadSelectedPhoto(_ item: PhotosPickerItem) {
        guard subscriptionService.canIdentifyPlant() else {
            showingPaywall = true
            return
        }
        item.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                if let data = data, let image = UIImage(data: data) {
                    cameraManager.stopSession()
                    analyzingImage = image
                    identifyPlant(image: image)
                }
            case .failure:
                break
            }
        }
    }
    
    private func identifyPlant(image: UIImage) {
        Task {
            isIdentifying = true
            await subscriptionService.useIdentification()
            do {
                let result = try await identificationService.identifyPlant(from: image)
                let imageData = image.jpegData(compressionQuality: 0.8)
                
                let plant = PlantIdentification(
                    imageData: imageData,
                    commonName: result.commonName,
                    scientificName: result.scientificName,
                    plantDescription: result.plantDescription,
                    careInstructions: result.careInstructions,
                    characteristics: result.characteristics,
                    safetyInfo: result.safetyInfo,
                    habitat: result.habitat,
                    origin: result.origin,
                    plantUse: result.plantUse,
                    classification: result.classification
                )
                
                await MainActor.run {
                    self.modelContext.insert(plant)
                    do {
                        try self.modelContext.save()
                    } catch {
                        print("Error saving plant: \(error)")
                    }
                    self.isIdentifying = false
                    self.identifiedPlant = plant
                    self.cameraManager.startSession()
                }
            } catch {
                DispatchQueue.main.async {
                    self.isIdentifying = false
                    self.cameraManager.startSession()
                    // Handle error - could show an alert
                }
            }
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct CameraOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            let squareSize: CGFloat = min(geometry.size.width, geometry.size.height) * 0.85
            ZStack {
                // Dimmed background
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                
                // Clear square in the middle
                RoundedRectangle(cornerRadius: 12)
                    .frame(width: squareSize, height: squareSize)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .blendMode(.destinationOut)
            }
            .compositingGroup()
            
            // Square border guide
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white, lineWidth: 3)
                .frame(width: squareSize, height: squareSize)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}

struct CornerIndicator: View {
    let corners: UIRectCorner
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.white)
            .frame(width: 20, height: 3)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white)
                    .frame(width: 3, height: 20)
            )
    }
}
