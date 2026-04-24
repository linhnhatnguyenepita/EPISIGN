import SwiftUI

struct ScanFloatingButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "viewfinder")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(width: 64, height: 64)
                .background(
                    Circle().fill(AppColors.navyGradient)
                )
                .shadow(color: AppColors.navy.opacity(0.25), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Scan NFC tag")
    }
}

#Preview {
    ScanFloatingButton(action: {})
        .padding()
}
