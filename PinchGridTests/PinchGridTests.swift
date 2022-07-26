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
}
