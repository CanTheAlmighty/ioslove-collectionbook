//
//  PassportCell.swift
//  CollectionBook
//
//  Created by Jose Luis Canepa on 4/5/18.
//  Copyright © 2018 Jose Luis Canepa. All rights reserved.
//

import UIKit

final class PassportCell : UICollectionViewCell
{
    @IBOutlet weak var labelTitle : UILabel?
    @IBOutlet weak var labelSubtitle : UILabel?
    @IBOutlet weak var viewPassport : PassportView?
    
    // MARK: - Setup
    
    public func setColor(percentage : CGFloat)
    {
        let color = UIColor(hue: percentage, saturation: 0.6, brightness: 1.0, alpha: 1.0)
        
        viewPassport?.colorMain = color
    }
    
    // Triggers a re-drawing for a fully expanded version
    public func redraw(expanded : Bool)
    {
        viewPassport?.expanded = expanded
        viewPassport?.setNeedsDisplay()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        guard let passport = viewPassport?.layer as? CAShapeLayer else { return }
        
        passport.path = CGPath(roundedRect: bounds, cornerWidth: 8.0, cornerHeight: 8.0, transform: nil)
        passport.fillColor = UIColor.green.cgColor
    }
}

final class PassportView : UIView
{
    var expanded : Bool = false
    
    var colorMain : UIColor = .black
    {
        didSet
        {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect)
    {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let path = CGPath(roundedRect: bounds, cornerWidth: 8.0, cornerHeight: 8.0, transform: nil)
        
        context.addPath(path)
        context.setFillColor(colorMain.cgColor)
        context.fillPath()
        
        // Add the bottom line
        if expanded
        {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY * 0.85))
            path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY * 0.85))
            
            context.addPath(path)
            context.setLineDash(phase: 0.0, lengths: [1.0, 2.0])
            context.setStrokeColor(UIColor(white: 0, alpha: 0.2).cgColor)
            context.strokePath()
        }
    }
}
