import SwiftUI
import AVFoundation
import Combine

class QRScannerViewModel: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var scannedCode: String?
    let session = AVCaptureSession()
    private var hasScanned = false

    override init() {
        super.init()
        setupSession()
    }

    private func setupSession() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                DispatchQueue.main.async { self?.configureSession() }
            }
        default:
            return
        }
    }

    private func configureSession() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.qr]

        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.session.startRunning()
        }
    }

    func stop() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.session.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !hasScanned,
              let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = object.stringValue else { return }
        hasScanned = true
        scannedCode = code
        stop()
    }
}

final class PreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}

struct QRCameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        if uiView.previewLayer.session !== session {
            uiView.previewLayer.session = session
        }
    }
}

struct QRScanView: View {
    let lecture: Lecture
    var onScanned: (String) -> Void
    var onDismiss: () -> Void

    @StateObject private var viewModel = QRScannerViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                courseHeader
                scanCard
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 128)
        }
        .background(AppColors.background)
        .onReceive(viewModel.$scannedCode) { code in
            guard let code = code else { return }
            onScanned(code)
        }
        .onDisappear {
            viewModel.stop()
        }
    }

    private var courseHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("IN SESSION")
                .font(AppFonts.dmSans(size: 11, weight: .bold))
                .tracking(0.55)
                .foregroundStyle(AppColors.badgeBlueText)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Capsule().fill(AppColors.badgeBlueBg))

            Text(lecture.title)
                .font(AppFonts.dmSans(size: 24, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
                .padding(.top, 4)

            HStack(spacing: 12) {
                Image(systemName: "person.circle")
                    .font(AppFonts.dmSans(size: 15))
                    .foregroundStyle(AppColors.textSecondary)
                Text(lecture.teacher)
                    .font(AppFonts.dmSans(size: 18, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var scanCard: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 40)
                .fill(AppColors.headerBg)

            VStack(spacing: 0) {
                cameraPreview
                    .padding(.vertical, 24)

                VStack(spacing: 16) {
                    Text("Scan QR Code")
                        .font(AppFonts.dmSans(size: 24, weight: .bold))
                        .tracking(-0.6)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("Point your camera at the QR code\ndisplayed by your teacher to\nverify your attendance.")
                        .font(AppFonts.dmSans(size: 16))
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 16)

                VStack(spacing: 0) {
                    Rectangle()
                        .fill(AppColors.divider)
                        .frame(height: 1)
                    Button {
                        onDismiss()
                    } label: {
                        Text("Go back")
                            .font(AppFonts.dmSans(size: 14, weight: .semibold))
                            .foregroundStyle(AppColors.textSecondary)
                            .padding(.vertical, 24)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 24)
            }
        }
    }

    private var cameraPreview: some View {
        ZStack {
            QRCameraPreview(session: viewModel.session)
                .frame(width: 240, height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.navy, lineWidth: 2)
                .frame(width: 240, height: 240)
        }
        .padding(20)
    }
}

#Preview {
    QRScanView(lecture: MockData.todaysLectures[0], onScanned: { _ in }, onDismiss: {})
}
