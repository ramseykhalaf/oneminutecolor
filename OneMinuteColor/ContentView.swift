import SwiftUI

private struct CarouselStep: Identifiable {
    let id: Int
    let image: String
    let caption: LocalizedStringKey
}

private let carouselSteps: [CarouselStep] = [
    CarouselStep(id: 0, image: "Step-LongPress", caption: "carousel_longpress"),
    CarouselStep(id: 1, image: "Step-AddControl", caption: "carousel_addcontrol"),
    CarouselStep(id: 2, image: "Step-SearchShortcuts", caption: "carousel_search"),
    CarouselStep(id: 3, image: "Step-FindShortcut", caption: "carousel_find"),
]

struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("primaryButtonMode") private var storedPrimaryButtonMode = "install"

    private let actionHandler = ButtonActionHandler(configuration: .appDefault)
    @State private var pendingInstallReturn = false
    @State private var statusMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Text("app_title")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.top, 48)

                stepSection(number: 1, title: String(localized: "step_install")) {
                    Button(action: openInstallShortcut) {
                        Text("install_button")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity, minHeight: 56)
                    }
                    .buttonStyle(.borderedProminent)
                }

                stepSection(number: 2, title: String(localized: "step_control_center")) {
                    TabView {
                        ForEach(carouselSteps) { step in
                            VStack(spacing: 12) {
                                Image(step.image)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 16))

                                Text(step.caption)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 32)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .frame(height: 340)
                }

                Divider()
                    .padding(.horizontal, 24)

                Button(action: runShortcut) {
                    Label("run_button", systemImage: "play.fill")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.bordered)

                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer(minLength: 32)
            }
            .padding(.horizontal, 24)
        }
        .onOpenURL(perform: handleIncomingURL)
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active, pendingInstallReturn else { return }
            pendingInstallReturn = false
            storedPrimaryButtonMode = "run"
            statusMessage = String(localized: "status_installed")
        }
    }

    // MARK: - Helpers

    private func stepSection<Content: View>(
        number: Int,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(number). \(title)")
                .font(.title2.weight(.bold))
            content()
        }
    }

    // MARK: - Actions

    private func openInstallShortcut() {
        pendingInstallReturn = true
        _ = actionHandler.installShortcutButtonTapped { url in
            openURL(url)
        }
        statusMessage = String(localized: "status_install_prompt")
    }

    private func runShortcut() {
        let url = actionHandler.startOneMinuteColorButtonTappedWithCallback { destination in
            openURL(destination)
        }

        if url == nil {
            storedPrimaryButtonMode = "install"
            statusMessage = String(localized: "status_could_not_start")
        } else {
            statusMessage = String(localized: "status_running")
        }
    }

    private func handleIncomingURL(_ url: URL) {
        let expectedScheme = ShortcutConfiguration.appDefault.callbackURLScheme.lowercased()
        guard url.scheme?.lowercased() == expectedScheme,
              url.host?.lowercased() == "shortcut" else {
            return
        }

        let event = url.pathComponents.dropFirst().first?.lowercased()
        switch event {
        case "success":
            storedPrimaryButtonMode = "run"
            statusMessage = String(localized: "status_ready")
        case "cancel":
            statusMessage = String(localized: "status_canceled")
        case "error":
            storedPrimaryButtonMode = "install"
            statusMessage = String(localized: "status_not_available")
        default:
            break
        }
    }
}
