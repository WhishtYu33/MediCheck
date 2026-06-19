import SwiftUI

extension Color {
    /// Initialize Color from a hex string like "#FF5733" or "FF5733"
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        guard hexSanitized.count == 6,
              let value = UInt64(hexSanitized, radix: 16) else {
            return nil
        }

        let r = Double((value & 0xFF0000) >> 16) / 255.0
        let g = Double((value & 0x00FF00) >> 8) / 255.0
        let b = Double(value & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    /// Convert Color to hex string
    var hexString: String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

/// Preset medication colors for the color picker
extension Color {
    static let medicationPresets: [(name: String, hex: String, color: Color)] = [
        ("蓝色", "#4A90D9", Color(hex: "#4A90D9")!),
        ("绿色", "#4CD964", Color(hex: "#4CD964")!),
        ("橙色", "#FF9500", Color(hex: "#FF9500")!),
        ("红色", "#FF3B30", Color(hex: "#FF3B30")!),
        ("紫色", "#AF52DE", Color(hex: "#AF52DE")!),
        ("青色", "#5AC8FA", Color(hex: "#5AC8FA")!),
        ("粉色", "#FF2D55", Color(hex: "#FF2D55")!),
        ("薄荷", "#34C759", Color(hex: "#34C759")!),
        ("靛蓝", "#5856D6", Color(hex: "#5856D6")!),
        ("棕色", "#A2845E", Color(hex: "#A2845E")!),
        ("黄绿", "#B2D235", Color(hex: "#B2D235")!),
        ("珊瑚", "#FF6B6B", Color(hex: "#FF6B6B")!),
    ]
}
