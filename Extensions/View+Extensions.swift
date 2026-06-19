import SwiftUI

extension View {
    /// Apply a card style with rounded corners and shadow
    func cardStyle() -> some View {
        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 2)
            )
    }

    /// Apply a capsule badge style
    func badgeStyle(color: Color = .blue) -> some View {
        self
            .font(.caption2)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(color.opacity(0.12))
            )
    }
}
