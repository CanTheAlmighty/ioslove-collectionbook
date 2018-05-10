//
//  LessonTableViewController.swift
//  CollectionBook
//
//  Created by Jose Luis Canepa on 3/26/18.
//  Copyright © 2018 Jose Luis Canepa. All rights reserved.
//

import UIKit

// MARK: - Lesson List

final class LessonTableViewController : UITableViewController
{
    private enum Section : Int
    {
        static var all : [Section] { return [.lessons, .samples] }
        
        case lessons
        case samples
        
        var title : String
        {
            switch self
            {
            case .lessons: return "Lessons"
            case .samples: return "Samples"
            }
        }
    }
    
    private struct Lesson
    {
        let name : String
        let desc : String
        let vc   : UIViewController.Type?
        let nib  : String?
        
        var isEnabled : Bool { return nib != nil && vc != nil }
    }
    
    private let lessons : [Section : [Lesson]] =
    [
        .lessons: [
            Lesson(name: "The Basics",
                   desc: "How to set up the layout for the first time",
                   vc: CollectionViewController00.self,
                   nib: "CollectionViewController00"),
            Lesson(name: "Supplementaries",
                   desc: "Displaying supplementary views",
                   vc: CollectionViewController01.self,
                   nib: "CollectionViewController01"),
            Lesson(name: "Section Handling",
                   desc: "Handling more than a section, plus a cleanup",
                   vc: CollectionViewController02.self,
                   nib: "CollectionViewController02"),
            Lesson(name: "Invalidations",
                   desc: "Making the supplementaries react to the content offsets, using invalidations",
                   vc: CollectionViewController03.self,
                   nib: "CollectionViewController03"),
            Lesson(name: "UIDynamics",
                   desc: "Adding an animation coordinator for advanced layouts, and handling proper dynamic item reuse",
                   vc: CollectionViewController04.self,
                   nib: "CollectionViewController04"),
//            Lesson(name: "Optimizing", desc: "Picking only the right views to layout instead of using Intersections", vc: nil, nib: "CollectionViewController00"),
        ],
        .samples:
        [
            Lesson(name: "Wallet Layout", desc: "Imitates the Wallet Application from iOS", vc: PassportViewController.self, nib: "PassportViewController")
        ]
    ]
    
    private func lessons(in section : Int) -> [Lesson]
    {
        guard let section = Section(rawValue: section),
              let lessons = lessons[section]
        else { return [] }
        
        return lessons
    }
    
    private func lesson(at indexPath : IndexPath) -> Lesson?
    {
        return lessons(in: indexPath.section)[indexPath.row]
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return Section.all.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return lessons(in: section).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LessonCell
        
        let lessonsSection = lessons(in: indexPath.section)
        let lesson = lessonsSection[indexPath.row]
        
        cell.labelNumber?.text      = String(format: "%02d", indexPath.row+1)
        cell.labelTitle?.text       = lesson.name
        cell.labelDescription?.text = lesson.desc
        cell.labelNumber?.textColor = UIColor(hue: CGFloat(indexPath.row) / CGFloat(lessonsSection.count), saturation: 0.9, brightness: 0.8, alpha: 1.0)
        cell.show(as: lesson.isEnabled)
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return Section(rawValue: section)!.title
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        guard let lesson = lesson(at: indexPath), lesson.isEnabled else { return }
        
        presentLesson(lesson)
    }
    
    // MARK: - Presentation
    
    private func presentLesson(_ lesson : Lesson)
    {
        guard let viewController = lesson.vc?.init(nibName: lesson.nib, bundle: .main) else { return }
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Lesson Cell

final class LessonCell : UITableViewCell
{
    @IBOutlet weak var labelNumber      : UILabel?
    @IBOutlet weak var labelTitle       : UILabel?
    @IBOutlet weak var labelDescription : UILabel?
    
    func show(as enabled : Bool)
    {
        if !enabled
        {
            labelNumber?.textColor = .lightGray
        }
        
        labelTitle?.textColor       = enabled ? .black : .lightGray
        labelDescription?.textColor = enabled ? .black : .lightGray
        
        selectionStyle = enabled ? .default : .none
    }
}









