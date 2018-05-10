//
//  CollectionViewLayout03.swift
//  CollectionBook
//
//  Created by Jose Luis Canepa on 3/28/18.
//  Copyright © 2018 Jose Luis Canepa. All rights reserved.
//
//  CMD+F "NEW:" to see what's been added

import UIKit

final class CollectionViewLayout03 : UICollectionViewLayout
{
    enum SupplementaryKind : String
    {
        case header
    }
    
    // NEW: Metrics now combine all the custom information, for easier invalidation
    struct Metrics
    {
        struct Header
        {
            var height : CGFloat = 60.0
        }
        
        struct Grid
        {
            var columns : Int = 5
        }
        
        var header = Header()
        var grid   = Grid()
    }
    
    // NEW: Storage for all the pre-calculated data
    struct DerivedMetrics
    {
        /// The precomputed height of each section
        var offsets : [CGFloat] = []
        
        /// Each cell size
        var cellSize : CGSize
        
        init(metrics : Metrics, collectionView : UICollectionView)
        {
            // Calculate each cell's width (and height, assuming square), which is how many columns we want.
            let side = (collectionView.frame.size.width / CGFloat(metrics.grid.columns)).rounded(.down)
            
            // Calculate each sections expected height cumulatively
            var offsets : [CGFloat] = Array<CGFloat>(repeating: 0.0, count: collectionView.numberOfSections + 1)
            var height : CGFloat = 0.0
            
            for section in 0 ..< collectionView.numberOfSections
            {
                let items = collectionView.numberOfItems(inSection: section)
                
                // Ignore empty sections
                guard items > 0 else { continue }
                
                // Calculate the rows
                let rows = (CGFloat(items) / CGFloat(metrics.grid.columns)).rounded(.up)
                
                // Add up the height
                height += rows * side
                
                // Add up the section header
                height += metrics.header.height
                
                // Save it
                offsets[section+1] = height
            }
            
            self.offsets  = offsets
            self.cellSize = CGSize(width: side, height: side)
        }
    }
    
    // NEW: Metrics and derived metrics now saved as properties
    var metrics : Metrics = Metrics()
    {
        didSet
        {
            // Re-calculate the derived metrics
            derived = DerivedMetrics(metrics: metrics, collectionView: collectionView!)
            invalidateLayout()
        }
    }
    
    private lazy var derived : DerivedMetrics = DerivedMetrics(metrics: metrics, collectionView: collectionView!)
    
    var attributesCell   : [IndexPath : UICollectionViewLayoutAttributes] = [:]
    var attributesHeader : [IndexPath : UICollectionViewLayoutAttributes] = [:]
    
    // MARK: - Preparation
    
    override func prepare()
    {
        guard let collectionView = collectionView else { return }
        
        for section in 0 ..< collectionView.numberOfSections
        {
            let items = collectionView.numberOfItems(inSection: section)
            
            for item in 0 ..< items
            {
                let indexPath = IndexPath(item: item, section: section)
                
                // NEW: We avoid re-laying out the same cell, now invalidations tell us when to layout
                guard attributesCell[indexPath] == nil else { continue }
                
                attributesCell[indexPath] = layoutAttributesForItem(at: indexPath)
            }
            
            if items > 0
            {
                let indexPath = IndexPath(item: 0, section: section)
                
                // NEW: Same as above, specially important, since we will be invalidating this attributes constantly.
                guard attributesHeader[indexPath] == nil else { continue }
                
                attributesHeader[indexPath] = layoutAttributesForSupplementaryView(ofKind: SupplementaryKind.header.rawValue, at: indexPath)
            }
        }
    }
    
    // MARK: - Individual Layout
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        // Create the attributes
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        // NEW: We obtain the offset from the derived metric information
        let offset = derived.offsets[indexPath.section]
        
        let origin = CGPoint(x: derived.cellSize.width  * CGFloat(indexPath.item % metrics.grid.columns),
                             y: derived.cellSize.height * CGFloat(indexPath.item / metrics.grid.columns) + metrics.header.height + offset)
        
