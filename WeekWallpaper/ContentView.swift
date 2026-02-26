import SwiftUI
import Photos

struct ContentView: View {
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isSaving = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header ──
                Text("Year in Weeks")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.top, 16)

                Text("Dynamic wallpaper · updates weekly")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.35))
                    .padding(.top, 4)
                    .padding(.bottom, 24)

                // ── Phone Preview Frame ──
                ZStack {
                    // Phone bezel
                    RoundedRectangle(cornerRadius: 44)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.15), .white.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 44)
                                .fill(Color(hex: "0A0A0A"))
                        )

                    // Wallpaper preview
                    WallpaperView()
                        .clipShape(RoundedRectangle(cornerRadius: 42))
                        .padding(2)
                }
                .frame(width: 280, height: 606)
                .shadow(color: .white.opacity(0.03), radius: 30, y: 5)
                .padding(.bottom, 32)

                // ── Save Button ──
                Button(action: saveWallpaper) {
                    HStack(spacing: 8) {
                        if isSaving {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Image(systemName: "arrow.down.to.line.circle.fill")
                                .font(.system(size: 18))
                        }
                        Text(isSaving ? "Saving…" : "Save to Photos")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: 220)
                    .padding(.vertical, 14)
                    .background(Color(hex: "34D399"))
                    .clipShape(Capsule())
                }
                .disabled(isSaving)
                .opacity(isSaving ? 0.7 : 1)

                // ── Instruction ──
                Text("Save → Settings → Wallpaper → Choose from Photos")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.25))
                    .padding(.top, 12)

                Spacer()
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Save Wallpaper
    private func saveWallpaper() {
        isSaving = true

        // Render at iPhone 15 Pro resolution
        let renderer = ImageRenderer(
            content: WallpaperView()
                .frame(width: 1179, height: 2556)
        )
        renderer.scale = 1.0

        guard let image = renderer.uiImage else {
            showError("Failed to render wallpaper image.")
            return
        }

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    alertTitle = "Saved ✓"
                    alertMessage = "Wallpaper saved to your Photos. Go to Settings → Wallpaper to apply it."
                    showAlert = true
                    isSaving = false

                case .denied, .restricted:
                    showError("Photo library access denied. Please enable it in Settings → Privacy → Photos.")

                default:
                    showError("Unable to access Photo library.")
                }
            }
        }
    }

    private func showError(_ message: String) {
        alertTitle = "Error"
        alertMessage = message
        showAlert = true
        isSaving = false
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
