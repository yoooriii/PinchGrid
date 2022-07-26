//
//  GridLayout.swift
//  PinchGrid
//
//  Created by Leonid-Yurii-Lokhmatov on 19.07.2022.
//

import UIKit
import simd

class GridLayout: UICollectionViewLayout {
    private var allWidths = [CGFloat]()  // column width
    private var allHeights = [CGFloat]() // row height
    private var contentSize = CGSize.zero
    
    private let maxK = CGFloat(0.8)
    private let minK = CGFloat(0.1)
    
    var rowCount: Int { get {
        allHeights.count + 1
    } }
    var columnCount: Int { get {
        allWidths.count + 1
    } }
    
    //MARK: - implementation, override layout methods

    // Implement -layoutAttributesForElementsInRect: to return layout attributes for for supplementary or decoration views, or to perform layout in an as-needed-on-screen fashion.
    // Additionally, all layout subclasses should implement -layoutAttributesForItemAtIndexPath: to return layout attributes instances on demand for specific index paths.
    // If the layout supports any supplementary or decoration view types, it should also implement the respective atIndexPath: methods for those types.
    // return an array layout attributes instances for all the views in the given rect
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let rangeX = findRange(min: rect.minX/contentSize.width, max: rect.maxX/contentSize.width, in: allWidths)
        let rangeY = findRange(min: rect.minY/contentSize.height, max: rect.maxY/contentSize.height, in: allHeights)
        var attributes = [UICollectionViewLayoutAttributes]()
        for rx in rangeX {
            for ry in rangeY {
                if let a = layoutAttributesForItem(at: IndexPath(row: rx, section: ry)) {
                    attributes.append(a)
                }
            }
        }
        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        assert(indexIsValid(row: indexPath.section, column: indexPath.row), "Index out of range")
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = itemFrame(row: indexPath.section, column: indexPath.row)
        return attributes
    }
    
    // Subclasses must override this method and use it to return the width and height of the collection view’s content. These values represent the width and height of all the content, not just the content that is currently visible. The collection view uses this information to configure its own content size to facilitate scrolling.
    override var collectionViewContentSize: CGSize { get {
        contentSize
    } }
    
    // The collection view calls -prepareLayout once at its first layout as the first message to the layout instance.
    // The collection view calls -prepareLayout again after layout is invalidated and before requerying the layout information.
    // Subclasses should always call super if they override.
    override func prepare() {
        super.prepare()
    }

    //MARK: - custom methods
    
    public func setupMatrix(rows: Int, columns: Int, contentSize: CGSize) {
        assert(rows >= 2)
        assert(columns >= 2)
        
        let elementWidth = 1.0 / CGFloat(columns)
        let elementHeight = 1.0 / CGFloat(rows)
        
        allWidths = Array(repeating: elementWidth, count: columns - 1)
        allHeights = Array(repeating: elementHeight, count: rows - 1)
        
        self.contentSize = contentSize
        invalidateLayout()
    }
    
    public func scaleItem(_ scale: CGFloat, row: Int, column: Int) {
        assert(indexIsValid(row: row, column: column), "Index out of range")
        scaleN(scale, index: column, array: &allWidths)
        scaleN(scale, index: row, array: &allHeights)
        invalidateLayout()
    }
    
    public func distributeEqually() {
        setupMatrix(rows: rowCount, columns: columnCount, contentSize: contentSize)
        invalidateLayout()
    }
    
    public func setContentSize(_ size: CGSize) {
        contentSize = size
        invalidateLayout()
    }
    
    //MARK: - private methods

    private func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row <= allHeights.count && column >= 0 && column <= allWidths.count
    }
    
    private func scaleN(_ scale: CGFloat, index: Int, array: inout [CGFloat]) {
        assert(index <= array.count, "Index out of range")
        
        let kOld = (index < array.count) ? array[index] : (CGFloat(1) - array.reduce(0, +))
        let kNew = simd_clamp(kOld * scale, minK, maxK)
        
        let kk = (CGFloat(1) - kNew) / (CGFloat(1) - kOld)
        
        for i in 0..<array.count {
            if i == index {
                array[i] = kNew
            } else {
                let ai = array[i]
                array[i] = ai * kk
            }
        }
    }
    
    private func itemFrame(row: Int, column: Int) -> CGRect {
        assert(column <= allWidths.count)
        assert(row <= allHeights.count)
        
        let szHK = itemNormSize(position: column, array: allWidths)
        let szVK = itemNormSize(position: row, array: allHeights)
        return CGRect(x: szHK.0 * contentSize.width, y: szVK.0 * contentSize.height, width: szHK.1 * contentSize.width, height: szVK.1 * contentSize.height)
    }
    
    // get item normalized position & size
    private func itemNormSize(position: Int, array: [CGFloat]) -> (CGFloat, CGFloat) {
        assert(position <= array.count)
        
        var sk = CGFloat.zero
        var ki = CGFloat.zero
        for i in 0...position {
            ki = (i < array.count) ? array[i] : (1.0 - sk)
            if i != position {
                sk += ki
            }
        }
        return (sk, ki)
    }
    
    // find indices in normalized range
    func findRange(min: CGFloat, max: CGFloat, in array: [CGFloat]) -> Range<Int> {
        var x = CGFloat.zero
        
        var idxStart = -1
        for i in 0...array.count {
            if i < array.count {
                x += array[i]
            } else {
                x = 1.0
            }
            
            if x >= min {
                // start index found
                idxStart = i
                break
            }
        }
        
        if idxStart < 0 || idxStart > array.count {
            // empty range, the array does not contain the [min-max] range
            return 0..<0
        }

        if idxStart == array.count {
            // the last item
            return array.count..<(1 + array.count)
        }

        var idxEnd = -1
        for i in (1 + idxStart)...array.count {
            if x >= max {
                // end index found
                idxEnd = i
                break
            }
            if i < array.count {
                x += array[i]
            } else {
                x = 1.0
            }
        }
        
        return (idxEnd < 0) ? idxStart..<(1 + array.count) : idxStart..<idxEnd
    }
}