        attributes.frame = CGRect(origin: origin, size: derived.cellSize)
        
        return attributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        guard let collectionView = collectionView else { return nil }
        
        // NEW: We obtain the offset from the derived metric information
        var offset = derived.offsets[indexPath.section]
        
        // NEW: We consider the actual contents offsets to make objects "stick"
        let contentOffset = collectionView.bounds.origin.y
        
        // NEW: Now, the following logic is tricky, we can easily make headers stick, but if we want them to push
        // each other, we need some math.
        //
        // So first, we only care about headers that are prior to the current content offset, because all of the rest
        // will be much lower in the scroll to get stickied.
        if contentOffset > offset
        {
            // If the current offset is before the next header, then stick it to the top
            if contentOffset < derived.offsets[indexPath.section+1] - metrics.header.height
            {
                // (make its y-offset the same as the scroll view's)
                offset = collectionView.bounds.origin.y
            }
            else
            {
                // If we're in here, this means we are a header that is getting "stacked out" of sight.
                // So we "unstick" the header (no longer attached to the content offset), and we make it equivalent
                // to the position where the next header _should be_, minus its height so it sits just above the next
                // header.
                //
                // This creates the illusion of being "pushed out", but in reality, this offset is a constant, is the
                // next header in line that gets the sticky treatment, and this one scrolls normally, albeit offseted.
                offset = derived.offsets[indexPath.section+1] - metrics.header.height
            }
            
        }
        
        // Create the attributes
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: SupplementaryKind.header.rawValue, with: indexPath)
        attributes.frame = CGRect(x: 0, y: offset, width: collectionView.frame.size.width, height: metrics.header.height)
        
        // NEW: We modify the z-index, to keep the header above all other cells (otherwise, it gets hidden behind)
        attributes.zIndex = collectionView.numberOfItems(inSection: indexPath.section) + 1
        
        return attributes
    }
    
    // MARK: - Layout
    
    override var collectionViewContentSize: CGSize
    {
        guard let collectionView = collectionView else { return .zero }
        
        var size : CGSize = .zero
        size.width  = collectionView.frame.size.width
        size.height = derived.offsets[collectionView.numberOfSections]
        
        return size
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        var attributes = attributesCell.values.filter
        {
            (attribute) -> Bool in
            
            return rect.intersects(attribute.frame)
        }
        
        attributes.append(contentsOf: attributesHeader.values.filter({ rect.intersects($0.frame) }))
        
        return attributes
    }
    
    // NEW: All new
    // MARK: - Invalidation
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool
    {
        // NEW: We need to remove all things when scrolling (bounds change)
        return true
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext
    {
        // NEW: Invalidation context needs to be brought from super
        let context = super.invalidationContext(forBoundsChange: newBounds)

        let indexPaths = attributesHeader.values.map { $0.indexPath }

        // NEW: Inefficient, but we invalidate only the headers, since they are the ones that we're messing with
        if indexPaths.count > 0
        {
            context.invalidateSupplementaryElements(ofKind: SupplementaryKind.header.rawValue, at: indexPaths)
        }

        return context
    }
    
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext)
    {
        defer
        {
            // Super needs to be called ALWAYS, otherwise the prepare-layout cycle won't get executed
            super.invalidateLayout(with: context)
        }
        
        // Case if a full invalidation occured
        if context.invalidateEverything
        {
            attributesHeader = [:]
            attributesCell   = [:]
            
            return
        }
        
        // Remove all the things that were invalidated
        context.invalidatedSupplementaryIndexPaths?.forEach
        {
            (kindRaw, indexPaths) in
            
            guard let kind = SupplementaryKind(rawValue: kindRaw) else { return }
            
            switch kind
            {
            case .header:
                
                indexPaths.forEach { _ = attributesHeader.removeValue(forKey: $0) }
            }
        }
    }
}
















