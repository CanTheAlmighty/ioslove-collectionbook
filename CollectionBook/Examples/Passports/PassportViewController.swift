//
//  PassportViewController.swift
//  CollectionBook
//
//  Created by Jose Luis Canepa on 4/5/18.
//  Copyright © 2018 Jose Luis Canepa. All rights reserved.
//

import UIKit

final class PassportViewController : UICollectionViewController
{
    struct Destination
    {
        let name : String
        let place : String
    }
    
    var destinations =
    [
        Destination(name: "Johannesburg", place: "South Africa"),
        Destination(name: "Berlin", place: "Germany"),
        Destination(name: "Toronto", place: "Canada"),
        Destination(name: "Mumbai", place: "India"),
        Destination(name: "Munich", place: "Germany"),
        Destination(name: "Madrid", place: "Spain"),
        Destination(name: "Dublin", place: "Ireland"),
        Destination(name: "Chennai", place: "India"),
        Destination(name: "Los Angeles", place: "USA"),
        Destination(name: "Miami", place: "USA"),
        Destination(name: "Prague", place: "Czech Republic"),
        Destination(name: "Vienna", place: "Austria"),
        Destination(name: "Shanghai", place: "China"),
        Destination(name: "Rome", place: "Italy"),
        Destination(name: "Taipei", place: "Taiwan"),
        Destination(name: "Osaka", place: "Japan"),
        Destination(name: "Milan", place: "Italy"),
        Destination(name: "Amsterdam", place: "Netherlands"),
        Destination(name: "Barcelona", place: "Spain"),
        Destination(name: "Istanbul", place: "Turkey"),
        Destination(name: "Osorno", place: "Chile"),
        Destination(name: "Hong Kong", place: "China"),
        Destination(name: "Kuala Lumpur", place: "Malaysia"),
        Destination(name: "New York", place: "USA"),
        Destination(name: "Seoul", place: "South Korea"),
        Destination(name: "Tokyo", place: "Japan"),
        Destination(name: "Singapore", place: "Malaysia"),
        Destination(name: "Dubai", place: "UAE"),
        Destination(name: "Paris", place: "France"),
        Destination(name: "London", place: "UK"),
        Destination(name: "Bangkok", place: "Thailand")
    ]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        prepareCollectionView()
    }
    
    private func prepareCollectionView()
    {
        collectionView?.register(UINib(nibName: "PassportCell", bundle: .main), forCellWithReuseIdentifier: "pass")
        collectionView?.register(UINib(nibName: "PassportHeader", bundle: .main), forSupplementaryViewOfKind: PassportLayout.SupplementaryKind.header.rawValue, withReuseIdentifier: "header")
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return destinations.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pass", for: indexPath) as! PassportCell
        
        let destination = destinations[indexPath.item]
        
        cell.setColor(percentage: CGFloat(indexPath.item) / CGFloat(destinations.count))
        cell.labelTitle?.text    = destination.name
        cell.labelSubtitle?.text = destination.place
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool
    {
        guard let selection = collectionView.indexPathsForSelectedItems, selection.count > 0 else
        {
            // Can select, since there's nothing selected
            return true
        }
        
        // Deselect all prior elements
        selection.forEach { collectionView.deselectItem(at: $0, animated: true) }
        
        // Change the layout
        let layout = PassportLayout()
        collectionView.setCollectionViewLayout(layout, animated: true, completion: nil)
        
        // Don't select the new one, since there was already a selection
        return false
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    {
        if let cell = collectionView.cellForItem(at: indexPath) as? PassportCell
        {
            cell.redraw(expanded: false)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        // Create a new layout with a selection
        let layout = PassportLayout()
        layout.selection = indexPath
        
        collectionView.setCollectionViewLayout(layout, animated: true, completion: nil)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? PassportCell
        {
            cell.redraw(expanded: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kindRaw: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        let kind = PassportLayout.SupplementaryKind(rawValue: kindRaw)!
        
        switch kind
        {
        case .header:
            
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind.rawValue, withReuseIdentifier: "header", for: indexPath)
        }
    }
}























