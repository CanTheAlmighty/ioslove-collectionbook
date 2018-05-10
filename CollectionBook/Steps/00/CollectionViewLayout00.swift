//
//  CollectionViewLayout00.swift
//  CollectionBook
//
//  Created by Jose Luis Canepa on 3/28/18.
//  Copyright © 2018 Jose Luis Canepa. All rights reserved.
//

import UIKit

final class CollectionViewLayout00 : UICollectionViewLayout
{
    var columns    : Int = 5
    var attributes : [IndexPath : UICollectionViewLayoutAttributes] = [:]
    
    // MARK: - Preparation
    
    override func prepare()
    {
        guard let collectionView = collectionView else { return }
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0)
        {
            let indexPath = IndexPath(item: item, section: 0)
            
            attributes[indexPath] = layoutAttributesForItem(at: indexPath)
        }
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
                                  y: cellSize * CGFloat(indexPath.item / columns),
                                  width: cellSize,
                                  height: cellSize)
        
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
        size.height = rows * cellSize
        
        return size
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        return attributes.values.filter
        {
            (attribute) -> Bool in
            
            return rect.intersects(attribute.frame)
        }
    }
}
