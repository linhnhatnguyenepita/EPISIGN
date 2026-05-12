import SwiftUI

struct TopAppBar: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: "graduationcap.fill")
                    .font(AppFonts.dmSans(size: 18, weight: .bold))
                    .foregroundStyle(AppColors.navy)
                VStack(alignment: .leading, spacing: 1) {
                    Text("EPISIGN")
                        .font(AppFonts.dmSans(size: 18, weight: .black))
                        .foregroundStyle(AppColors.textPrimary)
                    Text(appState.role.label)
                        .font(AppFonts.dmSans(size: 11, weight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            Spacer()
            roleSwitcherMenu
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            AppColors.headerBg
                .ignoresSafeArea(edges: .top)
        )
    }

    private var roleSwitcherMenu: some View {
        Menu {
            Section {
                Button {
                    appState.isAuthenticated = false
                } label: {
                    Label("Logout", systemImage: "xmark.circle.fill")
                }
            } header: {
                Text("Logout")
            }
        } label: {
            ZStack {
                Circle()
                    .fill(AppColors.avatarBg)
                    .frame(width: 40, height: 40)
                    .overlay(Circle().stroke(AppColors.avatarRing, lineWidth: 2))
                Image(systemName: appState.role.icon)
                    .font(AppFonts.dmSans(size: 16))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .menuOrder(.fixed)
    }
}

#Preview {
    TopAppBar()
        .environmentObject(AppState())
}
