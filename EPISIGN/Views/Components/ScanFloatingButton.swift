import SwiftUI

struct ScanFloatingButton: View {
    var action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Image(systemName: "viewfinder")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.white)
                .frame(width: 60, height: 60)
                .background(AppColors.navyGradient)
                .clipShape(Circle())
                .shadow(color: AppColors.navy.opacity(0.35), radius: 10, x: 0, y: 6)
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.1)) { isPressed = true } }
                .onEnded { _ in withAnimation(.easeInOut(duration: 0.1)) { isPressed = false } }
        )
        .accessibilityLabel("Scan NFC tag")
    }
}

#Preview {
    ScanFloatingButton(action: {})
        .padding()
}
