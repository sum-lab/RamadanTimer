//
//  CustomCollectionViewLayout.swift
//  RamadanTimer
//
//  Created by Sumayyah on 16/06/17.
//  Copyright © 2017 Sumayyah. All rights reserved.
//

import UIKit

class CustomCollectionViewLayout: UICollectionViewLayout {
    
    var numberOfColumns = 4
    var itemAttributes = [[UICollectionViewLayoutAttributes]]()
    var itemsSize = [CGSize]()
    var contentSize: CGSize!
    
    // returns true to call prepare() on every scroll
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    // layout visible items
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        for section in self.itemAttributes {
            attributes += section.filter { rect.intersects($0.frame) }
        }
        return attributes
    }
    
    // return attributes for given index path
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemAttributes[indexPath.section][indexPath.row]
    }
    
    override var collectionViewContentSize: CGSize {
        return self.contentSize
    }
    
    override func prepare() {
        // if no sections, return
        if collectionView?.numberOfSections == 0 {
            return
        }
        itemAttributes.removeAll()
        
        itemsSize.removeAll()
        self.calculateItemsSize()
        
        var column = 0
        var xOffset : CGFloat = 0
        var yOffset : CGFloat = 0
        var contentWidth : CGFloat = 0
        var contentHeight : CGFloat = 0
        
        for section in 0..<self.collectionView!.numberOfSections {
            var sectionAttributes = [UICollectionViewLayoutAttributes]()
            
            for index in 0..<numberOfColumns {
                let itemSize = self.itemsSize[index]
                let indexPath = IndexPath(item: index, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x:xOffset, y:yOffset, width:itemSize.width, height:itemSize.height).integral
                
                if section == 0 && index == 0 {
                    attributes.zIndex = 1024;
                } else  if section == 0 || index == 0 {
                    attributes.zIndex = 1023
                }
                
                if section == 0 {
                    var frame = attributes.frame
                    frame.origin.y = self.collectionView!.contentOffset.y
                    attributes.frame = frame
                }
                if index == 0 {
                    var frame = attributes.frame
                    frame.origin.x = self.collectionView!.contentOffset.x
                    attributes.frame = frame
                }
                
                sectionAttributes.append(attributes)
                
                xOffset += itemSize.width
                column += 1
                
                if column == numberOfColumns {
                    if xOffset > contentWidth {
                        contentWidth = xOffset
                    }
                    
                    column = 0
                    xOffset = 0
                    yOffset += itemSize.height
                }
            }
            self.itemAttributes.append(sectionAttributes)
        }
        
        let attributes : UICollectionViewLayoutAttributes = self.itemAttributes.last!.last!
        contentHeight = attributes.frame.origin.y + attributes.frame.size.height
        self.contentSize = CGSize(width:contentWidth, height:contentHeight)
    }
    
    func sizeForItemWithColumnIndex(columnIndex: Int) -> CGSize {
        if UIDevice.current.userInterfaceIdiom == .pad || UIApplication.shared.statusBarOrientation.isLandscape {
            return CGSize(width: (collectionView?.bounds.width)!/4, height: 30)
        }
        var text : String = ""
        switch (columnIndex) {
        case 0:
            text = "30 Ramadan 1438"
        case 1:
            text = "Jun 31, 2017"
        case 2:
            text = "04:30 AM"
        case 3:
            text = "07:30 PM"
        default:
            text = "Col 4"
        }
        
        let size : CGSize = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17.0)])
        let width : CGFloat = size.width + 25
        return CGSize(width:width, height:30)
    }
    
    func calculateItemsSize() {
        for index in 0..<numberOfColumns {
            self.itemsSize.append(self.sizeForItemWithColumnIndex(columnIndex: index))
        }
    }
}
