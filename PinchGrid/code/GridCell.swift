//
//  GridCell.swift
//  PinchGrid
//
//  Created by Leonid-Yurii-Lokhmatov on 17.07.2022.
//

import Foundation
import UIKit

class GridCell : UICollectionViewCell {
    @IBOutlet var textLabel: UILabel?
    @IBOutlet var titleLabel: UILabel?
    var recognizer: UIGestureRecognizer?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        recognizer = UIPinchGestureRecognizer()
        addGestureRecognizer(recognizer!)
        
        layer.borderColor = UIColor.blue.cgColor
        layer.borderWidth = 1
    }
}
