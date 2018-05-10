//
//  PassportLayout.swift
//  CollectionBook
//
//  Created by Jose Luis Canepa on 4/5/18.
//  Copyright © 2018 Jose Luis Canepa. All rights reserved.
//

/* Simulates a Wallet (ex-passbook) layout.
 
 This layout is very inefficient, as it returns all the cells at the same time, so it's not recommended for actual
 use, other than small and constant-sized datasets, or unless optimizations are done on the view querying.
 
 The purpose of this example is to illustrate:
 
 1. That all cell-items can be placed dynamically on runtime manually, with the desired effects of:
   1. Sticking to top
   2. Causing elements to separate elastically when pulling/bouncing on top.
 2. Full layout invalidations when selecting an element (this is done on the view controller).
 3. Aditionally, using the collection view cell's constraints to do additional effects when resized (notice the rounded,
 corners)
 */

import UIKit

final class PassportLayout : UICollectionViewLayout
{
    enum SupplementaryKind : String
    {
        case header
    }
    
    // MARK: - Metrics
    
    struct Metrics
    {
        struct Header
        {
            var height : CGFloat = 72.0
        }
        
        struct Pass
        {
            /// How vertically separated are each cell at their furthest
            var separation : CGFloat = 72.0
            
            /// How much of the ticket is additionally rendered (to allow for rounded corners, or other transparent elements)
            var overlap : CGFloat = 8.0
            
            /// Insetting for all the cell drawing area
            var insets : UIEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
            
            /// How tall a pass actually is (when rendered fully)
            var height : CGFloat = 480.0
        }
        
        struct Effects
        {
            /// How springy are the tickets when reaching the bounds, 0.0 = inelastic, 1.0 = elastic, >1.0 is exaggerated
            var elasticity : CGFloat = 1.0
            
            /// When passes get collapsed, they are relegated to a small area in the bottom, this value determines
            /// the available height for them.
            var collapseHeight : CGFloat = 96.0
        }
        
        var header  = Header()
        var pass    = Pass()
        var effects = Effects()
    }
    
    var metrics = Metrics()
    {
        didSet { invalidateLayout() }
    }
    
    var selection : IndexPath? //{ return collectionView?.indexPathsForSelectedItems?.first }
    
    // MARK: - Attributes Storage
    
    var attributes       : [IndexPath : UICollectionViewLayoutAttributes] = [:]
    var attributesHeader : UICollectionViewLayoutAttributes? = nil
    
    // MARK: - Preparation
    
    override func prepare()
    {
        guard let collectionView = collectionView else { return }
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0)
        {
            let indexPath = IndexPath(item: item, section: 0)
            
            guard attributes[indexPath] == nil else { continue }
            
            attributes[indexPath] = layoutAttributesForItem(at: indexPath)
        }
        
