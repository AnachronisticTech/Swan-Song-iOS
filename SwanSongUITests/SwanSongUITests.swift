//
//  SwanSongUITests.swift
//  SwanSongUITests
//
//  Created by Daniel Marriner on 10/08/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import XCTest

class SwanSongUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        snapshot("0 Albums")
//        let list = app.tables["albumList"]
//        XCTAssert(list.exists, "Table does not exist")
//        let cells = list.cells
//        XCTAssert(cells.count > 0, "Table had zero rows")
//        let cell = cells.element(boundBy: 0)
//        XCTAssert(cell.exists, "First cell does not exist")
//        cell.tap()
        app.tables["albumList"].staticTexts["Angel (Original Television Soundtrack)"].tap()
        // snapshot("1 Album")

        app.tabBars.buttons["Genres"].tap()
        let itemButton = app.navigationBars["Genres"].buttons["Item"]
        itemButton.tap()
        snapshot("2 Genres")
        itemButton.tap()
//        let list2 = app.tables["genreList"]
//        XCTAssert(list2.exists, "Table does not exist")
//        let cells2 = list2.cells
//        XCTAssert(cells2.count > 0, "Collection had zero cells")
//        let cell2 = cells2.element(boundBy: 1)
//        XCTAssert(cell2.exists, "Cell does not exist")
//        cell2.tap()
        app.tables["genreList"].staticTexts["Disco"].tap()
        snapshot("3 Genre")

        app.tabBars.buttons["Songs"].tap()
        snapshot("4 Songs")
        app.tables.staticTexts["Big Night"].tap()
        snapshot("5 PlayerLight")
        app.buttons["playButton"].tap()

        app.tabBars.buttons["Settings"].tap()
        app.tables/*@START_MENU_TOKEN@*/.buttons["Dark"]/*[[".cells",".segmentedControls.buttons[\"Dark\"]",".buttons[\"Dark\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Settings"].buttons["Play"].tap()
        snapshot("6 PlayerDark")
        app.buttons["playButton"].tap()
        app.tables/*@START_MENU_TOKEN@*/.buttons["Auto"]/*[[".cells",".segmentedControls.buttons[\"Auto\"]",".buttons[\"Auto\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
