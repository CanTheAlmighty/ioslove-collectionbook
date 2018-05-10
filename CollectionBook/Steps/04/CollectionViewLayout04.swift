//
//  CollectionViewLayout04.swift
//  CollectionBook
//
//  Created by Jose Luis Canepa on 6/09/18.
//  Copyright © 2018 Jose Luis Canepa. All rights reserved.
//
//  CMD+F "NEW:" to see what's been added
//  This is a "fork" of

import UIKit

final class CollectionViewLayout04 : UICollectionViewLayout
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
    
    // MARK: - Animator
    var animator : UIDynamicAnimator? = nil
    
    private lazy var derived : DerivedMetrics = DerivedMetrics(metrics: metrics, collectionView: collectionView!)
    
    var attributesCell   : [IndexPath : UICollectionViewLayoutAttributes] = [:]
    var attributesHeader : [IndexPath : UICollectionViewLayoutAttributes] = [:]
    var behaviorsCell    : [IndexPath : UIDynamicBehavior] = [:]
    var behaviorsHeaders : [IndexPath : UIDynamicBehavior] = [:]
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        animator = UIDynamicAnimator(collectionViewLayout: self)
    }
    
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
                
                guard attributesCell[indexPath] == nil,
                      let attributes = layoutAttributesForItem(at: indexPath)
                else { continue }
                
                // NEW: Add the new behavior
                let behavior = UIAttachmentBehavior(item: attributes, attachedToAnchor: attributes.center)
                behavior.damping   = 0.40
                behavior.length    = 0.0
                behavior.frequency = 1.0
                
                behaviorsCell[indexPath] = behavior
                animator?.addBehavior(behavior)
                
                attributesCell[indexPath] = attributes
            }
            
            if items > 0
            {
                let indexPath = IndexPath(item: 0, section: section)
                
                guard attributesHeader[indexPath] == nil,
                      let attributes = layoutAttributesForSupplementaryView(ofKind: SupplementaryKind.header.rawValue, at: indexPath)
                else { continue }
                
                // NEW: Behaviors for headers? yes please!
                let behavior = UIAttachmentBehavior(item: attributes, attachedToAnchor: attributes.center)
                
                // Make the headers weaker springs
                behavior.damping   = 0.20
                behavior.length    = 0.0
                behavior.frequency = 1.0
                
                behaviorsHeaders[indexPath] = behavior
                animator?.addBehavior(behavior)
                
                attributesHeader[indexPath] = attributes
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
        let offset = derived.offsets[indexPath.section]
        
        // NEW: We removed the sticky invalidation logic, since the Dynamics will take
        // care of invalidating the layout. Plus, it looked weird with all the moving stuff.
        
        // Create the attributes
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: SupplementaryKind.header.rawValue, with: indexPath)
        attributes.frame = CGRect(x: 0, y: offset, width: collectionView.frame.size.width, height: metrics.header.height)
        
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
        let context = super.invalidationContext(forBoundsChange: newBounds)
        
        // NEW: We animate the displacements, and let the animator handle invalidations.
        animateDisplacements(old: collectionView?.bounds ?? .zero, new: newBounds)
        
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
            
            behaviorsCell = [:]
            animator?.removeAllBehaviors()
            
            return
        }
        
        context.invalidatedItemIndexPaths?.forEach
        {
            if let behavior = behaviorsCell[$0]
            {
                animator?.removeBehavior(behavior)
                behaviorsCell.removeValue(forKey: $0)
            }
            
            attributesCell.removeValue(forKey: $0)
        }
        
        // Remove all the things that were invalidated
        context.invalidatedSupplementaryIndexPaths?.forEach
        {
            (kindRaw, indexPaths) in
            
            guard let kind = SupplementaryKind(rawValue: kindRaw) else { return }
            
            switch kind
            {
            case .header:
                
                indexPaths.forEach
                {
                    _ = attributesHeader.removeValue(forKey: $0)
                    _ = behaviorsHeaders.removeValue(forKey: $0)
                }
            }
        }
    }
    
    // MARK: - Dynamics
    
    // NEW: This method diplaces
    private func animateDisplacements(old : CGRect, new : CGRect)
    {
        // DO NOT do any of this if there's no animator.
        guard animator != nil else { return }
        
        // The actual displacement method
        func displace(_ attribute : UICollectionViewLayoutAttributes, touch : CGPoint, delta : CGFloat) -> UICollectionViewLayoutAttributes
        {
            // The euclidian distance between finger and attribute, normalized by the smallest side of the screen
            let distance = sqrt(pow(touch.x - attribute.center.x, 2) + pow(touch.y - attribute.center.y, 2)) / min(new.size.height, new.size.width)
            
            // Multiplier based of the squard distance, moving in the opposite direction of the finger.
            let multiplier : CGFloat = -pow(distance, 2) * 0.18
            
            // Displace it
            var center = attribute.center
            center.y += delta * multiplier
            attribute.center = center
            
            return attribute
        }
        
        // Delta movement
        let delta = old.origin.y - new.origin.y
        
        // Make sure we have the finger, and the delta is significant
        guard fabs(delta) > 1.0, let touch = collectionView?.panGestureRecognizer.location(in: collectionView) else { return }
        
        // Update all attributes to this new offsets
        behaviorsCell.forEach
        {
            (indexPath, behavior) in
            
            guard var attribute = attributesCell[indexPath] else { return }
            
            attribute = displace(attribute, touch: touch, delta: delta)
            animator?.updateItem(usingCurrentState: attribute)
        }
        
        behaviorsHeaders.forEach
        {
            (indexPath, behavior) in
            
            guard var attribute = attributesHeader[indexPath] else { return }
            
            attribute = displace(attribute, touch: touch, delta: delta)
            animator?.updateItem(usingCurrentState: attribute)
        }
    }
}




















