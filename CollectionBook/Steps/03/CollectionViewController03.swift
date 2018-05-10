//
//  CollectionViewController03.swift
//  CollectionBook
//
//  Created by Jose Luis Canepa on 3/28/18.
//  Copyright © 2018 Jose Luis Canepa. All rights reserved.
//

import UIKit

final class CollectionViewController03 : UICollectionViewController
{
    private typealias Layout = CollectionViewLayout03
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        prepareCollection()
    }
    
    let sections : Int = 10
    let count : Int = 100
    
    private func prepareCollection()
    {
        collectionView?.register(UINib(nibName: "GridCell", bundle: .main), forCellWithReuseIdentifier: "cell")
        collectionView?.register(UINib(nibName: "GridHeaderView", bundle: .main), forSupplementaryViewOfKind: Layout.SupplementaryKind.header.rawValue, withReuseIdentifier: "header")
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return sections
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GridCell
        
        cell.setColor(percentage: CGFloat(indexPath.item) / CGFloat(count))
        cell.label?.text = "\(indexPath.item)"
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kindRaw: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        let kind = Layout.SupplementaryKind(rawValue: kindRaw)!
        
        switch kind
        {
        case .header:
            
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: Layout.SupplementaryKind.header.rawValue, withReuseIdentifier: "header", for: indexPath) as! GridHeaderView
            
            header.labelTitle?.text    = "Section \(indexPath.section)"
            header.labelSubtitle?.text = "\(Date())"
            
            return header
        }
    }
}
