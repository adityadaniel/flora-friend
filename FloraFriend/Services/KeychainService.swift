import Foundation
import KeychainAccess

class KeychainService {
    static let shared = KeychainService()
    
    private let keychain = Keychain(service: "com.florafriend.app")
    
    private init() {}
    
    private enum Keys {
        static let hasUsedFreeScan = "has_used_free_scan"
        static let freeScansUsed = "free_scans_used"
    }
    
    var hasUsedFreeScan: Bool {
        get {
            return keychain[Keys.hasUsedFreeScan] == "true"
        }
        set {
            keychain[Keys.hasUsedFreeScan] = newValue ? "true" : "false"
        }
    }
    
    var freeScansUsed: Int {
        get {
            guard let value = keychain[Keys.freeScansUsed], let count = Int(value) else {
                return 0
            }
            return count
        }
        set {
            keychain[Keys.freeScansUsed] = String(newValue)
        }
    }
    
    func incrementFreeScansUsed() {
        freeScansUsed += 1
        hasUsedFreeScan = true
    }
    
    func resetFreeScans() {
        freeScansUsed = 0
        hasUsedFreeScan = false
    }
    
    func canUseFreeScans(maxFreeScans: Int = 1) -> Bool {
        return freeScansUsed < maxFreeScans
    }
}