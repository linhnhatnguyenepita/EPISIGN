import SwiftUI

struct SplashView: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0F0C29"), Color(hex: "302B63"), Color(hex: "24243E")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulse ? 1.3 : 1.0)
                        .opacity(pulse ? 0 : 1)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false), value: pulse)

                    Image(systemName: "wave.3.right.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .foregroundStyle(
                            LinearGradient(colors: [.purple, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                }

                Text("EPISIGN")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.white, .purple.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    )

                ProgressView()
                    .tint(.white.opacity(0.6))
            }
        }
        .onAppear { pulse = true }
    }
}
