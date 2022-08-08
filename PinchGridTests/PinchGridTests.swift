//
//  PinchGridTests.swift
//  PinchGridTests
//
//  Created by Leonid-Yurii-Lokhmatov on 17.07.2022.
//

import XCTest
@testable import PinchGrid

class PinchGridTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
   
    func testFindRangeFunc() throws {
        let layout = GridLayout()
        layout.setupMatrix(rows: 5, columns: 5, contentSize: CGSize(width: 100, height: 100))
        let arr1 = [CGFloat](repeating: 0.1, count: 9)
        
        var r = 0..<0
        
        var min = CGFloat(0)
        var max = CGFloat(0.09)
        
        r = layout.findRange(min: min, max: max, in: arr1)
        XCTAssert(r == 0..<1, "wrong range \(r) in [\(min), \(max)]")

        min = 0.01; max = 0.09
        r = layout.findRange(min: min, max: max, in: arr1)
        XCTAssert(r == 0..<1, "wrong range \(r) in [\(min), \(max)]")
        
        min = 0.01; max = 0.11
        r = layout.findRange(min: min, max: max, in: arr1)
        XCTAssert(r == 0..<2, "wrong range \(r) in [\(min), \(max)]")
        
        min = 0.45; max = 1.5
        r = layout.findRange(min: min, max: max, in: arr1)
        XCTAssert(r == 4..<10, "wrong range \(r) in [\(min), \(max)]")
        
        min = 0.45; max = 0.65
        r = layout.findRange(min: min, max: max, in: arr1)
        XCTAssert(r == 4..<7, "wrong range \(r) in [\(min), \(max)]")
        
        min = 0.05; max = 0.15
        r = layout.findRange(min: min, max: max, in: arr1)
        XCTAssert(r == 0..<2, "wrong range \(r) in [\(min), \(max)]")
        
        min = 0.15; max = 0.25
        r = layout.findRange(min: min, max: max, in: arr1)
        XCTAssert(r == 1..<3, "wrong range \(r) in [\(min), \(max)]")
    }
    
    func testInitialItemSize() throws {
        let layout = GridLayout()
        let w0 = CGFloat(100)
        let h0 = CGFloat(200)
        layout.setupMatrix(rows: 3, columns: 3, contentSize: CGSize(width: w0 * 3.0, height: h0 * 3.0))
        for ri in 0...2 {
            for ci in 0...2 {
                if let attr = layout.layoutAttributesForItem(at: IndexPath(row: ri, section: ci)) {
                    let rect = CGRect(x: w0 * CGFloat(ri), y: h0 * CGFloat(ci), width: w0, height: h0)
                    XCTAssert(areRectsEqual(attr.frame, rect), "wrong attributes.frame for item at row:column [\(ri):\(ci)] \n \(rect) --> \(attr.frame)")
                } else {
                    XCTAssert(false, "no attributes for item at row:column [\(ri):\(ci)]")
                }
            }
        }
    }
    
    func testScaledCentralItemSize() throws {
        let layout = GridLayout()
        let w0 = CGFloat(100)
        let h0 = CGFloat(200)
        layout.setupMatrix(rows: 3, columns: 3, contentSize: CGSize(width: w0 * 3.0, height: h0 * 3.0))
        layout.scaleItem(2.0, row: 1, column: 1)
        var widths = [CGFloat](repeating: 0, count: 3)
        widths[0] = w0/2.0
        widths[1] = w0*2.0
        widths[2] = w0/2.0
        var heights = [CGFloat](repeating: 0, count: 3)
        heights[0] = h0/2.0
        heights[1] = h0*2.0
        heights[2] = h0/2.0

        for ri in 0...2 {
            let sub = widths[0...ri]
            let x = sub.reduce(0, +)

            for ci in 0...2 {
                var y = CGFloat(0)
                for i in 0...ci {
                    y += heights[i]
                }

                if let attr = layout.layoutAttributesForItem(at: IndexPath(row: ri, section: ci)) {
                    let rect = CGRect(x: x, y: y, width: w0, height: h0)
                    XCTAssert(areRectsEqual(attr.frame, rect), "wrong attributes.frame for item at row:column [\(ri):\(ci)] \n \(rect) --> \(attr.frame)")
                } else {
                    XCTAssert(false, "no attributes for item at row:column [\(ri):\(ci)]")
                }
            }
        }
    }
    
    func testExample_03() throws {
        let layout = GridLayout()
        layout.setupMatrix(rows: 10, columns: 10, contentSize: CGSize(width: 1000, height: 2000))
        let rect = CGRect(x: 299, y: 0, width: 199, height: 299)
        let attr = layout.layoutAttributesForElements(in: rect)
        if let attr = attr {
            print("layoutAttributes:rect:\(rect) -> [\(attr.count)]: ")
            for a in attr {
                print("\(a.indexPath): \(a.frame)")
            }
        } else {
            print("layoutAttributes:rect:\(rect) -> <nil>")
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    //MARK: - helper functions
    
    let precision = CGFloat(0.01)
    
    func areRectsEqual(_ r1: CGRect, _ r2: CGRect) -> Bool {
        return precision > abs(r1.minX - r2.minX) &&
        precision > abs(r1.width - r2.width) &&
        precision > abs(r1.minY - r2.minY) &&
        precision > abs(r1.height - r2.height)
    }
}
