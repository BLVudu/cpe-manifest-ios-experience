//
//  ProfileViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 2/2/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import CoreData


class ProfileViewController: UICollectionViewController{
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var bookmarks = [NSManagedObject]()
    @IBOutlet weak var backBtn: UIBarButtonItem!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let layout = self.collectionViewLayout as? ExtrasLayout {
            layout.delegate = self
        }

        
        
        let managedContext = appDelegate.managedObjectContext
        

        let fetchRequest = NSFetchRequest(entityName: "Bookmark")
        
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            bookmarks = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        self.collectionView!.registerNib(UINib(nibName: "BookmarkCell", bundle: nil), forCellWithReuseIdentifier: "bookmark")
        
        
        
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //self.collectionViewLayout.invalidateLayout()
        
        return bookmarks.count
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("bookmark", forIndexPath: indexPath) as! BookmarkCell
        let bookmark = bookmarks[indexPath.row]
        cell.caption.text = bookmark.valueForKey("caption") as? String
        cell.thumbnail.image = UIImage(data:bookmark.valueForKey("thumbnail")as! NSData)
        cell.mediaType.text = bookmark.valueForKey("mediaType") as? String
        return cell
    }
    
    
    
    
       @IBAction func dismissProfile(sender: AnyObject) {
        
        self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil);

    }
    @IBAction func deleteAll(sender: AnyObject) {
        
        
        
        let managedContext = appDelegate.managedObjectContext
        for bookmark in self.bookmarks{
 
            let indexPath = NSIndexPath(forItem:self.bookmarks.count-1, inSection:0)
            self.bookmarks.removeAtIndex(indexPath.row)
            self.collectionView?.deleteItemsAtIndexPaths([indexPath])
            managedContext.deleteObject(bookmark)
            
        }
 
        do {
            try managedContext.save()
        } catch {
            let error = error as NSError
            print("Could not save \(error), \(error.userInfo)")
        }
 
        
    }
    

}

    
extension ProfileViewController: ExtrasLayoutDelegate{
        
        func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath: NSIndexPath,
            withWidth width: CGFloat) -> CGFloat {
                
                
                return collectionView.frame.height/2
        }
        
        func collectionView(collectionView: UICollectionView,
            heightForLabelAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat
        {
            return 200
        }
    

        

}
