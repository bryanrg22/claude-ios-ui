#if canImport(UIKit)
    import SwiftUI

    struct ClaudeRoutinesView: View {
        @Binding var state: RoutineState
        let back: () -> Void
        let action: (RoutineAction) -> Void
        var body: some View {
            VStack(spacing: 0) {
                ZStack {
                    Text("Routines").font(.system(size: 17, weight: .semibold))
                    HStack {
                        Button(action: back) {
                            Image(systemName: "chevron.left").font(.system(size: 23, weight: .light)).frame(
                                width: 44, height: 44)
                        }.glassEffect(in: .circle).accessibilityLabel("Back").accessibilityIdentifier("routines.back")
                        Spacer()
                        Menu {
                            Picker(
                                "Filter routines",
                                selection: Binding(get: { state.filter }, set: { action(.selectFilter($0)) })
                            ) {
                                ForEach(RoutineFilter.allCases, id: \.self) { filter in
                                    Label {
                                        Text(filter.rawValue)
                                    } icon: {
                                        if filter == .all {
                                            CodeReferenceIcons.image(.checklist)
                                        } else {
                                            Image(systemName: filter == .active ? "play" : "pause")
                                        }
                                    }.tag(filter)
                                }
                            }.pickerStyle(.inline)
                        } label: {
                            Image(systemName: "slider.vertical.3").font(.system(size: 20, weight: .light)).frame(
                                width: 44, height: 44)
                        }.glassEffect(in: .circle).accessibilityLabel("Filter routines").accessibilityIdentifier(
                            "routines.filter")
                    }
                }.frame(height: 48).padding(.horizontal, 16).padding(.top, -2)
                GeometryReader { geo in
                    VStack(spacing: 18) {
                        Image(systemName: "clock").font(.system(size: 20, weight: .light)).frame(width: 48, height: 48)
                            .background(ClaudePalette.panel, in: .circle)
                        VStack(spacing: 4) {
                            Text("No routines yet").font(.system(size: 18))
                            Text("Routines run Claude on a schedule and will show up here").font(.system(size: 16))
                                .multilineTextAlignment(.center)
                        }
                    }.foregroundStyle(ClaudePalette.secondary).padding(.horizontal, 36).frame(maxWidth: .infinity)
                        .position(x: geo.size.width / 2, y: geo.size.height * 0.505)
                }
                HStack {
                    Spacer()
                    Button {
                        action(.newRoutine)
                    } label: {
                        Label("New routine", systemImage: "plus").font(.system(size: 16)).foregroundStyle(.black)
                            .padding(.horizontal, 17).frame(height: 44).background(.white, in: .capsule)
                    }.accessibilityIdentifier("routines.new")
                }.padding(.horizontal, 24)
            }.foregroundStyle(ClaudePalette.ink).background(ClaudePalette.codeBackground)
                .sheet(isPresented: Binding(get: { state.editor != nil }, set: { if !$0 { action(.cancel) } })) {
                    ClaudeRoutineEditorView(state: $state, action: action)
                }
        }
    }
    struct ClaudeRoutineEditorView: View {
        @Binding var state: RoutineState
        let action: (RoutineAction) -> Void
        var body: some View {
            VStack(spacing: 0) {
                SheetHeader(
                    title: "New routine", back: state.editor == .manual, controlDiameter: 44,
                    close: { action(state.editor == .manual ? .backToDescription : .cancel) })
                ScrollView {
                    if state.editor == .manual { manualForm } else { descriptionForm }
                }.scrollDismissesKeyboard(.interactively)
            }.background(ClaudePalette.background).foregroundStyle(ClaudePalette.ink).presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        private var descriptionForm: some View {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    fieldLabel("What do you want automated?")
                    editor(
                        field: .description,
                        placeholder: "e.g. Every weekday morning, review new PRs and post a summary")
                }
                Button {
                    action(.draftRoutine(state.description))
                } label: {
                    Label("Draft routine", systemImage: "bolt").font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.black).frame(maxWidth: .infinity).frame(height: 48).background(
                            .white.opacity(
                                state.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1),
                            in: .capsule)
                }.disabled(state.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityIdentifier("routine.draft")
                Button {
                    action(.manualSetup)
                } label: {
                    Text("Set up manually").font(.system(size: 18, weight: .semibold)).frame(maxWidth: .infinity).frame(
                        height: 48
                    ).overlay { Capsule().stroke(ClaudePalette.ink.opacity(0.12), lineWidth: 1) }
                }.accessibilityIdentifier("routine.manual")
            }.padding(.horizontal, 16).padding(.top, 20)
        }
        private var manualForm: some View {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    fieldLabel("Name")
                    TextField("Routine name", text: field(.name)).font(.system(size: 16)).padding(.horizontal, 16)
                        .frame(height: 48).background(ClaudePalette.panel, in: .capsule).overlay {
                            Capsule().stroke(ClaudePalette.ink.opacity(0.12), lineWidth: 0.5)
                        }.accessibilityIdentifier("routine.name")
                }
                VStack(alignment: .leading, spacing: 12) {
                    fieldLabel("Instructions")
                    editor(field: .instructions, placeholder: "What should Claude do each time this runs?")
                }.padding(.top, 10)
                RowGroup {
                    ForEach([RoutineOption.environment, .repository, .model, .connectors], id: \.self) { option in
                        Button {
                            action(.openOption(option))
                        } label: {
                            HStack(spacing: 12) {
                                option.icon.resizable().scaledToFit().frame(width: 23, height: 23).foregroundStyle(
                                    Color(white: 0.72))
                                Text(option.rawValue).font(.system(size: 17))
                                Spacer()
                                Text(value(option)).font(.system(size: 16)).foregroundStyle(ClaudePalette.secondary)
                                    .lineLimit(1)
                                Image(systemName: "chevron.right").font(.system(size: 15)).foregroundStyle(
                                    ClaudePalette.secondary)
                            }.padding(.horizontal, 16).padding(.vertical, 14)
                        }.buttonStyle(.plain).accessibilityIdentifier("routine.option.\(option.rawValue)")
                        RowDivider()
                    }
                    Button {
                        action(.openOption(.notifications))
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "bell").font(.system(size: 20, weight: .light)).frame(width: 23)
                            Text("Notifications").font(.system(size: 17))
                            Spacer()
                            Text(state.draft.notifications).font(.system(size: 16)).foregroundStyle(
                                ClaudePalette.secondary)
                            Image(systemName: "chevron.down").font(.system(size: 15)).foregroundStyle(
                                ClaudePalette.secondary)
                        }.padding(.horizontal, 16).padding(.vertical, 14)
                    }.buttonStyle(.plain).accessibilityIdentifier("routine.option.Notifications")
                }
                fieldLabel("Trigger").padding(.top, 12)
                if let schedule = state.draft.schedule {
                    scheduleGroup(schedule)
                } else {
                    RowGroup {
                        SheetRow(
                            title: "Schedule", detail: "Run on a recurring cron schedule or once at a future time",
                            chevron: true
                        ) { action(.addSchedule) }.accessibilityIdentifier("routine.option.Schedule")
                        RowDivider()
                        SheetRow(title: "GitHub event", detail: "Run when a GitHub webhook event fires", chevron: true)
                        { action(.openOption(.githubEvent)) }.accessibilityIdentifier("routine.option.GitHub event")
                    }
                }
                Button {
                    action(.create(state.draft))
                } label: {
                    Text("Create").font(.system(size: 18, weight: .semibold)).foregroundStyle(.black).frame(
                        maxWidth: .infinity
                    ).frame(height: 48).background(.white.opacity(state.canCreate ? 1 : 0.55), in: .capsule)
                }.disabled(!state.canCreate).accessibilityIdentifier("routine.create")
            }.padding(.horizontal, 16).padding(.top, 30).padding(.bottom, 20)
        }
        private func scheduleGroup(_ schedule: RoutineSchedule) -> some View {
            RowGroup {
                HStack {
                    Button {
                        action(.toggleSchedule)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "clock")
                            Text(
                                "\(schedule.repeats.rawValue) at \(scheduleDate(schedule).formatted(date: .omitted, time: .shortened))"
                            ).font(.system(size: 17))
                            Spacer()
                            Image(systemName: state.scheduleExpanded ? "chevron.up" : "chevron.down").font(
                                .system(size: 14))
                        }
                    }.buttonStyle(.plain).accessibilityIdentifier("routine.schedule.expand")
                    Button {
                        action(.removeSchedule)
                    } label: {
                        Image(systemName: "xmark").font(.system(size: 14)).frame(width: 36, height: 44)
                    }.buttonStyle(.plain).accessibilityLabel("Remove schedule").accessibilityIdentifier(
                        "routine.schedule.remove")
                }.padding(.leading, 16).padding(.trailing, 8).frame(height: 72)
                if state.scheduleExpanded {
                    RowDivider()
                    HStack {
                        Text("Repeats").font(.system(size: 17))
                        Spacer()
                        Menu {
                            Picker(
                                "Repeats",
                                selection: Binding(get: { schedule.repeats }, set: { action(.setRepeat($0)) })
                            ) { ForEach(RoutineRepeat.allCases, id: \.self) { Text($0.rawValue).tag($0) } }
                        } label: {
                            HStack(spacing: 5) {
                                Text(schedule.repeats.rawValue)
                                Image(systemName: "chevron.up.chevron.down").font(.system(size: 11))
                            }.font(.system(size: 16)).foregroundStyle(ClaudePalette.secondary)
                        }.accessibilityIdentifier("routine.schedule.repeat")
                    }.padding(.horizontal, 16).frame(height: 72)
                    RowDivider()
                    DatePicker(
                        "Time",
                        selection: Binding(
                            get: { scheduleDate(schedule) },
                            set: {
                                let parts = Calendar.current.dateComponents([.hour, .minute], from: $0)
                                action(.setTime(hour: parts.hour ?? 1, minute: parts.minute ?? 0))
                            }), displayedComponents: .hourAndMinute
                    ).font(.system(size: 17)).tint(ClaudePalette.ink).padding(.horizontal, 16).frame(height: 66)
                        .accessibilityIdentifier("routine.schedule.time")
                }
            }
        }
        private func scheduleDate(_ schedule: RoutineSchedule) -> Date {
            Calendar.current.date(
                from: DateComponents(year: 2001, month: 1, day: 1, hour: schedule.hour, minute: schedule.minute))
                ?? .distantPast
        }
        private func fieldLabel(_ title: String) -> some View {
            Text(title).font(.system(size: 16)).foregroundStyle(ClaudePalette.secondary).padding(.horizontal, 16)
        }
        private func field(_ field: RoutineField) -> Binding<String> {
            Binding(
                get: {
                    switch field {
                    case .description: state.description
                    case .name: state.draft.name
                    case .instructions: state.draft.instructions
                    }
                }, set: { action(.edit(field, $0)) })
        }
        private func editor(field: RoutineField, placeholder: String) -> some View {
            ZStack(alignment: .topLeading) {
                if self.field(field).wrappedValue.isEmpty {
                    Text(placeholder).foregroundStyle(ClaudePalette.secondary).padding(16).allowsHitTesting(false)
                }
                TextEditor(text: self.field(field)).scrollContentBackground(.hidden).padding(10)
                    .accessibilityIdentifier("routine.\(field == .description ? "description" : "instructions")")
            }.font(.system(size: 16)).frame(height: 138).background(ClaudePalette.panel, in: .rect(cornerRadius: 28))
                .overlay { RoundedRectangle(cornerRadius: 28).stroke(ClaudePalette.ink.opacity(0.08), lineWidth: 0.5) }
        }
        private func value(_ option: RoutineOption) -> String {
            switch option {
            case .environment: state.draft.environment
            case .repository: state.draft.repository
            case .model: state.draft.model
            case .connectors: state.draft.connectors
            case .notifications: state.draft.notifications
            case .schedule, .githubEvent: ""
            }
        }
    }
    private extension RoutineOption {
        @MainActor var icon: Image {
            switch self {
            case .repository: CodeReferenceIcons.image(.branch)
            case .model: CodeReferenceIcons.image(.model)
            case .connectors: CodeReferenceIcons.image(.connectors)
            default: Image(systemName: symbol)
            }
        }
        var symbol: String {
            switch self {
            case .environment: "cloud"
            case .repository: "point.3.connected.trianglepath.dotted"
            case .model: "atom"
            case .connectors: "square.grid.2x2"
            case .notifications: "bell"
            case .schedule: "clock"
            case .githubEvent: "point.3.connected.trianglepath.dotted"
            }
        }
    }
#endif
