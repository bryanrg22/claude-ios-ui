#if canImport(UIKit)
    import SwiftUI

    /// The captured feature announcement, independent of authentication or a backend.
    /// Supply the measured illustration as `hero`; the default is only the observed still.
    public struct ClaudeWorkAnnouncementView<Hero: View>: View {
        private let hero: Hero
        private let typography: ClaudeTypography
        private let onDismiss: () -> Void

        public init(
            typography: ClaudeTypography = .init(), onDismiss: @escaping () -> Void, @ViewBuilder hero: () -> Hero
        ) {
            self.typography = typography
            self.onDismiss = onDismiss
            self.hero = hero()
            ClaudeFontResources.register()
        }

        public var body: some View {
            VStack(spacing: 0) {
                hero
                    .frame(maxWidth: .infinity)
                    // Measured 588 px at 2x in the 393 x 852 pt phone capture.
                    .frame(height: 294)
                    .background(Color(red: 57 / 255, green: 105 / 255, blue: 187 / 255))
                    .clipped()
                    .overlay(alignment: .topLeading) {
                        Button(action: onDismiss) {
                            Image(systemName: "xmark").font(.system(size: 23, weight: .light))
                                .frame(width: 44, height: 44)
                        }
                        .glassEffect(.regular, in: .circle)
                        .padding(16)
                        .accessibilityLabel("Close work announcement")
                        .accessibilityIdentifier("announcement.close")
                    }
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("New").font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color(red: 0.79, green: 0.42, blue: 0.32))
                            .padding(.horizontal, 9).padding(.vertical, 5)
                            .background(Color(red: 0.21, green: 0.16, blue: 0.14), in: Capsule())
                        Text("One Claude for your work")
                            .font(.custom(typography.serifName, size: 30, relativeTo: .largeTitle))
                            .padding(.top, 16)
                            .accessibilityAddTraits(.isHeader)
                        Text(
                            "Cowork and chat have merged. Ask anything and Claude will choose the best way to get it done."
                        )
                        .font(.system(size: 16)).lineSpacing(3).padding(.top, 23)
                        VStack(alignment: .leading, spacing: 16) {
                            feature(
                                "Ask a quick question or hand off a task to finish in the background",
                                symbol: "bubble.left", waveform: true)
                            feature("Set a task to repeat, like a Monday summary", symbol: "clock")
                            feature(
                                "Try more artifact types, like slides, designs, and docs",
                                symbol: "rectangle.on.rectangle")
                        }.padding(.top, 24)
                    }.padding(.horizontal, 24).padding(.top, 24).padding(.bottom, 16)
                }.scrollIndicators(.hidden)
                Button(action: onDismiss) {
                    Text("Got it").font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity).frame(height: 48)
                        .foregroundStyle(Color.black)
                        .background(Color(red: 249 / 255, green: 249 / 255, blue: 247 / 255), in: Capsule())
                }.padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 16)
                    .accessibilityIdentifier("announcement.dismiss")
            }
            // Sampled from the source content background, rather than a system material.
            .background(Color(white: 32 / 255))
            .foregroundStyle(Color(white: 0.96))
            .buttonStyle(.plain)
            .preferredColorScheme(.dark)
        }

        private func feature(_ text: String, symbol: String, waveform: Bool = false) -> some View {
            HStack(alignment: .top, spacing: 18) {
                Image(systemName: symbol).font(.system(size: 18)).frame(width: 22, height: 22)
                    .overlay {
                        if waveform { Image(systemName: "waveform").font(.system(size: 8)).offset(y: -1) }
                    }
                    .accessibilityHidden(true)
                Text(text).font(.system(size: 18)).lineSpacing(3).fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    /// Observed Chat/Cowork frame. No animation duration or path is implied by this still.
    public struct ClaudeWorkAnnouncementStill: View {
        public init() {}
        public var body: some View {
            HStack(spacing: 50) {
                label("Chat")
                label("Cowork")
            }.frame(maxWidth: .infinity, maxHeight: .infinity).accessibilityHidden(true)
        }
        private func label(_ text: String) -> some View {
            Text(text).font(.system(size: 23)).foregroundStyle(.black)
                .padding(.horizontal, 16).frame(height: 38)
                .background(Color(red: 0.94, green: 0.93, blue: 0.90), in: .rect(cornerRadius: 12))
                .overlay { RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.19), lineWidth: 3) }
        }
    }
#endif
