//
//  ExtrasSceneLocationsViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 5/5/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit
import MapKit

struct MapAppDataItem {
    var appData: NGDMAppData!
    var marker: MultiMapMarker!
}



class ExtrasSceneLocationsViewController: MenuedViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var mapView: MultiMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var galleryName: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var triviaText: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UIView!
    private var mapAppDataItems = [String: [MapAppDataItem]]()
    private var tempSelectedAppDataItems:[MapAppDataItem]?
    private var selectedAppDataItems: [MapAppDataItem]?
    private var childGalleryItems: [NGDMAppData]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.hidden = true
        menuTableView.backgroundColor = UIColor.clearColor()
        collectionView.registerNib(UINib(nibName: String(MapItemCell), bundle: nil), forCellWithReuseIdentifier: MapItemCell.ReuseIdentifier)
        
        if childGalleryItems != nil{
            let selectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            collectionView.selectItemAtIndexPath(selectedIndexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.Left)
            
        }
        
        let info = NSMutableDictionary()
        info[MenuSection.Keys.Title] = "Location: Full Map"
        
        var rows = [[String: String]]()
        for experience in self.experience.childExperiences {
            if let appData = experience.appData, type = appData.type, location = appData.location {
                if mapAppDataItems[type] == nil {
                    mapAppDataItems[type] = [MapAppDataItem]()
                    rows.append([MenuItem.Keys.Title: type, MenuItem.Keys.Value: type])
                }
                
                let center = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                let marker = mapView.addMarker(center, title: location.name, subtitle: location.address, icon: UIImage(named: "MOSMapPin"), autoSelect: false)
                mapAppDataItems[type]!.append(MapAppDataItem(appData: appData, marker: marker))
            }
        }
        
        info[MenuSection.Keys.Rows] = rows
        menuSections.append(MenuSection(info: info))
        
        mapView.zoomToFitAllMarkers()
    }
    
    func selectAppDataType(appDataType: String) {
        if let mapAppDataItems = mapAppDataItems[appDataType] {
            if mapAppDataItems.count == 1 {
                let mapData = mapAppDataItems[0].appData
                let center = CLLocationCoordinate2DMake((mapData.location?.latitude)!, (mapData.location?.longitude)!)
                mapView.setLocation(center, zoomLevel: 7, animated: true)
                
            }else {
            mapView.zoomToFitMarkers(mapAppDataItems.map({ $0.marker }))
            }
            selectedAppDataItems = mapAppDataItems
            collectionView.reloadData()
        }
    }
   
    //MARK: Overriding MenuedViewController functions
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            cell.backgroundColor = UIColor.init(netHex: 0xba0f0f)
        } else {
            cell.backgroundColor = UIColor.blackColor()
        }
        
        tableViewHeight.constant += cell.frame.height
        
        tableView.setNeedsUpdateConstraints()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(menuTableView, didSelectRowAtIndexPath: indexPath)
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? MenuItemCell, appDataType = cell.menuItem?.value {
            galleryName.text = appDataType
            selectAppDataType(appDataType)
        }
    }
    
    //MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let selectedAppDataItems = selectedAppDataItems {
            return selectedAppDataItems.count
        } else if let childGalleryItems = childGalleryItems{
            return childGalleryItems.count
        }
        
        return mapAppDataItems.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MapItemCell.ReuseIdentifier, forIndexPath: indexPath) as! MapItemCell
        cell.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        if let appData = selectedAppDataItems?[indexPath.row].appData {
            cell.appDataType = nil
            cell.appData = appData
            cell.childMedia = nil
        } else {
            if let childGalleryItems = childGalleryItems{
                let childMedia = childGalleryItems[indexPath.row]
                if childMedia.displayText != nil{
                    cell.childMediaType = ChildMediaType.Text
                    cell.childMedia = childMedia

                }
                
            } else {
                let mapAppDataItemList = Array(mapAppDataItems.values)[indexPath.row]
                cell.childMedia = nil
                cell.childCount = mapAppDataItemList.count
                cell.appDataType = mapAppDataItemList.first?.appData
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? MapItemCell {
            if let appDataType = cell.appDataType?.type {
                galleryName.text = cell.appDataType?.type
                selectAppDataType(appDataType)
            } else if let childMedia = cell.childMedia {
                textView.hidden = false
                imageView.image = cell.appData?.thumbnailImage
                triviaText.text = childMedia.displayText
            } else {
                loadChildGallery(cell.appData!)
            }
        
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let itemWidth: CGFloat = (CGRectGetWidth(collectionView.frame) / 4)
        return CGSizeMake(itemWidth, itemWidth + 30)
    }
    
    func loadChildGallery(appData: NGDMAppData){
        childGalleryItems = []
        if appData.displayText != nil {
            childGalleryItems?.append(appData)
        }
        tempSelectedAppDataItems = selectedAppDataItems
        selectedAppDataItems = nil
        collectionView.reloadData()
        
    }
    @IBAction func dismissGallery(sender: AnyObject) {
        
        textView.hidden = true
        childGalleryItems = nil
        selectedAppDataItems = tempSelectedAppDataItems
        tempSelectedAppDataItems = nil
        collectionView.reloadData()
    }
    
}
