import Foundation
import AVFoundation
import SwiftUI

class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var isAuthorized = false
    @Published var session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var photoCompletion: ((UIImage?) -> Void)?
    
    override init() {
        super.init()
    }
    
    func checkPermissionStatus() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        DispatchQueue.main.async {
            switch status {
            case .authorized:
                self.isAuthorized = true
                self.setupCamera()
            case .denied, .restricted:
                self.isAuthorized = false
            case .notDetermined:
                self.isAuthorized = false
            @unknown default:
                self.isAuthorized = false
            }
        }
    }
    
    private func setupCamera() {
        guard !session.isRunning else { return }
        
        session.beginConfiguration()
        
        // Remove existing inputs
        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Camera device not available")
            session.commitConfiguration()
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            } else {
                print("Cannot add camera input")
                session.commitConfiguration()
                return
            }
            
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            } else {
                print("Cannot add photo output")
                session.commitConfiguration()
                return
            }
            
            session.commitConfiguration()
            
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
            }
        } catch {
            print("Camera setup error: \(error)")
            session.commitConfiguration()
        }
    }
    
    func requestPermission(onComplete: (() -> Void)? = nil) {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                if granted {
                    self?.setupCamera()
                }
                onComplete?()
            }
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        photoCompletion = completion
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        defer { photoCompletion = nil }
        
        if let error = error {
            print("Photo capture error: \(error)")
            photoCompletion?(nil)
            return
        }
        
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            print("Failed to process photo data")
            photoCompletion?(nil)
            return
        }
        
        photoCompletion?(image)
    }
    
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    func startSession() {
        #if targetEnvironment(simulator)
        #else
        guard isAuthorized && !session.isRunning else { return }
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
        #endif
    }
} 
