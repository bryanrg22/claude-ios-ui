import XCTest
final class ClaudeDemoUITests: XCTestCase {
    @MainActor private func capture(_ name: String) {
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = name
        shot.lifetime = .keepAlways
        add(shot)
    }
    @MainActor func testDraftChangesVoiceToSendThenStreamingStopAndCompletion() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["composer.voice"].waitForExistence(timeout: 5))
        let draft = app.textFields["composer.draft"]
        draft.tap()
        draft.typeText("Hello")
        XCTAssertTrue(app.buttons["composer.send"].exists)
        app.buttons["composer.send"].tap()
        XCTAssertTrue(app.buttons["composer.stop"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["composer.voice"].waitForExistence(timeout: 6))
        XCTAssertTrue(app.staticTexts["Claude is AI and can make mistakes."].exists)
    }
    @MainActor func testDictationCancelPreservesDraft() {
        let app = XCUIApplication()
        app.launchArguments = ["--typed"]
        app.launch()
        app.buttons["composer.dictate"].tap()
        XCTAssertTrue(app.buttons["dictation.cancel"].waitForExistence(timeout: 2))
        app.buttons["dictation.stop"].tap()
        XCTAssertTrue(app.buttons["composer.dictate"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["dictation.cancel"].exists)
        XCTAssertEqual(app.textFields["composer.draft"].value as? String, "Reply with a short greeting.")
        app.buttons["composer.dictate"].tap()
        app.buttons["dictation.cancel"].tap()
        XCTAssertEqual(app.textFields["composer.draft"].value as? String, "Reply with a short greeting.")
    }
    @MainActor func testModelSelectionChangesComposer() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["composer.model"].tap()
        capture("models-dark")
        app.buttons["model.Haiku 5.5"].tap()
        XCTAssertTrue(app.buttons["composer.model"].label.contains("Haiku 5.5"))
    }

    @MainActor func testAttachmentPermissionAndEffortDrillIns() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["composer.attach"].tap()
        XCTAssertTrue(app.staticTexts["Add to session"].waitForExistence(timeout: 3))
        capture("attachments-dark")
        app.buttons.containing(.staticText, identifier: "Permission").firstMatch.tap()
        app.buttons.containing(.staticText, identifier: "Automatically approve").firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Automatic"].exists)
        app.buttons["Close"].tap()
        app.buttons["composer.model"].tap()
        app.buttons["model.effort"].tap()
        capture("effort-dark")
        app.buttons["effort.Low"].tap()
        app.buttons["Close"].tap()
        XCTAssertTrue(app.buttons["composer.model"].label.contains("Low"))
    }
    @MainActor func testFeedbackCancellationLeavesResponseUnrated() {
        let app = XCUIApplication()
        app.launchArguments = ["--complete"]
        app.launch()
        app.buttons["Good response"].tap()
        XCTAssertTrue(app.staticTexts["Feedback"].waitForExistence(timeout: 2))
        app.buttons["Close"].tap()
        app.buttons["Bad response"].tap()
        XCTAssertTrue(app.staticTexts["Type of issue"].waitForExistence(timeout: 2))
        app.buttons["Close"].tap()
        XCTAssertTrue(app.buttons["Good response"].exists)
    }

    @MainActor func testCameraControlsCancelPreservesDraftAndPhotoAttaches() {
        let app = XCUIApplication()
        app.launchArguments = ["--typed"]
        app.launch()
        app.buttons["composer.attach"].tap()
        app.buttons.containing(.staticText, identifier: "Camera").firstMatch.tap()
        XCTAssertTrue(app.buttons["camera.shutter"].waitForExistence(timeout: 3))
        capture("camera-photo")
        app.buttons["camera.zoom.2.0"].tap()
        app.buttons["camera.flip"].tap()
        app.buttons["camera.flash"].tap()
        XCTAssertEqual(app.buttons["camera.flash"].value as? String, "on")
        app.buttons["camera.mode.VIDEO"].tap()
        app.buttons["camera.shutter"].tap()
        XCTAssertEqual(app.buttons["camera.shutter"].label, "Stop video")
        app.buttons["camera.cancel"].tap()
        app.buttons["Close"].tap()
        XCTAssertEqual(app.textFields["composer.draft"].value as? String, "Reply with a short greeting.")
        app.buttons["composer.attach"].tap()
        app.buttons.containing(.staticText, identifier: "Camera").firstMatch.tap()
        app.buttons["camera.shutter"].tap()
        XCTAssertTrue(app.buttons["Remove Camera photo.jpg"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.textFields["composer.draft"].value as? String, "Reply with a short greeting.")
    }

    @MainActor func testEditCancelRestoresAssistantAndUnsentDraft() {
        let app = XCUIApplication()
        app.launchArguments = ["--complete", "--typed"]
        app.launch()
        app.staticTexts["Reply with a short greeting."].firstMatch.press(forDuration: 1)
        app.buttons["Edit"].tap()
        XCTAssertTrue(app.buttons["editing.cancel"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["Hey Jordan! What's on your mind tonight?"].exists)
        capture("editing-message")
        app.buttons["editing.cancel"].tap()
        XCTAssertTrue(app.staticTexts["Hey Jordan! What's on your mind tonight?"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.textFields["composer.draft"].value as? String, "Reply with a short greeting.")
    }

    @MainActor func testInlineVoiceSettingsModelAndExitRestoreConversation() {
        let app = XCUIApplication()
        app.launchArguments = ["--complete"]
        app.launch()
        app.buttons["composer.voice"].tap()
        XCTAssertTrue(app.buttons["voice.microphone"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Hey Jordan! What's on your mind tonight?"].exists)
        XCTAssertFalse(app.buttons["Copy response"].exists)
        XCTAssertFalse(app.staticTexts["Claude is AI and can make mistakes."].exists)
        capture("voice-inline")
        app.buttons["voice.output"].tap()
        XCTAssertEqual(app.buttons["voice.output"].value as? String, "Muted")
        app.buttons["voice.settings"].tap()
        XCTAssertTrue(app.staticTexts["Voice settings"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.buttons["voice.choice.Suave"].frame.midX, app.frame.midX, accuracy: 5)
        capture("voice-settings")
        app.buttons["voice.choice.Clara"].tap()
        XCTAssertEqual(app.buttons["voice.choice.Clara"].frame.midX, app.frame.midX, accuracy: 5)
        app.buttons["voice.choice.Suave"].tap()
        XCTAssertEqual(app.buttons["voice.choice.Suave"].frame.midX, app.frame.midX, accuracy: 5)
        app.buttons["voice.settings.model"].tap()
        XCTAssertTrue(app.staticTexts["Select model"].waitForExistence(timeout: 2))
        capture("voice-models")
        app.buttons["model.Sonnet 5.5"].tap()
        app.buttons["Close"].tap()
        app.buttons["voice.exit"].tap()
        XCTAssertTrue(app.buttons["composer.voice"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Copy response"].exists)
        XCTAssertTrue(app.staticTexts["Claude is AI and can make mistakes."].exists)
        XCTAssertTrue(app.buttons["composer.model"].label.contains("Sonnet 5.5"))
        XCTAssertTrue(app.staticTexts["Voice chat ended"].exists)
        capture("voice-ended")
        app.buttons["Good voice chat"].tap()
        XCTAssertEqual(app.buttons["Good voice chat"].value as? String, "Selected")
        app.buttons["voice.summary.dismiss"].tap()
        XCTAssertFalse(app.staticTexts["Voice chat ended"].exists)
    }
    @MainActor func testDevicesManageAccountAndClosePreserveConversation() {
        let app = XCUIApplication()
        app.launchArguments = ["--complete"]
        app.launch()
        app.buttons["header.devices"].tap()
        let device = app.descendants(matching: .any)["devices.row.sample-desktop"].firstMatch
        XCTAssertTrue(device.waitForExistence(timeout: 3))
        XCTAssertTrue(device.label.contains("Connected"))
        device.tap()
        XCTAssertTrue(app.buttons["devices.manage"].exists)
        capture("devices-connected")
        app.buttons["devices.manage"].tap()
        let name = app.textFields["devices.profile.name"]
        XCTAssertTrue(name.waitForExistence(timeout: 3))
        XCTAssertEqual(name.value as? String, "Jordan Lee")
        capture("manage-devices-account")
        app.scrollViews["devices.account.scroll"].swipeUp()
        XCTAssertTrue(app.buttons["devices.logout"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["devices.delete"].isEnabled)
        app.buttons["devices.logout"].tap()
        XCTAssertTrue(app.buttons["devices.organization.copy"].exists)
        capture("manage-devices-bottom")
        app.buttons["sheet.close.Manage devices"].tap()
        app.buttons["sheet.close.Devices"].tap()
        XCTAssertTrue(app.staticTexts["Hey Jordan! What's on your mind tonight?"].waitForExistence(timeout: 2))
    }

    @MainActor func testDispatchSidebarNavigationDraftAndReturnToChat() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["sidebar.open"].tap()
        app.buttons.containing(.staticText, identifier: "Dispatch").firstMatch.tap()
        XCTAssertTrue(app.textFields["dispatch.draft"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Online"].exists)
        XCTAssertTrue(app.staticTexts["Oct 7, 2026 at 9:11 PM"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.buttons["dispatch.send"].isEnabled)
        capture("dispatch-online")
        app.textFields["dispatch.draft"].tap()
        app.textFields["dispatch.draft"].typeText("Organize sample files")
        XCTAssertTrue(app.buttons["dispatch.send"].isEnabled)
        app.buttons["dispatch.send"].tap()
        XCTAssertEqual(app.textFields["dispatch.draft"].value as? String, "Organize sample files")
        app.buttons["sidebar.open"].tap()
        app.buttons.containing(.staticText, identifier: "New session").firstMatch.tap()
        XCTAssertTrue(app.buttons["composer.voice"].waitForExistence(timeout: 3))
    }

    @MainActor func testCodeHomeFilterAndHostHooksPreserveList() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["sidebar.open"].tap()
        app.buttons.containing(.staticText, identifier: "Code").firstMatch.tap()
        XCTAssertTrue(app.buttons["code.add-device"].waitForExistence(timeout: 3))
        capture("code-home")
        app.buttons["code.filter"].tap()
        XCTAssertTrue(app.buttons["Needs input"].waitForExistence(timeout: 2))
        capture("code-filter")
        app.buttons["Needs input"].tap()
        XCTAssertTrue(app.buttons["code.session.map"].exists)
        XCTAssertFalse(app.buttons["code.session.design"].exists)
        app.buttons["code.filter"].tap()
        app.buttons["All"].tap()
        XCTAssertTrue(app.buttons["code.session.design"].exists)
        app.buttons["code.add-device"].tap()
        XCTAssertTrue(app.buttons["code.remote.copy"].waitForExistence(timeout: 2))
        capture("code-add-device")
        app.buttons["sheet.close.Set up remote control"].tap()
        app.buttons["code.new-session"].tap()
        XCTAssertTrue(app.buttons["code.draft.back"].waitForExistence(timeout: 2))
        app.buttons["code.draft.back"].tap()
        XCTAssertTrue(app.buttons["code.session.design"].exists)
        app.buttons["sidebar.open"].tap()
        app.buttons.containing(.staticText, identifier: "New session").firstMatch.tap()
        XCTAssertTrue(app.buttons["composer.voice"].waitForExistence(timeout: 2))
    }
    @MainActor func testRoutinesManualScheduleAndCancellation() {
        let app = XCUIApplication()
        app.launchArguments = ["--code"]
        app.launch()
        app.buttons["code.routines"].tap()
        XCTAssertTrue(app.staticTexts["No routines yet"].waitForExistence(timeout: 2))
        capture("routines-empty")
        app.buttons["routines.filter"].tap()
        XCTAssertTrue(app.buttons["Active"].waitForExistence(timeout: 2))
        capture("routines-filter")
        app.buttons["Active"].tap()
        XCTAssertTrue(app.staticTexts["No routines yet"].exists)
        app.buttons["routines.filter"].tap()
        app.buttons["All"].tap()
        app.buttons["routines.new"].tap()
        XCTAssertTrue(app.buttons["routine.manual"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["routine.draft"].isEnabled)
        capture("routine-new")
        app.buttons["routine.manual"].tap()
        XCTAssertTrue(app.textFields["routine.name"].waitForExistence(timeout: 2))
        capture("routine-manual")
        app.swipeUp()
        XCTAssertTrue(app.buttons["routine.create"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["routine.create"].isEnabled)
        capture("routine-manual-bottom")
        app.buttons["routine.option.Schedule"].tap()
        app.swipeUp()
        XCTAssertTrue(app.buttons["routine.schedule.repeat"].waitForExistence(timeout: 2))
        capture("routine-schedule")
        app.buttons["routine.schedule.repeat"].tap()
        XCTAssertTrue(app.buttons["Weekdays"].waitForExistence(timeout: 2))
        capture("routine-repeat-menu")
        app.buttons["Weekdays"].tap()
        XCTAssertTrue(app.buttons["routine.schedule.repeat"].label.contains("Weekdays"))
        app.buttons["routine.schedule.remove"].tap()
        XCTAssertTrue(app.buttons["routine.option.Schedule"].exists)
        app.buttons["sheet.close.New routine"].tap()
        app.buttons["sheet.close.New routine"].tap()
        XCTAssertTrue(app.staticTexts["No routines yet"].waitForExistence(timeout: 2))
        app.buttons["routines.back"].tap()
        XCTAssertTrue(app.buttons["code.add-device"].exists)
    }

    @MainActor func testCodeDraftModelBranchPermissionAndBackPreserveDraft() {
        let app = XCUIApplication()
        app.launchArguments = ["--code-new-session"]
        app.launch()
        XCTAssertTrue(app.buttons["code.draft.model"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.buttons["code.draft.send"].isEnabled)
        capture("code-new-session")
        app.buttons["code.draft.model"].tap()
        capture("code-models")
        app.buttons["code.model.effort"].tap()
        capture("code-effort")
        app.buttons["code.effort.Ultracode"].tap()
        app.buttons["sheet.close.Select model"].tap()
        XCTAssertTrue(app.buttons["code.draft.model"].label.contains("Ultracode"))
        app.buttons["code.draft.repository"].tap()
        capture("code-repository-menu")
        app.buttons["Change branch"].tap()
        XCTAssertTrue(app.buttons["code.branch.feature"].waitForExistence(timeout: 2))
        capture("code-branches")
        app.buttons["code.branch.feature"].tap()
        XCTAssertTrue(app.buttons["code.draft.repository"].label.contains("sample_branch"))
        app.buttons["code.draft.attach"].tap()
        capture("code-context")
        app.buttons["code.context.permission"].tap()
        capture("code-permission")
        app.buttons["code.permission.Plan"].tap()
        XCTAssertTrue(app.buttons["code.context.permission"].label.contains("Plan"))
        app.buttons["sheet.close.Add context"].tap()
        let draft = app.textFields["code.draft.text"]
        draft.tap()
        draft.typeText("Keep this local task")
        XCTAssertTrue(app.buttons["code.draft.send"].isEnabled)
        app.buttons["code.draft.send"].tap()
        XCTAssertEqual(draft.value as? String, "Keep this local task")
        app.buttons["code.draft.back"].tap()
        app.buttons["code.new-session"].tap()
        XCTAssertEqual(app.textFields["code.draft.text"].value as? String, "Keep this local task")
    }
    @MainActor func testCodeEnvironmentCancelAndRepositorySelection() {
        let app = XCUIApplication()
        app.launchArguments = ["--code-new-session"]
        app.launch()
        app.buttons["code.draft.environment"].tap()
        XCTAssertTrue(app.buttons["code.environment.create"].waitForExistence(timeout: 2))
        capture("code-environments")
        app.buttons["code.environment.create"].tap()
        XCTAssertTrue(app.buttons["code.environment.network"].waitForExistence(timeout: 2))
        capture("code-environment-create")
        XCTAssertFalse(app.buttons["code.environment.submit"].isEnabled)
        app.buttons["code.environment.network"].tap()
        XCTAssertTrue(app.buttons["Full network access"].waitForExistence(timeout: 2))
        capture("code-environment-network")
        app.buttons["Full network access"].tap()
        XCTAssertTrue(app.buttons["code.environment.network"].label.contains("Full network access"))
        app.buttons["sheet.close.New cloud environment"].tap()
        app.buttons["code.environment.cloud"].tap()
        XCTAssertTrue(app.buttons["code.draft.environment"].label.contains("Cloud"))
        app.buttons["code.draft.repository"].tap()
        app.buttons["Change repository"].tap()
        XCTAssertTrue(app.buttons["code.repository.library"].waitForExistence(timeout: 2))
        capture("code-repositories")
        app.buttons["code.repository.library"].tap()
        app.buttons["sheet.close.Repositories (1)"].tap()
        XCTAssertTrue(app.buttons["code.draft.repository"].label.contains("BookLibrary"))
    }

    @MainActor func testCodeConnectorPermissionsRemainLocal() {
        let app = XCUIApplication()
        app.launchArguments = ["--code-new-session"]
        app.launch()
        app.buttons["code.draft.attach"].tap()
        app.buttons["code.context.connectors"].tap()
        XCTAssertTrue(app.switches["code.connectors.discovery"].waitForExistence(timeout: 2))
        capture("code-connectors")
        app.buttons["code.connector.design"].tap()
        capture("code-connector-tools")
        app.buttons["code.connector.all-tools"].tap()
        capture("code-tool-permission")
        app.buttons["code.tool.permission.Blocked"].tap()
        XCTAssertTrue(app.buttons["code.connector.all-tools"].label.contains("Never"))
        app.buttons["sheet.close.Design tools"].tap()
        app.buttons["sheet.close.Connectors"].tap()
        app.buttons["sheet.close.Add context"].tap()
        XCTAssertFalse(app.buttons["code.draft.send"].isEnabled)
    }
    @MainActor func testProjectsIntroductionDraftPickersAndCancellation() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["Open sidebar"].tap()
        app.buttons["Projects"].tap()
        XCTAssertTrue(app.staticTexts["No projects yet"].waitForExistence(timeout: 3))
        capture("projects-empty")
        app.buttons["projects.filter"].tap()
        capture("projects-filter")
        app.buttons["Pinned"].tap()
        app.buttons["projects.new"].tap()
        XCTAssertTrue(app.buttons["project.introduction.continue"].waitForExistence(timeout: 3))
        capture("projects-introduction")
        app.buttons["project.introduction.continue"].tap()
        XCTAssertFalse(app.buttons["project.create"].isEnabled)
        capture("projects-setup")
        let name = app.textFields["project.name"]
        name.tap()
        name.typeText("Garden plan\n")
        XCTAssertTrue(app.buttons["project.create"].isEnabled)
        app.buttons["project.icon"].tap()
        capture("projects-icons")
        let search = app.textFields["project.icons.search"]
        search.tap()
        search.typeText("book")
        app.buttons["project.icons.book"].tap()
        app.buttons["project.icons.save"].tap()
        XCTAssertEqual(name.value as? String, "Garden plan")
        app.buttons["project.context"].tap()
        capture("projects-context")
        app.buttons["Google Drive"].tap()
        XCTAssertFalse(app.buttons["project.drive.add"].isEnabled)
        capture("projects-drive")
        app.buttons["project.drive.back"].tap()
        app.buttons["project.environment"].tap()
        capture("projects-environment")
        app.buttons["Default"].tap()
        app.buttons["project.cancel"].tap()
        XCTAssertTrue(app.staticTexts["No projects yet"].waitForExistence(timeout: 3))
        app.buttons["projects.new"].tap()
        XCTAssertTrue(app.textFields["project.name"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.textFields["project.name"].value as? String, "Project name...")
        XCTAssertFalse(app.buttons["project.create"].isEnabled)
        app.buttons["project.cancel"].tap()
    }
    @MainActor func testArtifactsFiltersDocumentCollapseAndReturn() {
        let app = XCUIApplication()
        app.launchArguments = ["--artifacts"]
        app.launch()
        XCTAssertTrue(app.buttons["artifact.row.garden"].waitForExistence(timeout: 3))
        capture("artifacts-list")
        app.buttons["artifacts.filter"].tap()
        XCTAssertTrue(app.buttons["Shared with you"].waitForExistence(timeout: 2))
        capture("artifacts-filter")
        app.buttons["Pinned"].tap()
        XCTAssertTrue(app.buttons["artifact.row.garden"].exists)
        XCTAssertFalse(app.buttons["artifact.row.workshop"].exists)
        app.buttons["artifacts.filter"].tap()
        app.buttons["All"].tap()
        app.buttons["artifact.row.garden"].tap()
        XCTAssertTrue(app.buttons["artifact.section.overview"].waitForExistence(timeout: 2))
        capture("artifact-document")
        XCTAssertFalse(app.buttons["artifact.undo"].isEnabled)
        XCTAssertFalse(app.buttons["artifact.redo"].isEnabled)
        app.buttons["artifact.section.overview"].tap()
        XCTAssertFalse(
            app.staticTexts[
                "A neighborhood garden gives people a place to learn together, share seasonal produce, and enjoy a quiet afternoon outside."
            ].exists)
        app.buttons["artifact.section.overview"].tap()
        app.buttons["artifact.collapse-title"].tap()
        XCTAssertFalse(app.buttons["artifact.section.overview"].exists)
        app.buttons["artifact.collapse-title"].tap()
        app.buttons["artifact.comments"].tap()
        app.buttons["artifact.share"].tap()
        app.buttons["artifact.tabs"].tap()
        XCTAssertTrue(app.buttons["artifact.section.overview"].exists)
        app.buttons["artifact.back"].tap()
        XCTAssertTrue(app.buttons["artifact.row.garden"].exists)
        app.buttons["sidebar.open"].tap()
        app.buttons.containing(.staticText, identifier: "New session").firstMatch.tap()
        XCTAssertTrue(app.buttons["composer.voice"].waitForExistence(timeout: 2))
    }
    @MainActor func testWidgetPreviewLinksRouteToOfflineScreens() {
        let app = XCUIApplication()
        let cases = [
            ("quickActionsSmall.chat", "composer.voice"), ("quickActionsSmall.camera", "camera.cancel"),
            ("quickActionsSmall.voice", "voice.exit"), ("quickActionsMedium.code", "code.add-device"),
            ("quickActionsMedium.dispatch", "dispatch.send"), ("codeSmall.newCodeSession", "code.draft.back"),
            ("codeSmall.searchCode", "code.search")
        ]
        for (index, route) in cases.enumerated() {
            app.launchArguments = ["--widgets"]
            app.launch()
            let link = app.descendants(matching: .any)["widget." + route.0].firstMatch
            XCTAssertTrue(link.waitForExistence(timeout: 3))
            if index == 0 { capture("widgets-preview") }
            link.tap()
            XCTAssertTrue(app.buttons[route.1].waitForExistence(timeout: 3))
        }
    }
    /// Native SpringBoard tests are opt-in because they modify a simulator Home Screen.
    @MainActor func testWidgetNativeGalleryVariants() throws {
        guard ProcessInfo.processInfo.environment["CLAUDE_NATIVE_WIDGET_TESTS"] == "1" else {
            throw XCTSkip("Set CLAUDE_NATIVE_WIDGET_TESTS=1 on the test runner for native gallery validation")
        }
        let app = XCUIApplication()
        app.launch()
        XCUIDevice.shared.press(.home)
        Thread.sleep(forTimeInterval: 2)
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        func nativeCapture(_ name: String) {
            let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
            attachment.name = name
            attachment.lifetime = .keepAlways
            add(attachment)
        }
        guard
            let icon = springboard.icons.matching(identifier: "Claude UI Demo").allElementsBoundByIndex.first(where: {
                $0.isHittable
            })
        else {
            XCTFail("Installed demo app icon missing")
            return
        }
        icon.press(forDuration: 1.2)
        springboard.buttons["Edit Home Screen"].tap()
        springboard.buttons["Edit"].tap()
        springboard.buttons["Add Widget"].tap()
        XCTAssertTrue(springboard.cells["Claude UI Demo"].waitForExistence(timeout: 4))
        springboard.cells["Claude UI Demo"].tap()
        guard let page = springboard.pageIndicators.allElementsBoundByIndex.first(where: { $0.frame.width > 300 })
        else {
            XCTFail("Native gallery page indicator missing")
            return
        }
        func pageIs(_ number: Int) -> Bool { page.value as? String == "page \(number) of 3" }
        func move(to number: Int, left: Bool) {
            for _ in 0..<3 {
                if pageIs(number) { return }
                let start = springboard.coordinate(withNormalizedOffset: CGVector(dx: left ? 0.88 : 0.12, dy: 0.58))
                let end = springboard.coordinate(withNormalizedOffset: CGVector(dx: left ? 0.12 : 0.88, dy: 0.58))
                start.press(forDuration: 0.05, thenDragTo: end)
                _ = XCTWaiter.wait(
                    for: [
                        XCTNSPredicateExpectation(
                            predicate: NSPredicate(format: "value == %@", "page \(number) of 3"), object: page)
                    ], timeout: 2)
            }
            XCTAssertTrue(pageIs(number))
        }
        XCTAssertTrue(page.waitForExistence(timeout: 4))
        XCTAssertTrue(pageIs(1))
        nativeCapture("widget-native-quick-small")
        move(to: 2, left: true)
        nativeCapture("widget-native-quick-medium")
        move(to: 3, left: true)
        XCTAssertTrue(springboard.staticTexts["Code shortcuts"].exists)
        nativeCapture("widget-native-code-small")
        springboard.buttons["close"].tap()
        if springboard.buttons["Done"].waitForExistence(timeout: 3) { springboard.buttons["Done"].tap() }
    }
    @MainActor func testWidgetInstalledSmallLinks() throws {
        guard ProcessInfo.processInfo.environment["CLAUDE_NATIVE_WIDGET_TESTS"] == "1" else {
            throw XCTSkip("Install the small Quick Actions widget and enable CLAUDE_NATIVE_WIDGET_TESTS=1")
        }
        let app = XCUIApplication()
        app.launchArguments = []
        app.launch()
        XCUIDevice.shared.press(.home)
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        for route in [("camera", "camera.cancel"), ("voice", "voice.exit"), ("chat", "composer.voice")] {
            let link = springboard.buttons["widget.quickActionsSmall." + route.0]
            XCTAssertTrue(link.waitForExistence(timeout: 4))
            link.tap()
            XCTAssertTrue(app.buttons[route.1].waitForExistence(timeout: 4))
            XCUIDevice.shared.press(.home)
        }
        Thread.sleep(forTimeInterval: 2)
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = "widget-native-installed"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    @MainActor func testMarkdownFormattingCopyAndSelectionInBothAppearances() {
        let app = XCUIApplication()
        for appearance in ["dark", "light"] {
            app.launchArguments = ["--markdown"] + (appearance == "light" ? ["--light"] : [])
            app.launch()
            XCTAssertTrue(app.staticTexts["A small garden"].waitForExistence(timeout: 4))
            capture("markdown-top-" + appearance)
            let paragraph = app.textViews["markdown.inlineCode"].firstMatch
            paragraph.press(forDuration: 1.1)
            XCTAssertTrue(app.buttons["Copy"].waitForExistence(timeout: 2) || app.menuItems["Copy"].exists)
            app.launch()
            // Targeted native auto-scroll remains stable when content height changes.
            app.buttons["markdown.code.copy"].tap()
            XCTAssertTrue(app.buttons["markdown.code.copy"].isHittable)
            capture("markdown-code-" + appearance)
            app.buttons["markdown.code.expand"].tap()
            XCTAssertTrue(app.buttons["markdown.code.close"].waitForExistence(timeout: 3))
            XCTAssertLessThan(app.staticTexts["markdown.code.expandedContent"].frame.minY, 220)
            capture("markdown-expanded-" + appearance)
            app.buttons["markdown.code.close"].tap()
            app.buttons["markdown.code.copy"].tap()
            let draft = app.textFields["composer.draft"]
            draft.tap()
            draft.press(forDuration: 1.1)
            if app.buttons["Paste"].waitForExistence(timeout: 2) {
                app.buttons["Paste"].tap()
            } else {
                app.menuItems["Paste"].tap()
            }
            XCTAssertEqual(draft.value as? String, "def greet(name: str) -> str:\n    return f\"Hello, {name}!\"\n")
            app.launch()
            app.swipeUp()
            capture("markdown-table-" + appearance)
            XCTAssertTrue(app.staticTexts["Mint"].exists)
            XCTAssertTrue(app.staticTexts["Season"].isHittable)
            let compact = app.scrollViews["markdown.table"].firstMatch
            XCTAssertLessThanOrEqual(app.staticTexts["Season"].frame.maxX, compact.frame.maxX)
            capture("markdown-table-compact-" + appearance)
            app.swipeUp()
            app.scrollViews.matching(identifier: "markdown.table").element(boundBy: 1).swipeLeft()
            XCTAssertTrue(app.staticTexts["Last updated"].isHittable)
            capture("markdown-table-scrolled-" + appearance)
            XCTAssertTrue(app.buttons["composer.voice"].exists)
        }
    }

    @MainActor func testMediaSelectionSendViewerAndFilenameCopy() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["composer.attach"].tap()
        let recent = app.buttons["media.recent.garden-1"]
        XCTAssertTrue(recent.waitForExistence(timeout: 3))
        recent.tap()
        XCTAssertEqual(recent.value as? String, "Selected")
        capture("media-recent-selected")
        recent.tap()
        XCTAssertFalse(app.buttons["media.attachSelected"].exists)
        recent.tap()
        app.buttons["media.attachSelected"].tap()
        XCTAssertTrue(app.buttons["media.draft.garden-1"].waitForExistence(timeout: 3))
        capture("media-composer")
        app.buttons["media.remove.garden-1"].tap()
        XCTAssertFalse(app.buttons["composer.send"].exists)
        app.buttons["composer.attach"].tap()
        app.buttons["media.recent.garden-1"].tap()
        app.buttons["media.attachSelected"].tap()
        app.buttons["composer.send"].tap()
        let sent = app.buttons["media.message.garden-1"]
        XCTAssertTrue(sent.waitForExistence(timeout: 3))
        XCTAssertGreaterThan(sent.frame.maxX, app.frame.width - 24)
        capture("media-sent")
        sent.tap()
        XCTAssertTrue(app.buttons["media.viewer.close"].waitForExistence(timeout: 3))
        capture("media-viewer")
        let image = app.buttons["media.viewer.image"]
        image.tap()
        XCTAssertTrue(app.buttons["media.viewer.close"].waitForNonExistence(timeout: 3))
        capture("media-viewer-hidden")
        image.tap()
        app.buttons["media.viewer.share"].tap()
        app.buttons["media.viewer.edit"].tap()
        XCTAssertTrue(app.buttons["media.viewer.close"].exists)
        app.buttons["media.viewer.close"].tap()
        sent.press(forDuration: 1.1)
        XCTAssertTrue(app.buttons["Copy file name"].waitForExistence(timeout: 2))
        capture("media-context-menu")
        app.buttons["Copy file name"].tap()
        let draft = app.textFields["composer.draft"]
        draft.tap()
        draft.press(forDuration: 1.1)
        if app.buttons["Paste"].waitForExistence(timeout: 2) {
            app.buttons["Paste"].tap()
        } else {
            app.menuItems["Paste"].tap()
        }
        XCTAssertEqual(draft.value as? String, "Garden-1.png")
    }

    @MainActor func testVideoFileCardViewerAndDownloadIntent() {
        let app = XCUIApplication()
        for appearance in ["dark", "light"] {
            app.launchArguments = ["--video"] + (appearance == "light" ? ["--light"] : [])
            app.launch()
            XCTAssertTrue(app.buttons["media.draft.garden-video"].waitForExistence(timeout: 3))
            capture("video-composer-" + appearance)
            app.buttons["composer.send"].tap()
            let card = app.buttons["media.message.garden-video"]
            XCTAssertTrue(card.waitForExistence(timeout: 3))
            XCTAssertEqual(card.frame.width, 140, accuracy: 1)
            XCTAssertGreaterThan(card.frame.maxX, app.frame.width - 24)
            capture("video-file-card-" + appearance)
            card.tap()
            XCTAssertTrue(app.buttons["media.video.close"].waitForExistence(timeout: 3))
            capture("video-file-viewer-" + appearance)
            XCTAssertFalse(app.buttons["media.viewer.edit"].exists)
            XCTAssertFalse(app.buttons["media.viewer.share"].exists)
            let movie = app.otherElements["media.video.content"]
            XCTAssertTrue(movie.waitForExistence(timeout: 3))
            movie.tap()
            XCTAssertTrue(app.buttons["media.video.close"].exists)
            let ended = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", "Ended"), object: movie)
            XCTAssertEqual(XCTWaiter.wait(for: [ended], timeout: 14), .completed)
            capture("video-final-frame-" + appearance)
            app.buttons["media.video.options"].tap()
            XCTAssertTrue(app.buttons["Download"].waitForExistence(timeout: 3))
            capture("video-download-menu-" + appearance)
            app.buttons["Download"].tap()
            XCTAssertTrue(app.buttons["media.video.close"].exists)
            app.buttons["media.video.close"].tap()
            card.press(forDuration: 1.1)
            XCTAssertTrue(app.buttons["Copy file name"].waitForExistence(timeout: 3))
            capture("video-file-context-menu-" + appearance)
            XCTAssertFalse(app.buttons["Copy image"].exists)
            app.buttons["Copy file name"].tap()
            card.tap()
            XCTAssertTrue(app.buttons["media.video.close"].waitForExistence(timeout: 3))
            XCTAssertEqual(app.otherElements["media.video.content"].value as? String, "Playing")
            capture("video-reopened-" + appearance)
            app.buttons["media.video.close"].tap()
        }
    }

    @MainActor func testSettingsProfileDraftCancelAndLocalSaveInBothAppearances() {
        let app = XCUIApplication()
        for appearance in ["dark", "light"] {
            app.launchArguments = appearance == "light" ? ["--light"] : []
            app.launch()
            app.buttons["sidebar.open"].tap()
            app.buttons["sidebar.settings"].tap()
            XCTAssertTrue(app.buttons["settings.route.Profile"].waitForExistence(timeout: 3))
            capture("settings-root-" + appearance)
            app.buttons["settings.about"].tap()
            XCTAssertTrue(app.buttons["Usage Policy"].waitForExistence(timeout: 3))
            capture("settings-info-" + appearance)
            app.buttons["Usage Policy"].tap()
            app.buttons["settings.route.Profile"].tap()
            let nickname = app.textFields["settings.profile.nickname"]
            XCTAssertTrue(nickname.waitForExistence(timeout: 3))
            XCTAssertEqual(nickname.value as? String, "Jordan")
            capture("settings-profile-" + appearance)
            app.buttons["settings.profile.photo"].tap()
            XCTAssertTrue(app.buttons["View photo library"].waitForExistence(timeout: 3))
            capture("settings-photo-menu-" + appearance)
            app.buttons["View photo library"].tap()

            app.buttons["settings.profile.instructions"].tap()
            let editor = app.textViews["settings.instructions.editor"]
            XCTAssertTrue(editor.waitForExistence(timeout: 3))
            capture("settings-instructions-" + appearance)
            editor.tap()
            editor.typeText("Keep this draft private")
            app.buttons["settings.instructions.cancel"].tap()
            app.buttons["settings.profile.instructions"].tap()
            XCTAssertEqual(editor.value as? String, "")
            app.buttons["settings.instructions.cancel"].tap()

            nickname.tap()
            nickname.typeText(" draft")
            app.buttons["settings.back"].tap()
            app.buttons["settings.route.Profile"].tap()
            XCTAssertEqual(nickname.value as? String, "Jordan")
            nickname.tap()
            nickname.typeText(" saved")
            XCTAssertEqual(nickname.value as? String, "Jordan saved")
            app.buttons["settings.profile.save"].tap()
            XCTAssertTrue(app.buttons["settings.route.Profile"].waitForExistence(timeout: 3))
            app.buttons["settings.route.Profile"].tap()
            XCTAssertEqual(nickname.value as? String, "Jordan saved")
            app.buttons["settings.profile.delete"].tap()
            XCTAssertEqual(nickname.value as? String, "Jordan saved")
            app.buttons["settings.back"].tap()
            let scroll = app.scrollViews["settings.root.scroll"]
            scroll.swipeUp()
            scroll.swipeUp()
            XCTAssertTrue(app.switches["settings.haptics"].exists)
            capture("settings-appearance-" + appearance)
            let before = app.switches["settings.haptics"].value as? String
            app.switches["settings.haptics"].tap()
            app.buttons["settings.back"].tap()
            app.buttons["sidebar.settings"].tap()
            scroll.swipeUp()
            scroll.swipeUp()
            XCTAssertNotEqual(app.switches["settings.haptics"].value as? String, before)
            app.buttons["settings.back"].tap()
            app.terminate()
        }
    }

    @MainActor func testWorkAnnouncementStillAndBothDismissalButtons() {
        let app = XCUIApplication()
        for button in ["announcement.dismiss", "announcement.close"] {
            app.launchArguments = ["--announcement"]
            app.launch()
            XCTAssertTrue(app.buttons[button].waitForExistence(timeout: 3))
            XCTAssertTrue(app.staticTexts["One Claude for your work"].exists)
            capture("work-announcement-still")
            app.buttons[button].tap()
            XCTAssertTrue(app.buttons["composer.voice"].waitForExistence(timeout: 3))
            app.terminate()
        }
    }

    @MainActor func testNotificationPreferencesPersistAcrossSettings() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["sidebar.open"].tap()
        app.buttons["sidebar.settings"].tap()
        app.buttons["settings.route.Notifications"].tap()
        XCTAssertTrue(app.switches["settings.notification.replies"].waitForExistence(timeout: 3))
        capture("settings-notifications-dark")
        for key in [
            "replies", "scheduledTasks", "researchComplete", "codeUpdates", "codePermissions", "dispatchMessages",
            "productUpdates"
        ] {
            let toggle = app.switches["settings.notification." + key]
            if !toggle.isHittable { app.scrollViews["settings.notifications.scroll"].swipeUp() }
            XCTAssertEqual(toggle.value as? String, "1")
            toggle.tap()
            XCTAssertEqual(toggle.value as? String, "0")
        }
        app.buttons["settings.back"].tap()
        app.buttons["settings.back"].tap()
        app.buttons["sidebar.settings"].tap()
        app.buttons["settings.route.Notifications"].tap()
        XCTAssertEqual(app.switches["settings.notification.replies"].value as? String, "0")
        app.buttons["settings.back"].tap()
        app.buttons["settings.back"].tap()
        app.terminate()
        app.launchArguments = ["--light"]
        app.launch()
        app.buttons["sidebar.open"].tap()
        app.buttons["sidebar.settings"].tap()
        app.buttons["settings.route.Notifications"].tap()
        XCTAssertTrue(app.switches["settings.notification.replies"].waitForExistence(timeout: 3))
        capture("settings-notifications-light")
    }

    @MainActor func testTimeFocusCapturedPickersAndLocalPreferencePersistence() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["sidebar.open"].tap()
        app.buttons["sidebar.settings"].tap()
        app.buttons["settings.route.Time & focus"].tap()
        let hours = app.buttons["settings.focus.hours"]
        let minutes = app.buttons["settings.focus.minutes"]
        XCTAssertTrue(hours.waitForExistence(timeout: 3))
        XCTAssertEqual(hours.value as? String, "-")
        capture("settings-time-focus-dark")
        hours.tap()
        XCTAssertTrue(app.buttons["settings.focus.choice.12"].waitForExistence(timeout: 3))
        capture("settings-time-focus-hours")
        app.buttons["settings.focus.choice.2"].tap()
        XCTAssertEqual(hours.value as? String, "2 hr")
        minutes.tap()
        XCTAssertTrue(app.buttons["settings.focus.choice.45"].waitForExistence(timeout: 3))
        capture("settings-time-focus-minutes")
        XCTAssertFalse(app.buttons["settings.focus.choice.60"].exists)
        app.buttons["settings.focus.choice.30"].tap()
        XCTAssertEqual(minutes.value as? String, "30 min")
        app.buttons["settings.focus.day.sunday"].tap()
        XCTAssertEqual(hours.value as? String, "2 hr")
        app.buttons["settings.back"].tap()
        app.buttons["settings.route.Time & focus"].tap()
        XCTAssertEqual(hours.value as? String, "2 hr")
        XCTAssertEqual(minutes.value as? String, "30 min")
        hours.tap()
        app.buttons["settings.focus.choice.none"].tap()
        minutes.tap()
        app.buttons["settings.focus.choice.none"].tap()
        XCTAssertEqual(hours.value as? String, "-")
        XCTAssertEqual(minutes.value as? String, "-")
        app.terminate()
        app.launchArguments = ["--light"]
        app.launch()
        app.buttons["sidebar.open"].tap()
        app.buttons["sidebar.settings"].tap()
        app.buttons["settings.route.Time & focus"].tap()
        XCTAssertTrue(hours.waitForExistence(timeout: 3))
        capture("settings-time-focus-light")
    }

    @MainActor func testPrivacyConsentIsHostOwnedInBothAppearances() {
        let app = XCUIApplication()
        for appearance in ["dark", "light"] {
            app.launchArguments = appearance == "light" ? ["--light"] : []
            app.launch()
            app.buttons["sidebar.open"].tap()
            app.buttons["sidebar.settings"].tap()
            app.buttons["settings.route.Privacy"].tap()
            let consent = app.switches["settings.privacy.modelImprovement"]
            XCTAssertTrue(consent.waitForExistence(timeout: 3))
            XCTAssertEqual(consent.value as? String, "1")
            capture("settings-privacy-" + appearance)
            consent.tap()
            XCTAssertEqual(consent.value as? String, "1")
            XCTAssertTrue(app.staticTexts["Data privacy"].exists)
            app.buttons["settings.back"].tap()
            app.buttons["settings.route.Privacy"].tap()
            XCTAssertEqual(consent.value as? String, "1")
            app.terminate()
        }
    }

    @MainActor func testUsageMetersAndHostOnlyCreditActionsInBothAppearances() {
        let app = XCUIApplication()
        for appearance in ["dark", "light"] {
            app.launchArguments = appearance == "light" ? ["--light"] : []
            app.launch()
            app.buttons["sidebar.open"].tap()
            app.buttons["sidebar.settings"].tap()
            app.buttons["settings.route.Usage"].tap()
            let creditToggle = app.switches["settings.usage.creditsEnabled"]
            XCTAssertTrue(creditToggle.waitForExistence(timeout: 3))
            XCTAssertEqual(creditToggle.value as? String, "0")
            XCTAssertTrue(app.staticTexts["12% used"].exists)
            XCTAssertTrue(app.staticTexts["40% used"].exists)
            capture("settings-usage-" + appearance)
            creditToggle.tap()
            XCTAssertEqual(creditToggle.value as? String, "0")
            app.buttons["settings.usage.refresh"].tap()
            app.buttons["settings.usage.info"].tap()
            XCTAssertTrue(app.staticTexts["12% used"].exists)
            app.scrollViews["settings.usage.scroll"].swipeUp()
            XCTAssertTrue(app.buttons["settings.usage.buy"].waitForExistence(timeout: 3))
            capture("settings-usage-footer-" + appearance)
            app.buttons["settings.usage.buy"].tap()
            XCTAssertEqual(app.staticTexts["settings.usage.balance"].label, "18 credits")
            app.buttons["settings.back"].tap()
            app.buttons["settings.route.Usage"].tap()
            XCTAssertEqual(creditToggle.value as? String, "0")
            app.terminate()
        }
    }

    @MainActor func testBillingNativeNoticeAndHostOnlyRestore() {
        let app = XCUIApplication()
        for appearance in ["dark", "light"] {
            app.launchArguments = appearance == "light" ? ["--light"] : []
            app.launch()
            app.buttons["sidebar.open"].tap()
            app.buttons["sidebar.settings"].tap()
            app.buttons["settings.route.Billing"].tap()
            XCTAssertTrue(app.buttons["settings.billing.manage"].waitForExistence(timeout: 3))
            capture("settings-billing-" + appearance)
            app.buttons["settings.billing.restore"].tap()
            XCTAssertEqual(app.staticTexts["settings.billing.plan"].label, "Max")
            app.buttons["settings.billing.manage"].tap()
            XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 3))
            capture("settings-billing-notice-" + appearance)
            app.alerts.buttons["OK"].tap()
            XCTAssertFalse(app.alerts.firstMatch.exists)
            app.buttons["settings.billing.manage"].tap()
            app.alerts.buttons["Manage on claude.ai"].tap()
            XCTAssertEqual(app.staticTexts["settings.billing.plan"].label, "Max")
            app.terminate()
        }
    }
    @MainActor func testSharedLinksReadOnlyDetailBackAndAppearance() {
        let app = XCUIApplication()
        for appearance in ["dark", "light"] {
            app.launchArguments = appearance == "light" ? ["--light"] : []
            app.launch()
            app.buttons["sidebar.open"].tap()
            app.buttons["sidebar.settings"].tap()
            let route = app.buttons["settings.route.Shared links"]
            if !route.isHittable { app.scrollViews["settings.root.scroll"].swipeUp() }
            route.tap()
            XCTAssertTrue(app.buttons["settings.shared.row.garden"].waitForExistence(timeout: 3))
            capture("settings-shared-links-" + appearance)
            app.buttons["settings.shared.row.garden"].tap()
            XCTAssertTrue(app.staticTexts["settings.shared.disclaimer"].waitForExistence(timeout: 3))
            XCTAssertFalse(app.textFields["composer.draft"].isHittable)
            XCTAssertTrue(app.staticTexts["Shared by Jordan 1 week ago"].exists)
            capture("settings-shared-detail-" + appearance)
            app.buttons["settings.back"].tap()
            XCTAssertTrue(app.buttons["settings.shared.row.garden"].waitForExistence(timeout: 3))
            app.buttons["settings.back"].tap()
            XCTAssertTrue(app.buttons["settings.route.Profile"].exists)
            app.terminate()
        }
    }

    @MainActor func testCodePreferencesMenusSliderAndNavigationPersistence() {
        let app = XCUIApplication()
        for appearance in ["dark", "light"] {
            app.launchArguments = appearance == "light" ? ["--light"] : []
            app.launch()
            app.buttons["sidebar.open"].tap()
            app.buttons["sidebar.settings"].tap()
            let route = app.buttons["settings.route.Claude Code"]
            if !route.isHittable { app.scrollViews["settings.root.scroll"].swipeUp() }
            route.tap()
            let slider = app.sliders["settings.code.size"]
            XCTAssertTrue(slider.waitForExistence(timeout: 3))
            capture("settings-code-" + appearance)
            app.buttons["settings.code.transcriptFont"].tap()
            XCTAssertTrue(app.buttons["System"].waitForExistence(timeout: 3))
            capture("settings-code-transcript-menu-" + appearance)
            app.buttons["System"].tap()
            XCTAssertTrue(app.buttons["settings.code.transcriptFont"].label.contains("System"))
            app.buttons["settings.code.codeFont"].tap()
            XCTAssertTrue(app.buttons["JetBrains Mono"].waitForExistence(timeout: 3))
            capture("settings-code-font-menu-" + appearance)
            app.buttons["JetBrains Mono"].tap()
            slider.adjust(toNormalizedSliderPosition: 0.8)
            let changedValue = slider.value as? String
            XCTAssertNotEqual(changedValue, "50%")
            app.switches["settings.code.wrap"].tap()
            XCTAssertEqual(app.switches["settings.code.wrap"].value as? String, "1")
            app.buttons["settings.back"].tap()
            if !route.isHittable { app.scrollViews["settings.root.scroll"].swipeUp() }
            route.tap()
            XCTAssertEqual(slider.value as? String, changedValue)
            XCTAssertTrue(app.buttons["settings.code.codeFont"].label.contains("JetBrains Mono"))
            XCTAssertEqual(app.switches["settings.code.wrap"].value as? String, "1")
            app.terminate()
        }
    }

    @MainActor func testCapabilitiesHostTruthAndMemoryFileDeleteCancel() {
        let app = XCUIApplication()
        for appearance in ["dark", "light"] {
            app.launchArguments = appearance == "light" ? ["--light", "--memory-clear-after-submit"] : []
            app.launch()
            app.buttons["sidebar.open"].tap()
            app.buttons["sidebar.settings"].tap()
            let route = app.buttons["settings.route.Capabilities"]
            if !route.isHittable { app.scrollViews["settings.root.scroll"].swipeUp() }
            route.tap()
            let artifacts = app.switches["settings.capability.artifacts"]
            XCTAssertTrue(artifacts.waitForExistence(timeout: 3))
            XCTAssertFalse(artifacts.isEnabled)
            XCTAssertEqual(artifacts.value as? String, "1")
            capture("settings-capabilities-" + appearance)
            app.switches["settings.capability.inlineVisualizations"].tap()
            XCTAssertEqual(app.switches["settings.capability.inlineVisualizations"].value as? String, "1")
            let memoryRoute = app.buttons["settings.capabilities.memoryFiles"]
            for _ in 0..<3 {
                if memoryRoute.isHittable { break }
                app.scrollViews["settings.capabilities.scroll"].swipeUp()
            }
            XCTAssertTrue(memoryRoute.isHittable)
            capture("settings-capabilities-memory-" + appearance)
            let sensitive = app.switches["settings.capability.sensitiveMemory"]
            sensitive.tap()
            XCTAssertEqual(sensitive.value as? String, "0")
            memoryRoute.tap()
            XCTAssertTrue(app.buttons["settings.memory.file.coding"].waitForExistence(timeout: 3))
            capture("settings-memory-files-" + appearance)
            XCTAssertFalse(app.buttons["settings.memory.send"].isEnabled)
            app.buttons["settings.memory.file.coding"].tap()
            XCTAssertTrue(app.buttons["settings.memory.delete"].waitForExistence(timeout: 3))
            capture("settings-memory-detail-" + appearance)
            app.buttons["settings.memory.delete"].tap()
            XCTAssertTrue(app.alerts.firstMatch.waitForExistence(timeout: 3))
            capture("settings-memory-delete-" + appearance)
            app.alerts.buttons["Cancel"].tap()
            XCTAssertTrue(app.buttons["settings.memory.delete"].isEnabled)
            let draft = app.descendants(matching: .any).matching(identifier: "settings.memory.draft").firstMatch
            draft.tap()
            draft.typeText("Remember herbs.")
            XCTAssertEqual(draft.value as? String, "Remember herbs.")
            app.buttons["settings.memory.send"].tap()
            XCTAssertEqual(draft.value as? String, appearance == "light" ? "" : "Remember herbs.")
            app.buttons["settings.memory.delete"].tap()
            app.alerts.buttons["Delete"].tap()
            XCTAssertTrue(app.buttons["settings.memory.delete"].exists)
            XCTAssertFalse(app.buttons["settings.memory.delete"].isEnabled)
            app.buttons["settings.back"].tap()
            XCTAssertTrue(app.buttons["settings.memory.file.coding"].exists)
            app.buttons["settings.memory.file.coding"].tap()
            XCTAssertTrue(app.buttons["settings.memory.delete"].isEnabled)
            app.buttons["settings.back"].tap()
            app.buttons["settings.back"].tap()
            XCTAssertTrue(app.buttons["settings.capabilities.memoryFiles"].exists)
            app.terminate()
        }
    }

    @MainActor func testSettingsConnectorsHostOnlyPolicyAndBackNavigation() {
        let app = XCUIApplication()
        for appearance in ["dark", "light"] {
            app.launchArguments = appearance == "light" ? ["--light"] : []
            app.launch()
            app.buttons["sidebar.open"].tap()
            app.buttons["sidebar.settings"].tap()
            let route = app.buttons["settings.route.Connectors"]
            if !route.isHittable { app.scrollViews["settings.root.scroll"].swipeUp() }
            route.tap()
            let discovery = app.switches["settings.connectors.discovery"]
            XCTAssertTrue(discovery.waitForExistence(timeout: 3))
            capture("settings-connectors-" + appearance)
            discovery.tap()
            XCTAssertEqual(discovery.value as? String, "1")

            app.buttons["settings.connector.notes"].tap()
            XCTAssertTrue(discovery.exists)
            app.buttons["settings.connector.design"].tap()
            XCTAssertTrue(app.buttons["settings.connector.tool.create"].waitForExistence(timeout: 3))
            capture("settings-connector-tools-" + appearance)
            app.buttons["settings.connector.allTools"].tap()
            XCTAssertTrue(app.buttons["settings.connector.policy.Always allow"].waitForExistence(timeout: 2))
            capture("settings-connector-all-tools-" + appearance)
            XCTAssertFalse(app.buttons["settings.connector.policy.Needs approval"].isSelected)
            app.buttons["settings.connector.policy.Always allow"].tap()
            XCTAssertFalse(app.buttons["settings.connector.policy.Always allow"].isSelected)
            app.buttons["settings.back"].tap()
            app.buttons["settings.connector.tool.create"].tap()
            XCTAssertTrue(app.buttons["settings.connector.policy.Needs approval"].waitForExistence(timeout: 3))
            capture("settings-connector-policy-" + appearance)
            XCTAssertTrue(app.buttons["settings.connector.policy.Needs approval"].isSelected)
            app.buttons["settings.connector.policy.Always allow"].tap()
            XCTAssertTrue(app.buttons["settings.connector.policy.Needs approval"].isSelected)
            app.buttons["settings.back"].tap()
            XCTAssertTrue(app.buttons["settings.connector.tool.create"].exists)
            app.buttons["settings.back"].tap()
            XCTAssertTrue(discovery.exists)
            app.buttons["settings.back"].tap()
            XCTAssertTrue(app.buttons["settings.route.Profile"].exists)
            app.terminate()
        }
    }

    @MainActor func testConnectorCatalogFiltersAndCustomDraftCancellation() {
        let app = XCUIApplication()
        for appearance in ["dark", "light"] {
            app.launchArguments = appearance == "light" ? ["--light"] : []
            app.launch()
            app.buttons["sidebar.open"].tap()
            app.buttons["sidebar.settings"].tap()
            let route = app.buttons["settings.route.Connectors"]
            if !route.isHittable { app.scrollViews["settings.root.scroll"].swipeUp() }
            route.tap()
            app.buttons["settings.connectors.add"].tap()
            capture("settings-connectors-add-" + appearance)
            app.buttons["Browse connectors"].tap()
            XCTAssertTrue(app.buttons["settings.catalog.sort"].waitForExistence(timeout: 3))
            capture("settings-catalog-" + appearance)
            app.buttons["settings.catalog.sort"].tap()
            capture("settings-catalog-sort-" + appearance)
            app.buttons["Consumer health"].tap()
            XCTAssertTrue(app.buttons["settings.catalog.connect.research"].waitForExistence(timeout: 2))
            XCTAssertFalse(app.buttons["settings.catalog.connect.design"].exists)
            capture("settings-catalog-health-" + appearance)
            app.buttons["settings.catalog.connect.research"].tap()
            XCTAssertTrue(app.buttons["settings.catalog.connect.research"].exists)
            let search = app.textFields["settings.catalog.search"]
            search.tap()
            search.typeText("Trail")
            XCTAssertTrue(app.buttons["settings.catalog.connect.trails"].exists)
            XCTAssertFalse(app.buttons["settings.catalog.connect.research"].exists)
            app.buttons["settings.catalog.close"].tap()
            app.buttons["settings.connectors.add"].tap()
            app.buttons["Add custom connector"].tap()
            let name = app.textFields["settings.custom.name"]
            XCTAssertTrue(name.waitForExistence(timeout: 3))
            XCTAssertTrue(app.buttons["settings.catalog.close"].isHittable)
            Thread.sleep(forTimeInterval: 2)
            capture("settings-custom-empty-" + appearance)
            XCTAssertFalse(app.buttons["settings.custom.continue"].isEnabled)
            name.tap()
            name.typeText("Example tools")
            XCTAssertEqual(name.value as? String, "Example tools")
            let url = app.textFields["settings.custom.url"]
            url.tap()
            url.typeText("https://example.com/mcp")
            XCTAssertEqual(url.value as? String, "https://example.com/mcp")
            XCTAssertTrue(app.buttons["settings.custom.continue"].isEnabled)
            app.buttons["settings.catalog.close"].tap()
            app.buttons["settings.connectors.add"].tap()
            app.buttons["Add custom connector"].tap()
            XCTAssertFalse(app.buttons["settings.custom.continue"].isEnabled)
            XCTAssertEqual(app.textFields["settings.custom.name"].value as? String, "Name")
            app.buttons["settings.catalog.close"].tap()
            app.terminate()
        }
    }

}
