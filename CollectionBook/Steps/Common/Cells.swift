//
//  Cells.swift
//  CollectionBook
//
//  Created by Jose Luis Canepa on 4/3/18.
//  Copyright © 2018 Jose Luis Canepa. All rights reserved.
//

import UIKit

final class GridCell : UICollectionViewCell
{
    @IBOutlet weak var label : UILabel?
    
    var colorMain : UIColor = .black
    {
        didSet
        {
            label?.textColor  = colorMain
            layer.borderColor = colorMain.cgColor
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        prepareLayer()
    }
    
    // MARK: - Preparation
    
    private func prepareLayer()
    {
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.green.cgColor
    }
    
    // MARK: - Setup
    
    public func setColor(percentage : CGFloat)
    {
        colorMain = UIColor(hue: percentage, saturation: 1.0, brightness: 1.0, alpha: 1.0)
    }
}
