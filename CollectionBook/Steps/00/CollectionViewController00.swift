//
//  CollectionViewController00.swift
//  CollectionBook
//
//  Created by Jose Luis Canepa on 3/28/18.
//  Copyright © 2018 Jose Luis Canepa. All rights reserved.
//

import UIKit

final class CollectionViewController00 : UICollectionViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        prepareCollection()
    }
    
    let count : Int = 100
    
    private func prepareCollection()
    {
        collectionView?.register(UINib(nibName: "GridCell", bundle: .main), forCellWithReuseIdentifier: "cell")
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
}
