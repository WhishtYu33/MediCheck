import SwiftUI

struct IconPickerView: View {
    @Binding var selectedIcon: String

    private let icons: [(name: String, label: String)] = [
        ("pills.fill", "药片"),
        ("pill.circle.fill", "胶囊"),
        ("cross.case.fill", "医疗箱"),
        ("heart.text.square.fill", "心脏"),
        ("allergens.fill", "过敏"),
        ("leaf.fill", "草本"),
        ("drop.fill", "滴剂"),
        ("syringe.fill", "注射"),
        ("brain.head.profile.fill", "神经"),
        ("lungs.fill", "呼吸"),
        ("stethoscope", "听诊"),
        ("bandage.fill", "绷带"),
        ("pills.circle.fill", "药丸"),
        ("ivfluid.bag.fill", "输液"),
        ("calendar.badge.clock", "日程"),
        ("alarm.fill", "闹钟"),
        ("clock.badge.fill", "定时"),
        ("flask.fill", "试剂"),
        ("testtube.2", "试管"),
        ("staroflife.fill", "急救"),
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(icons, id: \.name) { icon in
                VStack(spacing: 4) {
                    Image(systemName: icon.name)
                        .font(.title3)
                        .foregroundColor(selectedIcon == icon.name ? .white : .primary)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    selectedIcon == icon.name
                                        ? Color.blue
                                        : Color(.systemGray6)
                                )
                        )

                    Text(icon.label)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedIcon = icon.name
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
