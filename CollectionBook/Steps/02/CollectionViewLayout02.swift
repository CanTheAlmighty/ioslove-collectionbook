//
//  CollectionViewLayout02.swift
//  CollectionBook
//
//  Created by Jose Luis Canepa on 3/28/18.
//  Copyright © 2018 Jose Luis Canepa. All rights reserved.
//
//  CMD+F "NEW:" to see what's been added

import UIKit

final class CollectionViewLayout02 : UICollectionViewLayout
{
    enum SupplementaryKind : String
    {
        case header
    }
    
    var headerHeight     : CGFloat = 60.0
    var columns          : Int     = 5
    var attributesCell   : [IndexPath : UICollectionViewLayoutAttributes] = [:]
    var attributesHeader : [IndexPath : UICollectionViewLayoutAttributes] = [:] // NEW: Now it's a dictionary
    
    // MARK: - Preparation
    
    override func prepare()
    {
        guard let collectionView = collectionView else { return }
        
        // NEW: We need to layout every section now
        for section in 0 ..< collectionView.numberOfSections
        {
            let items = collectionView.numberOfItems(inSection: section)
            
            for item in 0 ..< items
            {
                let indexPath = IndexPath(item: item, section: section)
                
                attributesCell[indexPath] = layoutAttributesForItem(at: indexPath)
            }
            
            // NEW: Layout the header, only if we have elements inside it
            if items > 0
            {
                let indexPath = IndexPath(item: 0, section: section)
                attributesHeader[indexPath] = layoutAttributesForSupplementaryView(ofKind: SupplementaryKind.header.rawValue, at: indexPath)
            }
        }
    }
    
    // MARK: - Individual Layout
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        // Create the attributes
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        // NEW: Obtain the offset cumulatively (also, this is inefficient, since its being done each section N times),
        // will be improved later.
        let offset = cumulativeOffset(for: indexPath.section)
        
        let origin = CGPoint(x: cellSize.width * CGFloat(indexPath.item % columns),
                             y: cellSize.height * CGFloat(indexPath.item / columns) + headerHeight + offset)
        attributes.frame = CGRect(origin: origin, size: cellSize)
        
        return attributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        guard let collectionView = collectionView else { return nil }
        
        // NEW: Obtain the offset
        let offset = cumulativeOffset(for: indexPath.section)
        
        // Create the attributes
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: SupplementaryKind.header.rawValue, with: indexPath)
        attributes.frame = CGRect(x: 0, y: offset, width: collectionView.frame.size.width, height: headerHeight)
        
        return attributes
    }
    
    // MARK: - Layout
    
    override var collectionViewContentSize: CGSize
    {
        guard let collectionView = collectionView else { return .zero }
        
        var size : CGSize = .zero
        size.width  = collectionView.frame.size.width
        size.height = cumulativeOffset()
        
        return size
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        var attributes = attributesCell.values.filter
        {
            (attribute) -> Bool in
            
            return rect.intersects(attribute.frame)
        }
        
        // NEW: Now add all the headers that intersect
        attributes.append(contentsOf: attributesHeader.values.filter({ rect.intersects($0.frame) }))
        
        return attributes
    }
    
    // NEW: Math now extracted into functions to avoid redundant code
    // MARK: - Math
    
    private var cellSize : CGSize
    {
        guard let collectionView = collectionView else { return .zero }
        
        // Calculate each cell's width (and height, assuming square), which is how many columns we want.
        let width = (collectionView.frame.size.width / CGFloat(columns)).rounded(.down)
        
        return CGSize(width: width, height: width)
    }
    
    /// Produces the total height up until the given section
    ///
    /// - Parameter section: The section to get its vertical offset, if `nil`, the entire height is produced.
    /// - Returns: The total height up until the givne section, or total if section is `nil`.
    private func cumulativeOffset(for section : Int? = nil) -> CGFloat
    {
        guard let collectionView = collectionView else { return 0 }
        
        let size = cellSize
        let limit : Int
        
        if let section = section, section < collectionView.numberOfSections
        {
            limit = section
        }
        else
        {
            limit = collectionView.numberOfSections
        }
        
        var height : CGFloat = 0.0
        
        for section in 0 ..< limit
        {
            let items = collectionView.numberOfItems(inSection: section)
            
            // Ignore empty sections
            guard items > 0 else { continue }
            
            // Calculate the rows
            let rows = (CGFloat(items) / CGFloat(columns)).rounded(.up)
            
            // Add up the height
            height += rows * size.height
            
            // Add up the section header
            height += headerHeight
        }
        
        return height
    }
}




















