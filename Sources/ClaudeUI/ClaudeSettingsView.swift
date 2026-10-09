#if canImport(UIKit)
    import SwiftUI

    /// Settings presentation backed by host-owned state. Uncaptured destinations may be supplied by the host.
    public struct ClaudeSettingsView: View {
        @Binding private var state: ClaudeSettingsState
        public var appearance: ClaudeAppearance
        private var destinationContent: ((ClaudeSettingsDestination) -> AnyView?)?
        private let action: (ClaudeSettingsAction) -> Void
        @Environment(\.dismiss) private var dismiss
        public init(
            state: Binding<ClaudeSettingsState>, appearance: ClaudeAppearance,
            destinationContent: ((ClaudeSettingsDestination) -> AnyView?)? = nil,
            action: @escaping (ClaudeSettingsAction) -> Void
        ) {
            _state = state
            self.appearance = appearance
            self.destinationContent = destinationContent
            self.action = action
        }
        public var body: some View {
            VStack(spacing: 0) {
                header
                if let destination = state.destination, let content = destinationContent?(destination) {
                    content
                } else if state.destination == .profile {
                    profile
                } else if state.destination == .notifications {
                    ClaudeNotificationSettingsView(preferences: state.notifications, action: action)
                } else if state.destination == .billing {
                    ClaudeBillingSettingsView(state: state.billing) { action(.billing($0)) }
                } else if state.destination == .sharedLinks {
                    ClaudeSharedLinksView(state: state.sharedLinks) { action(.sharedLinks($0)) }
                } else if state.destination == .connectors {
                    ClaudeSettingsConnectorsView(state: state.connectors) { action(.connector($0)) }
                } else if state.destination == .capabilities {
                    ClaudeCapabilitiesView(state: state.capabilities) { action(.capability($0)) }
                } else if state.destination == .memoryFiles {
                    ClaudeMemoryFilesView(state: state.memoryFiles) { action(.memory($0)) }
                } else if state.destination == .code {
                    ClaudeCodeSettingsView(state: state.codePreferences) { action(.codePreference($0)) }
                } else if state.destination == .usage {
                    ClaudeUsageSettingsView(state: state.usage) { action(.usage($0)) }
                } else if state.destination == .privacy {
                    ClaudePrivacySettingsView(state: state.privacy) { action(.privacy($0)) }
                } else if state.destination == .timeAndFocus {
                    ClaudeTimeFocusView(state: state.timeFocus) { action(.timeFocus($0)) }
                } else if let destination = state.destination {
                    Spacer()
                    Text(destination.rawValue).font(.title2)
                    Spacer()
                } else {
                    root
                }
            }.background(ClaudePalette.background).foregroundStyle(ClaudePalette.ink).tint(ClaudePalette.ink)
                .environment(\.symbolVariants, .none)
                .preferredColorScheme(appearance == .system ? nil : appearance == .dark ? .dark : .light)
                .presentationDetents([.large]).presentationCornerRadius(40).presentationDragIndicator(.hidden)
                .onDisappear { action(.close) }
                .sheet(
                    item: Binding(
                        get: { state.connectors.presentation },
                        set: { if $0 == nil { action(.connector(.catalog(.dismiss))) } })
                ) { presentation in
                    ClaudeConnectorCatalogView(state: state.connectors.catalog, presentation: presentation) {
                        action(.connector(.catalog($0)))
                    }.presentationDetents([.large]).presentationCornerRadius(40).presentationDragIndicator(.hidden)
                }
                .sheet(
                    isPresented: Binding(
                        get: { state.instructionsDraft != nil }, set: { if !$0 { action(.cancelInstructions) } })
                ) { instructionsEditor }
        }
        private var header: some View {
            ZStack {
                if state.destination == .sharedLinks, let snapshot = state.sharedLinks.selected {
                    VStack(spacing: 3) {
                        Text(snapshot.title).font(.system(size: 15, weight: .semibold)).lineLimit(1)
                        Text(snapshot.byline).font(.system(size: 13.3)).foregroundStyle(ClaudePalette.secondary)
                            .lineLimit(1)
                    }.padding(.horizontal, 60)
                } else if state.destination == .connectors {
                    Text(
                        state.connectors.showingAllTools
                            ? "All tools"
                            : (state.connectors.tool?.name ?? state.connectors.connector?.name ?? "Connectors")
                    ).font(.system(size: 17, weight: .semibold)).lineLimit(1).padding(.horizontal, 54)
                } else {
                    Text(
                        state.destination == .memoryFiles
                            ? (state.memoryFiles.selected?.title ?? "Memory files")
                            : (state.destination?.rawValue ?? "Settings")
                    ).font(.system(size: 17, weight: .semibold))
                }
                HStack {
                    Button {
                        if state.destination == nil {
                            action(.close)
                            dismiss()
                        } else if state.destination == .connectors {
                            action(.connector(.back))
                        } else if state.destination == .memoryFiles {
                            action(.memory(.back))
                        } else if state.destination == .sharedLinks && state.sharedLinks.selected != nil {
                            action(.sharedLinks(.back))
                        } else {
                            action(.back)
                        }
                    } label: {
                        Image(systemName: state.destination == nil ? "xmark" : "chevron.left").font(
                            .system(size: 21, weight: .light)
                        ).frame(width: 44, height: 44)
                    }.glassEffect(in: .circle).accessibilityLabel(state.destination == nil ? "Close settings" : "Back")
                        .accessibilityIdentifier("settings.back")
                    Spacer()
                    if state.destination == .connectors, state.connectors.connector == nil {
                        Menu {
                            Button {
                                action(.connector(.openCatalog))
                            } label: {
                                Label("Browse connectors", systemImage: "square.grid.2x2")
                            }
                            Button {
                                action(.connector(.openCustom))
                            } label: {
                                Label("Add custom connector", systemImage: "square.grid.2x2")
                            }
                        } label: {
                            Image(systemName: "plus").font(.system(size: 21, weight: .light)).frame(
                                width: 44, height: 44)
                        }.glassEffect(in: .circle).accessibilityLabel("Add connector").accessibilityIdentifier(
                            "settings.connectors.add")
                    } else if state.destination == .memoryFiles, state.memoryFiles.selected != nil {
                        Button {
                            action(.memory(.askDelete))
                        } label: {
                            Image(systemName: "trash").font(.system(size: 21, weight: .light)).frame(
                                width: 44, height: 44)
                        }.glassEffect(in: .circle).disabled(state.memoryFiles.pendingDeletion != nil)
                            .accessibilityLabel("Delete memory file").accessibilityIdentifier("settings.memory.delete")
                    } else if state.destination == .profile {
                        Button {
                            action(.submitProfile)
                        } label: {
                            Image(systemName: "checkmark").font(.system(size: 20)).frame(width: 44, height: 44)
                        }.glassEffect(.regular.tint(.white.opacity(0.35)), in: .circle).disabled(
                            state.pendingProfile != nil
                        ).accessibilityLabel("Save profile").accessibilityIdentifier("settings.profile.save")
                    } else if state.destination == .usage {
                        HStack(spacing: 0) {
                            Button {
                                action(.usage(.refresh))
                            } label: {
                                Image(systemName: "arrow.clockwise").font(.system(size: 21, weight: .light)).frame(
                                    width: 50, height: 44)
                            }.accessibilityLabel("Refresh usage").accessibilityIdentifier("settings.usage.refresh")
                            Button {
                                action(.usage(.openLink(.usageHelp, state.usage.usageHelpURL)))
                            } label: {
                                Image(systemName: "info").font(.system(size: 21)).frame(width: 50, height: 44)
                            }.accessibilityLabel("Usage information").accessibilityIdentifier("settings.usage.info")
                        }.glassEffect(in: .capsule)
                    } else if state.destination == nil {
                        Menu {
                            if !state.versionLabel.isEmpty {
                                Text(state.versionLabel)
                                Divider()
                            }
                            ForEach(ClaudeSettingsInfoLink.allCases, id: \.self) { link in
                                if link == .support { Divider() }
                                Button {
                                    action(.infoLink(link))
                                } label: {
                                    Label(
                                        link.rawValue,
                                        systemImage: link == .licenses ? "doc.text" : "arrow.up.right.square")
                                }
                            }
                        } label: {
                            Image(systemName: "info").font(.system(size: 21)).frame(width: 44, height: 44)
                        }.glassEffect(in: .circle).accessibilityLabel("About").accessibilityIdentifier("settings.about")
                    }
                }
            }.frame(height: 44).padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 0)
        }
        private var root: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    RowGroup {
                        Button {
                            action(.open(.account))
                        } label: {
                            HStack(spacing: 10) {
                                Text(state.profile.initials).font(.system(size: 13, weight: .semibold)).frame(
                                    width: 40, height: 40
                                ).background(ClaudePalette.codeBackground, in: .circle)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(state.account.email).font(.system(size: 17)).lineLimit(1)
                                    Label(state.account.accountLabel, systemImage: "person").font(.system(size: 15))
                                        .foregroundStyle(ClaudePalette.secondary)
                                }.frame(maxWidth: .infinity, alignment: .leading)
                                Image(systemName: "chevron.right").font(.system(size: 15)).foregroundStyle(
                                    ClaudePalette.secondary)
                            }.padding(.horizontal, 16).frame(height: 70).contentShape(Rectangle())
                        }.buttonStyle(.plain).accessibilityIdentifier("settings.account")
                        Divider().padding(.leading, 64).padding(.trailing, 16)
                        settingsRow(.addAccount, symbol: "plus", tint: .blue, chevron: false)
                    }
                    RowGroup { settingsRow(.gift, symbol: "gift", tint: .blue, chevron: false) }
                    sectionLabel("Account")
                    RowGroup {
                        settingsRow(.profile, symbol: "person.crop.circle")
                        rowDivider
                        settingsRow(.billing, symbol: "dollarsign.circle", value: state.account.planLabel)
                        rowDivider
                        settingsRow(.usage, symbol: "chart.xyaxis.line")
                        rowDivider
                        settingsRow(.notifications, symbol: "bell")
                        rowDivider
                        settingsRow(.timeAndFocus, symbol: "moon.stars")
                        rowDivider
                        settingsRow(.privacy, symbol: "lock.shield")
                        rowDivider
                        settingsRow(.sharedLinks, symbol: "link")
                    }
                    sectionLabel("App")
                    RowGroup {
                        settingsRow(.capabilities, symbol: "slider.horizontal.3")
                        rowDivider
                        settingsRow(.code, symbol: "chevron.left.forwardslash.chevron.right")
                        rowDivider
                        settingsRow(.connectors, symbol: "square.grid.2x2")
                        rowDivider
                        settingsRow(.permissions, symbol: "switch.2")
                        rowDivider
                        settingsRow(.voice, symbol: "waveform")
                        rowDivider
                        Toggle(isOn: Binding(get: { state.hapticsEnabled }, set: { action(.setHaptics($0)) })) {
                            Label("Haptic feedback", systemImage: "iphone.gen3.radiowaves.left.and.right").font(
                                .system(size: 17))
                        }.tint(.blue).padding(.horizontal, 16).frame(height: 52).accessibilityIdentifier(
                            "settings.haptics")
                    }
                    sectionLabel("Appearance")
                    HStack(spacing: 10) {
                        ForEach([ClaudeAppearance.light, .dark, .system], id: \.self) { choice in
                            Button {
                                action(.setAppearance(choice))
                            } label: {
                                VStack(spacing: 9) {
                                    ThemeThumbnail(appearance: choice).frame(height: 68).overlay {
                                        RoundedRectangle(cornerRadius: 14).stroke(
                                            appearance == choice ? Color.blue : .clear, lineWidth: 2)
                                    }
                                    Text(choice.rawValue).font(.system(size: 14)).foregroundStyle(
                                        appearance == choice ? .blue : ClaudePalette.secondary)
                                }
                            }.buttonStyle(.plain).accessibilityLabel("\(choice.rawValue) appearance")
                                .accessibilityAddTraits(appearance == choice ? [.isSelected] : [])
                                .accessibilityIdentifier("settings.appearance." + choice.rawValue)
                        }
                    }.padding(16).background(ClaudePalette.panel, in: .rect(cornerRadius: 28))
                    RowGroup {
                        Button {
                            action(.requestLogOut)
                        } label: {
                            Label("Log out", systemImage: "rectangle.portrait.and.arrow.right").font(.system(size: 17))
                                .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 16).frame(
                                    height: 52)
                        }.buttonStyle(.plain).foregroundStyle(destructiveColor).accessibilityIdentifier(
                            "settings.logout")
                    }
                }.padding(.horizontal, 16).padding(.top, 26).padding(.bottom, 20)
            }.accessibilityIdentifier("settings.root.scroll")
        }
        private var profile: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(spacing: 8) {
                        Text(state.profileDraft?.initials ?? state.profile.initials).font(
                            .system(size: 32, weight: .semibold)
                        ).frame(width: 96, height: 96).background(ClaudePalette.codeBackground, in: .circle)
                        Menu {
                            Button {
                                action(.chooseAvatar)
                            } label: {
                                Label("Choose an avatar", systemImage: "face.smiling")
                            }
                            Button {
                                action(.requestPhotoLibrary)
                            } label: {
                                Label("View photo library", systemImage: "photo")
                            }
                            Button {
                                action(.requestCamera)
                            } label: {
                                Label("Take a photo", systemImage: "camera")
                            }
                        } label: {
                            Text("Edit photo").font(.system(size: 15, weight: .semibold)).padding(.horizontal, 12)
                                .frame(height: 32).overlay {
                                    Capsule().stroke(ClaudePalette.ink.opacity(0.12), lineWidth: 1)
                                }
                        }.buttonStyle(.plain).accessibilityIdentifier("settings.profile.photo")
                    }.frame(maxWidth: .infinity).padding(.top, 26).padding(.bottom, 16)
                    RowGroup {
                        profileField("Full name", field: .fullName)
                        RowDivider()
                        profileField("Nickname", field: .nickname)
                    }
                    Text("Claude calls you by your nickname.").font(.system(size: 14)).foregroundStyle(
                        ClaudePalette.secondary
                    ).padding(.horizontal, 16).padding(.top, 8)
                    Text("Instructions").font(.system(size: 15)).foregroundStyle(ClaudePalette.secondary).padding(
                        .horizontal, 16
                    ).padding(.top, 32).padding(.bottom, 10)
                    Button {
                        action(.openInstructions)
                    } label: {
                        Text(
                            state.profileDraft?.instructions.isEmpty == false
                                ? state.profileDraft!.instructions : "How you’d like Claude to respond"
                        ).lineLimit(1).foregroundStyle(
                            state.profileDraft?.instructions.isEmpty == false
                                ? ClaudePalette.ink : ClaudePalette.secondary
                        ).font(.system(size: 17)).frame(maxWidth: .infinity, alignment: .leading).padding(
                            .horizontal, 16
                        ).frame(height: 52).background(ClaudePalette.panel, in: .capsule).contentShape(Capsule())
                    }.buttonStyle(.plain).accessibilityIdentifier("settings.profile.instructions")
                    Text(
                        "Your instructions will apply to all conversations, within [Anthropic’s guidelines](claude-settings://guidelines)."
                    ).font(.system(size: 14)).foregroundStyle(ClaudePalette.secondary).tint(.blue).padding(
                        .horizontal, 16
                    ).padding(.top, 8).environment(
                        \.openURL,
                        OpenURLAction { _ in
                            action(.openGuidelines)
                            return .handled
                        })
                    RowGroup {
                        Button {
                            action(.requestDeleteAccount)
                        } label: {
                            Label("Delete account", systemImage: "trash").font(.system(size: 17)).frame(
                                maxWidth: .infinity, alignment: .leading
                            ).padding(.horizontal, 16).frame(height: 52)
                        }.buttonStyle(.plain).foregroundStyle(destructiveColor).accessibilityIdentifier(
                            "settings.profile.delete")
                    }.padding(.top, 24)
                }.padding(.horizontal, 16).padding(.bottom, 24)
            }.scrollDismissesKeyboard(.interactively).accessibilityIdentifier("settings.profile.scroll")
        }
        private func profileField(_ title: String, field: ClaudeProfileField) -> some View {
            HStack(spacing: 0) {
                Text(title).foregroundStyle(ClaudePalette.secondary).frame(width: 98, alignment: .leading)
                ClaudeProfileTextField(
                    text: field == .fullName ? state.profileDraft?.fullName ?? "" : state.profileDraft?.nickname ?? "",
                    placeholder: title, identifier: "settings.profile." + (field == .fullName ? "fullName" : "nickname")
                ) { action(.editProfile(field, $0)) }
            }.font(.system(size: 17)).padding(.horizontal, 16).frame(height: 52)
        }
        private var instructionsEditor: some View {
            VStack(spacing: 14) {
                ZStack {
                    Text("Instructions").font(.system(size: 17, weight: .semibold))
                    HStack {
                        Button {
                            action(.cancelInstructions)
                        } label: {
                            Image(systemName: "xmark").font(.system(size: 21, weight: .light)).frame(
                                width: 44, height: 44)
                        }.glassEffect(in: .circle).accessibilityLabel("Cancel instructions").accessibilityIdentifier(
                            "settings.instructions.cancel")
                        Spacer()
                        Button {
                            action(.applyInstructions)
                        } label: {
                            Image(systemName: "checkmark").font(.system(size: 20)).frame(width: 44, height: 44)
                        }.glassEffect(.regular.tint(.white.opacity(0.35)), in: .circle).accessibilityLabel(
                            "Apply instructions"
                        ).accessibilityIdentifier("settings.instructions.apply")
                    }
                }.frame(height: 44).padding(.horizontal, 16).padding(.top, 16)
                ZStack(alignment: .topLeading) {
                    if state.instructionsDraft?.isEmpty != false {
                        Text("When learning new concepts, I find analogies particularly helpful.").foregroundStyle(
                            ClaudePalette.secondary
                        ).padding(.horizontal, 5).padding(.top, 8).allowsHitTesting(false)
                    }
                    TextEditor(
                        text: Binding(get: { state.instructionsDraft ?? "" }, set: { action(.editInstructions($0)) })
                    ).scrollContentBackground(.hidden).accessibilityIdentifier("settings.instructions.editor")
                }.font(.system(size: 18)).padding(.horizontal, 16)
            }.background(ClaudePalette.background).foregroundStyle(ClaudePalette.ink).tint(ClaudePalette.ink)
                .presentationDetents([.large]).presentationCornerRadius(40).presentationDragIndicator(.hidden)
        }
        private var destructiveColor: Color { Color(red: 0.86, green: 0.59, blue: 0.59) }
        private var rowDivider: some View { Divider().padding(.leading, 56).padding(.trailing, 16) }
        private func sectionLabel(_ title: String) -> some View {
            Text(title).font(.system(size: 15)).foregroundStyle(ClaudePalette.secondary).padding(.leading, 16).padding(
                .top, 8
            ).padding(.bottom, -8)
        }
        private func settingsRow(
            _ destination: ClaudeSettingsDestination, symbol: String, value: String = "", tint: Color? = nil,
            chevron: Bool = true
        ) -> some View {
            Button {
                action(.open(destination))
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: symbol).font(.system(size: 20, weight: .light)).frame(width: 26).foregroundStyle(
                        tint ?? ClaudePalette.ink.opacity(0.75))
                    Text(destination.rawValue).frame(maxWidth: .infinity, alignment: .leading)
                    if !value.isEmpty { Text(value).foregroundStyle(ClaudePalette.secondary) }
                    if chevron {
                        Image(systemName: "chevron.right").font(.system(size: 15)).foregroundStyle(
                            ClaudePalette.secondary)
                    }
                }.font(.system(size: 17)).foregroundStyle(tint ?? ClaudePalette.ink).padding(.horizontal, 16).frame(
                    height: 51
                ).contentShape(Rectangle())
            }.buttonStyle(.plain).accessibilityIdentifier("settings.route." + destination.rawValue)
        }
    }
#endif