        if attributesHeader == nil
        {
            attributesHeader = layoutAttributesForSupplementaryView(ofKind: SupplementaryKind.header.rawValue, at: IndexPath(item: 0, section: 0))
        }
    }
    
    // MARK: - Individual Layout
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        guard let collectionView = collectionView else { return nil }
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        if let selection = selection
        {
            // Selection has been made
            let multiplier = CGFloat(indexPath.item) / CGFloat(collectionView.numberOfItems(inSection: 0))
            
            var offset : CGFloat = collectionView.frame.size.height - (1.0 - multiplier) * metrics.effects.collapseHeight
            var height : CGFloat = metrics.effects.collapseHeight / CGFloat(collectionView.numberOfItems(inSection: 0))
            height += metrics.pass.overlap
            
            if indexPath == selection
            {
                // Center vertically
                offset = (collectionView.frame.height - metrics.pass.height - metrics.effects.collapseHeight) / 2.0
                height = metrics.pass.height
            }
            
            attributes.frame = CGRect(x: metrics.pass.insets.left,
                                      y: offset,
                                      width: collectionView.bounds.size.width - metrics.pass.insets.left - metrics.pass.insets.right,
                                      height: height)
            
            attributes.zIndex = indexPath.item + 1
        }
        else
        {
            // The intended original offset
            var offset = CGFloat(indexPath.item) * metrics.pass.separation + metrics.header.height + metrics.pass.insets.top
            var height = metrics.pass.separation + metrics.pass.overlap
            
            // Stick it to the top (plus insets)
            if (offset - metrics.pass.insets.top) < collectionView.bounds.origin.y
            {
                offset = collectionView.bounds.origin.y + metrics.pass.insets.top
            }
            
            // If the collection view scrolls way above
            if collectionView.bounds.origin.y < 0
            {
                // Makes items extend past each other, depending on how hard the user pulls to the negative values
                // You can increase
                let extraSeparation : CGFloat = 1.0 + (fabs(collectionView.bounds.origin.y) / collectionView.bounds.size.height) * metrics.effects.elasticity
                
                if indexPath == IndexPath(item: 0, section: 0)
                {
                    // Simply stick the first cell to the top
                    offset  = offset + collectionView.bounds.origin.y
                    
                    // The height is our height plus the difference between this offset, and the offset of the following element
                    // (which is the height of indexPath at 1, times its separation)
                    height += (metrics.pass.separation + metrics.header.height + metrics.pass.insets.top) * extraSeparation - offset
                    
                    // Cap it to the absolute height of a ticket
                    if height > metrics.pass.height
                    {
                        height = metrics.pass.height
                    }
                }
                else
                {
                    // The rest of the cells get evenly split
                    offset *= extraSeparation
                    height *= extraSeparation
                }
            }
        
            // If it's the last item, make it span the full height
            if indexPath == IndexPath(row: collectionView.numberOfItems(inSection: 0) - 1, section: 0)
            {
                height = metrics.pass.height
            }
            
            attributes.frame = CGRect(x: metrics.pass.insets.left,
                                      y: offset,
                                      width: collectionView.bounds.size.width - metrics.pass.insets.left - metrics.pass.insets.right,
                                      height: height)
            
            attributes.zIndex = indexPath.item + 1
        }
        
        return attributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        guard let collectionView = collectionView, let kind = SupplementaryKind(rawValue: elementKind) else { return nil }
        
        switch kind
        {
        case .header:
            
            var alpha : CGFloat = 1.0
            
            // Make the header fade out when elements scroll over it (scroll offset past the header height)
            if collectionView.bounds.origin.y > 0, selection == nil
            {
                let halfpoint = metrics.header.height / 2.0
                
                alpha = 0.5 - ((collectionView.bounds.origin.y - halfpoint) / halfpoint)
            }
            else if selection != nil
            {
                // Hide if there's a selection going on
                alpha = 0.0
            }
            
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: kind.rawValue, with: indexPath)
            
            attributes.frame  = CGRect(x: 0, y: collectionView.bounds.origin.y, width: collectionView.frame.size.width, height: metrics.header.height)
            attributes.zIndex = 0
            attributes.alpha  = alpha
            
            return attributes
        }
        
    }
    
    // MARK: - Layout
    
    override var collectionViewContentSize: CGSize
    {
        guard let collectionView = collectionView else { return .zero }
        
        var size : CGSize = collectionView.frame.size
        
        if selection == nil
        {
            size.width  = collectionView.frame.size.width
            size.height  = metrics.pass.separation * CGFloat(collectionView.numberOfItems(inSection: 0))
            size.height += metrics.header.height
            size.height += metrics.pass.insets.top + metrics.pass.insets.bottom
        }
        
        return size
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        var visible : [UICollectionViewLayoutAttributes] = Array<UICollectionViewLayoutAttributes>(attributes.values)
        
        if let header = attributesHeader
        {
            visible.append(header)
        }
        
        return visible
    }
    
    // MARK: - Invalidation
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool
    {
        return true
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext
    {
        let context = super.invalidationContext(forBoundsChange: newBounds)
        
        context.invalidateItems(at: Array(attributes.keys))
        context.invalidateSupplementaryElements(ofKind: SupplementaryKind.header.rawValue, at: [IndexPath(item: 0, section: 0)])
        
        return context
    }
    
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext)
    {
        defer
        {
            super.invalidateLayout(with: context)
        }
        
        if context.invalidateEverything
        {
            attributes = [:]
            return
        }
        
        context.invalidatedItemIndexPaths?.forEach
        {
            attributes.removeValue(forKey: $0)
        }
        
        context.invalidatedSupplementaryIndexPaths?.forEach
        {
            (kindRaw, indexPaths) in
            
            guard let kind = SupplementaryKind(rawValue: kindRaw) else { return }
            
            switch kind
            {
            case .header: attributesHeader = nil
            }
        }
    }
}































