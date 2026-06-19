import SwiftUI

struct ColorPickerView: View {
    @Binding var selectedColorHex: String

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Color.medicationPresets, id: \.hex) { preset in
                Circle()
                    .fill(preset.color)
                    .frame(width: 36, height: 36)
                    .overlay {
                        if selectedColorHex.uppercased() == preset.hex.uppercased() {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .overlay(
                        Circle()
                            .stroke(
                                selectedColorHex.uppercased() == preset.hex.uppercased()
                                    ? preset.color : Color.clear,
                                lineWidth: 3
                            )
                            .padding(-4)
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedColorHex = preset.hex
                        }
                    }
            }
        }
        .padding(.vertical, 4)
    }
}
