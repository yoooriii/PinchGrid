//
//  GridViewController.swift
//  PinchGrid
//
//  Created by Leonid-Yurii-Lokhmatov on 17.07.2022.
//

import UIKit

class GridViewController: UIViewController {
    
    @IBOutlet var grid: UICollectionView?
    @IBOutlet var layout: UICollectionViewFlowLayout?
    @IBOutlet var gridLayout: GridLayout?
    var text: [String]?
    var hasAppeared = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let filepath = Bundle.main.path(forResource: "book", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                let arr = contents.components(separatedBy: CharacterSet.newlines)
                text = arr.filter({ !$0.isEmpty })
                print("contents: \(String(describing: text?.count)) : \(arr.count)")
            } catch {
                print("contents could not be loaded \(error)")
            }
        } else {
            print(".txt not found!")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !hasAppeared {
            // do it once only on the 1 appearance
            hasAppeared = true

            if let layout = gridLayout {
                // setup layout on the 1st appearance
                var size = view.bounds.size
                size.height *= 1.2
                size.width *= 1.2
                layout.setupMatrix(rows: 3, columns: 3, contentSize: size)
            }
        }
    }
    
    @IBAction func updateIt(_ sender: UIBarButtonItem) {
        var size = view.bounds.size
        size.height *= 1.2
        size.width *= 1.2
        gridLayout!.setContentSize(size)
        gridLayout!.distributeEqually()
    }

    @objc func pinchAction(_ gestureRecognizer: UIPinchGestureRecognizer) {
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let s = gestureRecognizer.scale
            
            if let cell = gestureRecognizer.view as? GridCell {
                if let indexPath = grid?.indexPath(for: cell) {
                    gridLayout!.scaleItem(s, row: indexPath.section, column: indexPath.row)
                }
            }
            
            gestureRecognizer.scale = 1.0
        }
    }
}


extension GridViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gridLayout!.rowCount
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return gridLayout!.columnCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "idGridCell", for: indexPath) as! GridCell
        cell.titleLabel?.text = "[\(indexPath.section) \(indexPath.row)]"
        cell.recognizer?.addTarget(self, action: #selector(pinchAction(_:)))
        
        let indx = indexPath.section * 3 + indexPath.row
        let str = text?[indx]
        cell.textLabel?.text = str
        cell.accessibilityLabel = "[s\(indexPath.section),r\(indexPath.row)]"

        return cell
    }
}
