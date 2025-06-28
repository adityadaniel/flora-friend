import SwiftUI


extension UIColor {
    static func fromHex(_ hex: Int) -> UIColor {
        return UIColor(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
    static let green50 = UIColor.fromHex(0xE5FAEF)
    static let green100 = UIColor.fromHex(0xCBF6DF)
    static let green200 = UIColor.fromHex(0x8AEAB7)
    static let green300 = UIColor.fromHex(0x27D87A)
    static let green400 = UIColor.fromHex(0x21B567)
    static let green500 = UIColor.fromHex(0x198A4E)
    static let green600 = UIColor.fromHex(0x177D47)
    static let green700 = UIColor.fromHex(0x146C3D)
    static let green800 = UIColor.fromHex(0x105B33)
    static let green900 = UIColor.fromHex(0x0C4125)
    static let green950 = UIColor.fromHex(0x082B18)
}

extension Color {
    static let green50 = Color(UIColor.green50)
    static let green100 = Color(UIColor.green100)
    static let green200 = Color(UIColor.green200)
    static let green300 = Color(UIColor.green300)
    static let green400 = Color(UIColor.green400)
    static let green500 = Color(UIColor.green500)
    static let green600 = Color(UIColor.green600)
    static let green700 = Color(UIColor.green700)
    static let green800 = Color(UIColor.green800)
    static let green900 = Color(UIColor.green900)
    static let green950 = Color(UIColor.green950)
}