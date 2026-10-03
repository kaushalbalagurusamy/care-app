import XCTest

/// End-to-end checks use app-owned, isolated launch fixtures. They never read or erase
/// the simulator user's ordinary CARE data.
final class CAREAppUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        launch(fixture: "--uitesting-fresh", skipWelcome: true)
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
    }

    private func launch(fixture: String, skipWelcome: Bool) {
        app?.terminate()
        app = XCUIApplication()
        app.launchArguments = [fixture]
        app.launch()
        if skipWelcome, app.buttons["Skip for now"].waitForExistence(timeout: 5) {
            app.buttons["Skip for now"].tap()
        }
    }

    @discardableResult
    private func require(_ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
        XCTAssertTrue(element.waitForExistence(timeout: 8), "Missing UI element: \(element.debugDescription)", file: file, line: line)
        return element
    }

    private func enableByScrolling(_ button: XCUIElement, maxSwipes: Int = 12) {
        require(button)
        for _ in 0..<maxSwipes where !button.isEnabled {
            app.swipeUp()
        }
        XCTAssertTrue(button.isEnabled, "The action never enabled after reaching the end of its content")
    }

    private func openChooseRelationships() {
        require(app.buttons["Assessment"]).tap()
        let begin = require(app.buttons["AssessmentOverviewBeginButton"])
        enableByScrolling(begin)
        begin.tap()
        require(app.staticTexts["Survey Instructions"])
        let next = require(app.buttons["SurveyOverviewNextButton"])
        enableByScrolling(next)
        next.tap()
        require(app.staticTexts["Choose Relationships"])
    }

    private func addContact(named name: String) {
        require(app.buttons["Add Person"]).tap()
        require(app.staticTexts["Add Relationship"])
        let nameField = require(app.textFields["RelationshipNameField"])
        let relationship = require(app.textFields["RelationshipToYouField"])
        XCTAssertTrue(relationship.exists, "Relationship to you should be optional free text")
        XCTAssertFalse(app.textFields["NewPersonAgeField"].exists)
        XCTAssertFalse(app.staticTexts["Other Relative"].exists)
        let save = require(app.buttons["Save Relationship"])
        XCTAssertFalse(save.isEnabled, "A blank name must not save")
        nameField.tap()
        nameField.typeText(name)
        XCTAssertTrue(save.isEnabled, "Name alone should allow saving")
        save.tap()
        require(app.staticTexts["Choose Relationships"])
    }

    func testFirstLaunchProfileHasNoAgeField() {
        launch(fixture: "--uitesting-fresh", skipWelcome: false)
        require(app.staticTexts["Welcome"])
        require(app.textFields["e.g., Alex Johnson"])
        XCTAssertFalse(app.staticTexts["Age"].exists)
        XCTAssertFalse(app.textFields["Age"].exists)
        require(app.buttons["Skip for now"]).tap()
        require(app.staticTexts["Welcome Back"])
    }

    func testFreeReleaseHasNoPurchaseEntryPoints() {
        XCTAssertFalse(app.buttons["AppIcon_sparkle"].exists)
        require(app.buttons["Exercises"]).tap()
        XCTAssertFalse(app.buttons["AppIcon_sparkle"].exists)
        XCTAssertFalse(app.buttons["UnlockFullBookExercisesButton"].exists)

        for category in ["Calm", "Accepted", "Resonant", "Energetic"] {
            require(app.buttons[category]).tap()
            XCTAssertFalse(app.buttons["AppIcon_sparkle"].exists)
            XCTAssertFalse(app.buttons["UnlockFullBookExercisesButton"].exists)
            require(app.buttons["AppIcon_back"]).tap()
        }
        require(app.buttons["Calm"]).tap()
        require(app.buttons["DoExercise_watch-something-funny"]).tap()
        require(app.staticTexts["Watch Something Funny"])
        let exerciseCapture = XCTAttachment(screenshot: app.screenshot())
        exerciseCapture.name = "Free Calm exercise header and emoji"
        exerciseCapture.lifetime = .keepAlways
        add(exerciseCapture)
    }

    func testPrivacyDetailsAreAccessibleFromProfileAndSettings() {
        require(app.buttons["Profile"]).tap()
        require(app.buttons["Privacy"]).tap()
        require(app.buttons["ProfilePrivacyDetailsButton"]).tap()
        require(app.staticTexts["Privacy & Data Use"])
        require(app.staticTexts["What stays on your device"])
        require(app.staticTexts["When you use other services"])
        require(app.staticTexts["Your choices and deletion"])
        require(app.buttons["Done"]).tap()

        require(app.buttons["Open Privacy Settings"]).tap()
        require(app.buttons["PrivacyDetailsLink"]).tap()
        require(app.staticTexts["Privacy & Data Use"])
    }

    func testNameOnlyContactsAndFivePersonGate() {
        openChooseRelationships()
        require(app.staticTexts["Choose five"])
        XCTAssertEqual(require(app.staticTexts["SelectedRelationshipCount"]).label, "0/5")
        let next = require(app.buttons["ChooseRelationshipsNextButton"])
        XCTAssertFalse(next.isEnabled, "Assessment must not start with zero selected contacts")

        let names = ["Alex One", "Blair Two", "Casey Three", "Drew Four", "Evan Five"]
        for (index, name) in names.enumerated() {
            addContact(named: name)
            require(app.buttons["Deselect \(name)"])
            XCTAssertEqual(require(app.staticTexts["SelectedRelationshipCount"]).label, "\(index + 1)/5")
            XCTAssertEqual(next.isEnabled, index == 4, "The gate should open at exactly five selections")
        }
        addContact(named: "Finley Six")
        require(app.buttons["Select Finley Six"])
        XCTAssertEqual(require(app.staticTexts["SelectedRelationshipCount"]).label, "5/5")

        // The card edge is part of the selection target, not just the avatar or name.
        require(app.buttons["Deselect Alex One"])
            .coordinate(withNormalizedOffset: CGVector(dx: 0.03, dy: 0.85)).tap()
        XCTAssertEqual(require(app.staticTexts["SelectedRelationshipCount"]).label, "4/5")
        require(app.buttons["Select Finley Six"]).tap()
        XCTAssertEqual(require(app.staticTexts["SelectedRelationshipCount"]).label, "5/5")
        next.tap()
        require(app.staticTexts["Choose Frequency"])
    }

    func testExerciseHeadersAndUpdatedFunnyClipDurations() {
        require(app.buttons["Exercises"]).tap()
        require(app.buttons["Accepted"]).tap()
        require(app.buttons["DoExercise_belonging-list"]).tap()
        let belongingTitle = require(app.staticTexts["Make a Belonging List"])
        let belongingDescription = require(app.staticTexts["ExerciseDescription"])
        XCTAssertGreaterThan(belongingDescription.frame.minY, belongingTitle.frame.maxY)
        XCTAssertTrue(belongingDescription.isHittable)
        XCTAssertTrue(app.staticTexts["◷ 3–5 min"].exists)

        launch(fixture: "--uitesting-fresh", skipWelcome: true)
        require(app.buttons["Exercises"]).tap()
        require(app.buttons["Calm"]).tap()
        require(app.images["🔥"])
        require(app.staticTexts["7–10 min • New exercise"])
        require(app.buttons["DoExercise_watch-something-funny"]).tap()
        let emojiBadge = require(app.images["ExerciseHeaderEmoji"])
        XCTAssertTrue(emojiBadge.isHittable)
        XCTAssertEqual(emojiBadge.frame.width, 48, accuracy: 1, "Figma uses a 48-point exercise emoji badge")
        XCTAssertEqual(emojiBadge.frame.height, 48, accuracy: 1)
        XCTAssertEqual(emojiBadge.frame.midX, app.frame.midX, accuracy: 1)
        let exercisePreview = XCTAttachment(screenshot: app.screenshot())
        exercisePreview.name = "Watch Something Funny emoji badge"
        exercisePreview.lifetime = .keepAlways
        add(exercisePreview)
        let funnyTitle = require(app.staticTexts["Watch Something Funny"])
        let funnyDescription = require(app.staticTexts["ExerciseDescription"])
        XCTAssertGreaterThan(funnyDescription.frame.minY, funnyTitle.frame.maxY)
        XCTAssertTrue(app.staticTexts["◷ 7–10 min"].exists)
        require(app.staticTexts["About 10 min • Funny animals and pets"])
        require(app.staticTexts["About 7 min • Wanda Sykes stand-up"])
        let firstClip = require(app.buttons["Play Funny Animal Compilation"])
        XCTAssertTrue(firstClip.isHittable)
        app.swipeUp()
        XCTAssertTrue(app.buttons["Play When Life Throws You Earthquakes"].isHittable,
                      "The full-size exercise should remain vertically scrollable")

        launch(fixture: "--uitesting-fresh", skipWelcome: true)
        require(app.buttons["Exercises"]).tap()
        require(app.buttons["Calm"]).tap()
        require(app.buttons["DoExercise_keep-photo-close"]).tap()
        require(app.images["ExerciseHeaderEmoji"])
        require(app.staticTexts["◷ 1–2 min"])
        require(app.buttons["KeepPhotoNextArrowButton"])
    }

    func testExerciseCardsAcrossCareCategories() {
        require(app.buttons["Exercises"]).tap()
        for (category, exerciseID) in [
            ("Calm", "watch-something-funny"),
            ("Accepted", "belonging-list"),
            ("Resonant", "mirror-emotion"),
            ("Energetic", "share-something-new")
        ] {
            require(app.buttons[category]).tap()
            require(app.buttons["DoExercise_\(exerciseID)"])
            let screenshot = XCTAttachment(screenshot: app.screenshot())
            screenshot.name = "\(category) exercise cards"
            screenshot.lifetime = .keepAlways
            add(screenshot)
            require(app.buttons["AppIcon_back"]).tap()
        }
    }

    func testResumedAssessmentBackRestoresPreviousQuestionAndAnswer() {
        launch(fixture: "--uitesting-assessment", skipWelcome: false)
        require(app.buttons["ResumeAssessmentButton"]).tap()
        require(app.staticTexts["Question 2 of 20"])
        require(app.buttons["AppIcon_back"]).tap()
        require(app.staticTexts["Question 1 of 20"])
        XCTAssertTrue(require(app.buttons["AssessmentOption_q1_opt_1"]).isSelected,
                      "Back should restore the previously saved answer")
        XCTAssertFalse(app.staticTexts["Welcome Back"].exists, "Back after resume must stay inside the assessment flow")
    }

    func testFinalAssessmentSubmitSealsEditorAndBlocksAnotherToday() {
        launch(fixture: "--uitesting-final-assessment", skipWelcome: false)
        require(app.buttons["ResumeAssessmentButton"]).tap()
        require(app.staticTexts["Person 5 of 5"])
        require(app.staticTexts["Question 20 of 20"])
        let submit = require(app.buttons["SurveyQuestionSubmitButton"])
        XCTAssertTrue(submit.isEnabled, "All 100 saved answers should make final submission available")
        submit.tap()
        require(app.staticTexts["Survey Results"])

        require(app.buttons["AppIcon_back"]).tap()
        require(app.staticTexts["Welcome Back"])
        XCTAssertFalse(app.staticTexts["Question 20 of 20"].exists,
                       "Back from committed results must never expose the completed editor")
        XCTAssertFalse(app.buttons["ResumeAssessmentButton"].exists,
                       "The completed assessment must no longer appear as a resumable draft")

        require(app.buttons["Assessment"]).tap()
        require(app.staticTexts["You’ve completed an assessment today. You can begin another tomorrow."])
        XCTAssertFalse(require(app.buttons["AssessmentOverviewBeginButton"]).isEnabled,
                       "A second completed assessment must not start on the same local day")
    }

    func testHistoricalTrendPointsOpenTheirOwnSavedResults() {
        launch(fixture: "--uitesting-history", skipWelcome: false)
        require(app.staticTexts["Welcome Back"])
        require(app.buttons["AppIcon_chart"]).tap()
        require(app.staticTexts["Past Results"])
        require(app.staticTexts["Tap a point to view that assessment’s full results."])

        let points = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'View assessment results from'"))
        XCTAssertTrue(points.element(boundBy: 0).waitForExistence(timeout: 8))
        XCTAssertEqual(points.count, 2, "Both saved assessments need independent trend targets")
        points.element(boundBy: 0).tap()
        require(app.staticTexts["Survey Results"])
        require(app.staticTexts["200"])
        findTextByScrolling("Alice History")
        XCTAssertFalse(app.staticTexts["Bob History"].exists)

        require(app.buttons["AppIcon_back"]).tap()
        require(app.staticTexts["Past Results"])
        let recentPoint = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'View assessment results from'"))
        require(recentPoint.element(boundBy: 1)).tap()
        require(app.staticTexts["Survey Results"])
        require(app.staticTexts["400"])
        findTextByScrolling("Bob History")
        XCTAssertFalse(app.staticTexts["Alice History"].exists)
    }

    private func findTextByScrolling(_ text: String) {
        let label = app.staticTexts[text]
        for _ in 0..<8 where !label.exists { app.swipeUp() }
        require(label)
    }

    func testSurveyRelationshipBreakdownInfoOpensRiskGroups() {
        launch(fixture: "--uitesting-history", skipWelcome: false)
        require(app.buttons["AppIcon_chart"]).tap()
        let point = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'View assessment results from'")).element(boundBy: 1)
        require(point).tap()
        require(app.staticTexts["Survey Results"])
        let info = app.buttons["About relational risk groups"]
        for _ in 0..<8 where !info.isHittable { app.swipeUp() }
        XCTAssertTrue(info.isHittable, "Relationship Breakdown should expose its information icon")
        info.tap()
        require(app.staticTexts["Relational Risk Groups"])
        require(app.buttons["AppIcon_back"]).tap()
        require(app.staticTexts["Survey Results"])
    }

    func testQuizDraftIsLabeledAndResumesFromHome() {
        launch(fixture: "--uitesting-quiz", skipWelcome: false)
        require(app.staticTexts["Quiz in Progress"])
        require(app.buttons["Continue"]).tap()
        require(app.staticTexts["Question 2 of 3"])
        require(app.buttons["AppIcon_back"]).tap()
        require(app.staticTexts["Question 1 of 3"])
    }

    func testMirrorPreviewMatchesFigmaFrame() {
        require(app.buttons["Exercises"]).tap()
        require(app.buttons["Resonant"]).tap()
        require(app.staticTexts["Resonant"])
        require(app.buttons["DoExercise_mirror-emotion"]).tap()
        require(app.staticTexts["Mirror the Emotion"])
        let description = require(app.staticTexts["ExerciseDescription"])
        XCTAssertTrue(description.isHittable, "The exercise introduction should be visible without being cropped")
        XCTAssertGreaterThan(description.frame.height, 20)
        let preview = require(app.buttons["MirrorEmotionPreviewButton"])
        XCTAssertLessThan(preview.frame.width, app.frame.width - 40,
                          "Mirror preview should be a bounded card, not screen-wide")
        XCTAssertEqual(preview.frame.width, 350, accuracy: 2,
                       "Mirror preview card should match the Figma 350-point width")
        XCTAssertEqual(preview.frame.height, 493, accuracy: 2,
                       "Mirror preview card should match the Figma 493-point height")
        let mirrorScreenshot = XCTAttachment(screenshot: app.screenshot())
        mirrorScreenshot.name = "Mirror the Emotion layout"
        mirrorScreenshot.lifetime = .keepAlways
        add(mirrorScreenshot)
    }

    func testMirrorDescriptionAndFullScreenClosePlacement() {
        require(app.buttons["Exercises"]).tap()
        require(app.buttons["Resonant"]).tap()
        require(app.buttons["DoExercise_mirror-emotion"]).tap()
        require(app.staticTexts["Mirror the Emotion"])
        require(app.buttons["Tap to play the video"]).tap()
        let close = require(app.buttons["MirrorVideoCloseButton"])
        XCTAssertTrue(close.isHittable)
        XCTAssertLessThan(close.frame.midX, app.frame.midX, "Close should sit on the left, clear of player settings")
        close.tap()
        require(app.staticTexts["Mirror the Emotion"])
    }

    func testConnectionCountdownCompletionSealsExerciseFlow() {
        require(app.buttons["Exercises"]).tap()
        require(app.buttons["Energetic"]).tap()
        require(app.buttons["DoExercise_connection-countdown"]).tap()
        require(app.staticTexts["Connection Countdown"])
        let complete = require(app.buttons["ExerciseFlowAction"])
        XCTAssertFalse(complete.isEnabled, "The required reflection must be entered first")

        require(app.buttons["Today"]).tap()
        let reflection = require(app.descendants(matching: .any)["CountdownLookingForwardField"])
        reflection.tap()
        reflection.typeText("Seeing a friend at lunch")
        XCTAssertTrue(complete.isEnabled)
        complete.tap()
        require(app.staticTexts["Exercise Complete!"])
        require(app.staticTexts["Connection Countdown"])
        require(app.staticTexts["Completed"])
        require(app.staticTexts["1"])

        require(app.buttons["AppIcon_back"]).tap()
        require(app.staticTexts["Welcome Back"])
        XCTAssertFalse(app.staticTexts["Picture the moment"].exists,
                       "Back from completion must not return to the editable exercise")
        XCTAssertFalse(app.staticTexts["Exercises in progress"].exists,
                       "A completed exercise must not remain an in-progress draft")
    }

    func testWatchFunnyCanBeCompletedWithoutPlayingYouTubeVideo() {
        require(app.buttons["Exercises"]).tap()
        require(app.buttons["Calm"]).tap()
        require(app.buttons["DoExercise_watch-something-funny"]).tap()

        let complete = require(app.buttons["Complete Exercise"])
        XCTAssertTrue(complete.isEnabled, "Watching a YouTube video must remain optional")
        complete.tap()

        require(app.staticTexts["Exercise Complete!"])
        require(app.staticTexts["Watch Something Funny"])
        require(app.staticTexts["Completed"])
        require(app.staticTexts["1"])
    }
}
