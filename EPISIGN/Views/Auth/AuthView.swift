//
//  AuthView.swift
//  EPISIGN
//
//  Created by Nhat Linh on 24/04/2026.
//

import SwiftUI
import DotLottie

struct AuthView: View {
    @EnvironmentObject private var appState: AppState
    @State private var email: String = ""
    @State private var password: String = ""

    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool

    @State private var animationInstance: DotLottieAnimation = DotLottieAnimation(
        fileName: "password",
        config: AnimationConfig(autoplay: true, loop: true)
    )

    var body: some View {
        VStack{
            DotLottieView(dotLottie: animationInstance)
                .frame(width: 180, height: 180)
            Text("EPISIGN")
                .font(AppFonts.bricolage(size: 32, weight: .bold))
                .padding(.vertical, 4)
            Text("Login with your EPISIGN account or use Microsoft account")
                .font(AppFonts.dmSans(size: 16))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 24)
                
            VStack(spacing: 0){
                TextField(text: $email){
                    Text("Email")
                }
                .font(AppFonts.dmSans(size: 14))
                .padding(16)
                .focused($isEmailFocused)

                Divider()
                    .background(Color.black.opacity(0.2))

                SecureField(text: $password){
                    Text("Password")
                }
                .font(AppFonts.dmSans(size: 14))
                .padding(16)
                .focused($isPasswordFocused)
            }
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.2), lineWidth: 1))
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .padding(.bottom, 24)
            Button { appState.isAuthenticated = true } label: {
                Text("Login")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.navyGradient)
                    )
            }
            .buttonStyle(.plain)
            Button {}
                 label: {
                Text("Forgot your password?")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
            }
                 .padding(.top, 12)
            Button {} label: {
                HStack(spacing: 8) {
                    Image(systemName: "link")
                        .font(.system(size: 16))
                    Text("Sign in with Microsoft Account")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(Color(.label))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 16)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.05))
        .onTapGesture {
            isEmailFocused = false
            isPasswordFocused = false
        }
        
    }
}

#Preview {
    AuthView()
        .environmentObject(AppState())
}
