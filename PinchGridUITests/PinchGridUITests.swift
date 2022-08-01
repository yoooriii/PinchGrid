//
//  PinchGridUITests.swift
//  PinchGridUITests
//
//  Created by Leonid-Yurii-Lokhmatov on 17.07.2022.
//

import XCTest

class PinchGridUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.

        // reset scroll state
        scrollState = ScrollState.none
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    let precision = 0.01
    let pinchUpScale = CGFloat(2.0)
    let pinchDownScale = CGFloat(0.5)
    let pinchScalePrecision = CGFloat(0.2)

    enum ScrollState {
        case top, bottom, none
    }
    var scrollState = ScrollState.none


    func testCentralCellUpscale() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        let gridSize = app.collectionViews.element(boundBy: 0).frame.size
        print("gridSize:\(gridSize)")
        
        let cells = app.collectionViews.cells
        XCTAssert(9 == cells.count, "wrong cells number")
        // get the central cell in the section = 1 & the row = 1 (counting from zero)
        let cell_1_1 = cells.element(matching: .cell, identifier: "[s1,r1]")
        XCTAssert(cell_1_1.exists, "cannot access the central cell")
        
        // get initial cell sizes, before pinch
        let mx0 = cellSizeMatrix(app)
        
        cell_1_1.pinch(withScale: pinchUpScale, velocity: 10.0)
        scrollToBottom(app)
        
        // get result cell sizes, after pinch
        let mx1 = cellSizeMatrix(app)
        
        // make sure the central element got scaled
        // note: the requested scale factor in reality produces a result below expectation (2.0-->1.8)
        let initialSize = mx0[1][1]
        let centralCellSize2 = mx1[1][1]
        let kh = centralCellSize2.width/initialSize.width
        let kv = centralCellSize2.height/initialSize.height
        XCTAssert(pinchUpScale-pinchScalePrecision < kh && kh < pinchUpScale+pinchScalePrecision && precision > abs(kh-kv))
        
        let wb0 = mx0[0][0].width + mx0[0][1].width + mx0[0][2].width
        let wb1 = mx0[1][0].width + mx0[1][1].width + mx0[1][2].width
        let wb2 = mx0[2][0].width + mx0[2][1].width + mx0[2][2].width
        
        let wa0 = mx1[0][0].width + mx1[0][1].width + mx1[0][2].width
        let wa1 = mx1[1][0].width + mx1[1][1].width + mx1[1][2].width
        let wa2 = mx1[2][0].width + mx1[2][1].width + mx1[2][2].width
        
        let hb0 = mx0[0][0].height + mx0[1][0].height + mx0[2][0].height
        let hb1 = mx0[0][1].height + mx0[1][1].height + mx0[2][1].height
        let hb2 = mx0[0][2].height + mx0[1][2].height + mx0[2][2].height
        
        let ha0 = mx1[0][0].height + mx1[1][0].height + mx1[2][0].height
        let ha1 = mx1[0][1].height + mx1[1][1].height + mx1[2][1].height
        let ha2 = mx1[0][2].height + mx1[1][2].height + mx1[2][2].height
        
        // make sure the collection view content size has not change although some cells have
        XCTAssert(areEqual(wb0, wb1) && areEqual(wb0, wb2) && areEqual(wb0, wa0) && areEqual(wb0, wa1) && areEqual(wb0, wa2), "content size widths are not equal \(wb0):\(wb1):\(wb2) -- \(wa0):\(wa1):\(wa2)")
        XCTAssert(areEqual(hb0, hb1) && areEqual(hb0, hb2) && areEqual(hb0, ha0) && areEqual(hb0, ha1) && areEqual(hb0, ha2), "content size widths are not equal \(hb0):\(hb1):\(hb2) -- \(ha0):\(ha1):\(ha2)")
        
        // make sure the result cell width evaluated properly
        let centralCellWidth = mx1[1][1].width
        let centralCellHeight = mx1[1][1].height
        var widths = [CGFloat](repeating: 0, count: 3)
        widths[0] = (wa0 - centralCellWidth)/2.0
        widths[1] = centralCellWidth
        widths[2] = (wa0 - centralCellWidth)/2.0
        for vi in 0...2 {
            for hi in 0...2 {
                XCTAssert(areEqual(widths[hi], mx1[vi][hi].width), "width is wrong at \(vi):\(hi)")
            }
        }
        
        // make sure the result cell height evaluated properly
        var heights = [CGFloat](repeating: 0, count: 3)
        heights[0] = (ha0 - centralCellHeight)/2.0
        heights[1] = centralCellHeight
        heights[2] = (ha0 - centralCellHeight)/2.0
        for vi in 0...2 {
            for hi in 0...2 {
                XCTAssert(areEqual(heights[vi], mx1[vi][hi].height), "height is wrong at \(vi):\(hi)")
            }
        }
    }

    func testCentralCellDownscale() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        let gridSize = app.collectionViews.element(boundBy: 0).frame.size
        print("gridSize:\(gridSize)")

        let cells = app.collectionViews.cells
        XCTAssert(9 == cells.count, "wrong cells number")
        // get the central cell in the section = 1 & the row = 1 (counting from zero)
        let cell_1_1 = cells.element(matching: .cell, identifier: "[s1,r1]")
        XCTAssert(cell_1_1.exists, "cannot access the central cell")

        // get initial cell sizes, before pinch
        let mx0 = cellSizeMatrix(app)

        cell_1_1.pinch(withScale: pinchDownScale, velocity: -10.0)
        scrollToBottom(app)

        // get result cell sizes, after pinch
        let mx1 = cellSizeMatrix(app)

        // make sure the central element got scaled
        // note: the requested scale factor in reality produces a result below expectation (2.0-->1.8)
        let initialSize = mx0[1][1]
        let centralCellSize2 = mx1[1][1]
        let kh = centralCellSize2.width/initialSize.width
        let kv = centralCellSize2.height/initialSize.height
        XCTAssert(pinchDownScale-pinchScalePrecision < kh && kh < pinchDownScale+pinchScalePrecision && precision > abs(kh-kv))
        
        let wb0 = mx0[0][0].width + mx0[0][1].width + mx0[0][2].width
        let wb1 = mx0[1][0].width + mx0[1][1].width + mx0[1][2].width
        let wb2 = mx0[2][0].width + mx0[2][1].width + mx0[2][2].width
        
        let wa0 = mx1[0][0].width + mx1[0][1].width + mx1[0][2].width
        let wa1 = mx1[1][0].width + mx1[1][1].width + mx1[1][2].width
        let wa2 = mx1[2][0].width + mx1[2][1].width + mx1[2][2].width
                
        let hb0 = mx0[0][0].height + mx0[1][0].height + mx0[2][0].height
        let hb1 = mx0[0][1].height + mx0[1][1].height + mx0[2][1].height
        let hb2 = mx0[0][2].height + mx0[1][2].height + mx0[2][2].height
        
        let ha0 = mx1[0][0].height + mx1[1][0].height + mx1[2][0].height
        let ha1 = mx1[0][1].height + mx1[1][1].height + mx1[2][1].height
        let ha2 = mx1[0][2].height + mx1[1][2].height + mx1[2][2].height
        
        // make sure the collection view content size has not change although some cells have
        XCTAssert(areEqual(wb0, wb1) && areEqual(wb0, wb2) && areEqual(wb0, wa0) && areEqual(wb0, wa1) && areEqual(wb0, wa2), "content size widths are not equal \(wb0):\(wb1):\(wb2) -- \(wa0):\(wa1):\(wa2)")
        XCTAssert(areEqual(hb0, hb1) && areEqual(hb0, hb2) && areEqual(hb0, ha0) && areEqual(hb0, ha1) && areEqual(hb0, ha2), "content size heights are not equal \(hb0):\(hb1):\(hb2) -- \(ha0):\(ha1):\(ha2)")

        // make sure the result cell width evaluated properly
        let centralCellWidth = mx1[1][1].width
        let centralCellHeight = mx1[1][1].height
        var widths = [CGFloat](repeating: 0, count: 3)
        widths[0] = (wa0 - centralCellWidth)/2.0
        widths[1] = centralCellWidth
        widths[2] = (wa0 - centralCellWidth)/2.0
        for vi in 0...2 {
            for hi in 0...2 {
                XCTAssert(areEqual(widths[hi], mx1[vi][hi].width), "width is wrong at \(vi):\(hi)")
            }
        }

        // make sure the result cell height evaluated properly
        var heights = [CGFloat](repeating: 0, count: 3)
        heights[0] = (ha0 - centralCellHeight)/2.0
        heights[1] = centralCellHeight
        heights[2] = (ha0 - centralCellHeight)/2.0
        for vi in 0...2 {
            for hi in 0...2 {
                XCTAssert(areEqual(heights[vi], mx1[vi][hi].height), "height is wrong at \(vi):\(hi)")
            }
        }
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    //MARK: - helper functions
    
    private func areEqual(_ x: CGFloat, _ y: CGFloat) -> Bool {
        return precision > abs(x-y)
    }
    
    private func scrollToTop(_ app: XCUIApplication) {
        if scrollState != .top {
            app.collectionViews.cells.element(matching: .cell, identifier: "[s1,r1]").swipeDown()
            scrollState = .top
        }
    }
    
    private func scrollToBottom(_ app: XCUIApplication) {
        if scrollState != .bottom {
            app.collectionViews.cells.element(matching: .cell, identifier: "[s1,r1]").swipeUp()
            scrollState = .bottom
        }
    }
    
    // returns all cell sizes in the collection view
    // note: some cells may be invisible therefore inaccessible,
    // if such a case then scroll the collection view up or down
    private func cellSizeMatrix(_ app: XCUIApplication) -> [[CGSize]] {
        var mx: [[CGSize]] = Array(repeating: Array(repeating: CGSize.zero, count: 3), count: 3)
        for si in 0...2 {
            scrollToTop(app)
            var doScroll = false
            for rep in 0...1 {
                for ri in 0...2 {
                    let id = "[s\(si),r\(ri)]"
                    let cell = app.collectionViews.cells.element(matching: .cell, identifier: id)
                    if !cell.exists {
                        XCTAssert(0==rep, "cannot access the collection view cell at \(id)")
                        doScroll = true
                        continue
                    }
                    mx[si][ri] = cell.frame.size
                }
                if !doScroll {
                    break
                }
                // scroll and repeat this step
                doScroll = false
                scrollToBottom(app)
            }
        }
        return mx
    }
    
    

}
