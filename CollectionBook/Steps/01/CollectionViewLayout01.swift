//
//  CollectionViewLayout01.swift
//  CollectionBook
//
//  Created by Jose Luis Canepa on 3/28/18.
//  Copyright © 2018 Jose Luis Canepa. All rights reserved.
//
//  CMD+F "NEW:" to see what's been added

import UIKit

final class CollectionViewLayout01 : UICollectionViewLayout
{
    // NEW: We can keep all our supplementary kinds in here, instead of loose Strings
    enum SupplementaryKind : String
    {
        case header
    }
    
    var headerHeight     : CGFloat = 60.0
    var columns          : Int     = 5
    var attributesCell   : [IndexPath : UICollectionViewLayoutAttributes] = [:]
    var attributesHeader : UICollectionViewLayoutAttributes? = nil // NEW: Holds the attributes for the header element
    
    // MARK: - Preparation
    
    override func prepare()
    {
        guard let collectionView = collectionView else { return }
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0)
        {
            let indexPath = IndexPath(item: item, section: 0)
            
            attributesCell[indexPath] = layoutAttributesForItem(at: indexPath)
        }
        
        // NEW: Layout the header
        attributesHeader = layoutAttributesForSupplementaryView(ofKind: SupplementaryKind.header.rawValue, at: IndexPath(item: 0, section: 0))
    }
    
    // MARK: - Individual Layout
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        guard let collectionView = collectionView else { return nil }
        
        // Create the attributes
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        // Calculate each cell's width (and height, assuming square), which is how many columns we want.
        let cellSize = (collectionView.frame.size.width / CGFloat(columns)).rounded(.down)
        
        attributes.frame = CGRect(x: cellSize * CGFloat(indexPath.item % columns),
                                  y: cellSize * CGFloat(indexPath.item / columns) + headerHeight, // NEW: Header height must be considered in the offset
                                  width: cellSize,
                                  height: cellSize)
        
        return attributes
    }
    
    // NEW: Added the layout attributes for supplementary
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        guard let collectionView = collectionView else { return nil }
        
        // Create the attributes
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: SupplementaryKind.header.rawValue, with: indexPath)
        attributes.frame = CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: headerHeight)
        
        return attributes
    }
    
    // MARK: - Layout
    
    override var collectionViewContentSize: CGSize
    {
        guard let collectionView = collectionView else { return .zero }
        
        var size : CGSize = .zero
        
        let cellSize =         (collectionView.frame.size.width             / CGFloat(columns)).rounded(.down)
        let rows     = (CGFloat(collectionView.numberOfItems(inSection: 0)) / CGFloat(columns)).rounded(.up)
        
        size.width  = collectionView.frame.size.width
        size.height = rows * cellSize + headerHeight // NEW: Header height will occupy some of the total space.
        
        return size
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        var attributes = attributesCell.values.filter
        {
            (attribute) -> Bool in
            
            return rect.intersects(attribute.frame)
        }
        
        // NEW: If it contains the first row, then show the header,
        // this saves us from doing two intersection operations
        if attributes.contains(where: { $0.indexPath == IndexPath(row: 0, section: 0) }), let header = attributesHeader
        {
            attributes.append(header)
        }
        
        return attributes
    }
}




















