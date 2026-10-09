import XCTest

final class MediaUITests: XCTestCase {

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
}
