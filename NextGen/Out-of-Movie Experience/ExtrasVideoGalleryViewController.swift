//
//  SecondTemplateViewController.swift
//  NextGen
//
//  Created by Sedinam Gadzekpo on 1/21/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc. All rights reserved.
//

import UIKit

class ExtrasVideoGalleryViewController: ExtrasExperienceViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var galleryTableView: UITableView!
    
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var previewImageView: UIImageView?
    @IBOutlet weak var previewPlayButton: UIButton?
    @IBOutlet weak var mediaTitleLabel: UILabel!
    @IBOutlet weak var mediaDescriptionLabel: UILabel!
    @IBOutlet weak var mediaRuntimeLabel: UILabel!
    private var _videoPlayerViewController: VideoPlayerViewController?
    
    @IBOutlet weak var galleryScrollView: UIScrollView!
    @IBOutlet weak var galleryPageControl: UIPageControl!
    @IBOutlet weak var galleryFullScreenButton: UIButton!
    private var _scrollViewPageWidth: CGFloat = 0
    private var _imageGallery: NGDMGallery?
    
    private var _didPlayFirstItem = false
    private var _previewPlayURL: NSURL?
    private var _userDidSelectNextItem = true
    
    private var _willPlayNextItemObserver: NSObjectProtocol!

    
    // MARK: Initialization
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(_willPlayNextItemObserver)
    }

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        galleryTableView.registerNib(UINib(nibName: String(VideoCell), bundle: nil), forCellReuseIdentifier: VideoCell.ReuseIdentifier)

        let selectedPath = NSIndexPath(forRow: 0, inSection: 0)
        self.galleryTableView.selectRowAtIndexPath(selectedPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
        self.tableView(self.galleryTableView, didSelectRowAtIndexPath: selectedPath)

        _willPlayNextItemObserver = NSNotificationCenter.defaultCenter().addObserverForName(kWBVideoPlayerWillPlayNextItem, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) -> Void in
            if let strongSelf = self, userInfo = notification.userInfo, index = userInfo["index"] as? Int {
                if index < strongSelf.experience.childExperiences.count {
                    let indexPath = NSIndexPath(forRow: index, inSection: 0)
                    strongSelf.galleryTableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
                    strongSelf._userDidSelectNextItem = false
                    strongSelf.tableView(strongSelf.galleryTableView, didSelectRowAtIndexPath: indexPath)
                }
            }
        }
    }
    
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(VideoCell.ReuseIdentifier, forIndexPath: indexPath) as! VideoCell
        cell.backgroundColor = UIColor.clearColor()
        cell.selectionStyle = .None
        cell.experience = experience.childExperiences[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return experience.childExperiences.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200
    }
    
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if !cell.selected {
                return indexPath
            }
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let thisExperience = experience.childExperiences[indexPath.row]
        
        mediaTitleLabel.text = thisExperience.metadata?.title
        mediaDescriptionLabel.text = thisExperience.metadata?.description
        
        // Reset media detail views
        galleryPageControl.hidden = true
        galleryScrollView.hidden = true
        videoContainerView.hidden = false
        previewImageView?.hidden = _didPlayFirstItem
        previewPlayButton?.hidden = _didPlayFirstItem
        mediaRuntimeLabel.text = nil
        
        let galleryScrollViewPages = galleryScrollView.subviews
        for pageView in galleryScrollViewPages {
            pageView.removeFromSuperview()
        }
        
        galleryScrollView.contentOffset = CGPointZero
        _imageGallery = nil
        
        // Set new media detail views
        if let gallery = thisExperience.imageGallery, pictures = gallery.pictures {
            galleryPageControl.hidden = false
            galleryScrollView.hidden = false
            videoContainerView.hidden = true
            previewImageView?.hidden = true
            previewPlayButton?.hidden = true
            
            let numPictures = pictures.count
            galleryPageControl.numberOfPages = numPictures
            
            var imageViewX: CGFloat = 0
            _scrollViewPageWidth = CGRectGetWidth(galleryScrollView.bounds)
            for i in 0 ..< numPictures {
                let imageView = UIImageView()
                imageView.contentMode = UIViewContentMode.ScaleAspectFit
                imageView.frame = CGRectMake(imageViewX, 0, _scrollViewPageWidth, CGRectGetHeight(galleryScrollView.bounds))
                imageView.clipsToBounds = true
                imageView.tag = i + 1
                galleryScrollView.addSubview(imageView)
                imageViewX += _scrollViewPageWidth
            }
            
            galleryScrollView.contentSize = CGSizeMake(CGRectGetWidth(galleryScrollView.bounds) * CGFloat(numPictures), CGRectGetHeight(galleryScrollView.bounds))
            _imageGallery = gallery
            loadGalleryImageForPage(0)
        } else if thisExperience.isAudioVisual {
            let runtime = thisExperience.videoRuntime
            if runtime > 0 {
                mediaRuntimeLabel.text = String.localize("label.runtime", variables: ["runtime": runtime.timeString()])
            }
        
            if let videoURL = thisExperience.videoURL, videoPlayerViewController = _videoPlayerViewController ?? UIStoryboard.getMainStoryboardViewController(VideoPlayerViewController) as? VideoPlayerViewController {
                if let player = videoPlayerViewController.player {
                    player.removeAllItems()
                }
                
                videoPlayerViewController.mode = VideoPlayerMode.Supplemental
                videoPlayerViewController.curIndex = Int32(indexPath.row)
                videoPlayerViewController.indexMax = Int32(experience.childExperiences.count)
                
                videoPlayerViewController.view.frame = videoContainerView.bounds
                videoContainerView.addSubview(videoPlayerViewController.view)
                self.addChildViewController(videoPlayerViewController)
                videoPlayerViewController.didMoveToParentViewController(self)
                _videoPlayerViewController = videoPlayerViewController
                
                if !_didPlayFirstItem {
                    _previewPlayURL = videoURL
                
                    if indexPath.row == 0 {
                        if let imageURL = thisExperience.imageURL {
                            previewImageView?.setImageWithURL(imageURL)
                        }
                    } else {
                        playFirstItem(nil)
                    }
                } else {
                    if _userDidSelectNextItem {
                        videoPlayerViewController.cancel(videoPlayerViewController.nextItemTask)
                    }
                        
                    videoPlayerViewController.playVideoWithURL(videoURL)
                    _userDidSelectNextItem = true
                
                }
            }
        }
    }
    
    // MARK: Image Gallery
    func loadGalleryImageForPage(page: Int) {
        if let gallery = _imageGallery, imageView = galleryScrollView.viewWithTag(page + 1) as? UIImageView, pictures = gallery.pictures {
            if imageView.image == nil {
                if let imageURL = pictures[page].imageURL {
                    imageView.setImageWithURL(imageURL)
                }
            }
            
            galleryPageControl.currentPage = page
        }
    }
    
    @IBAction func toggleGalleryFullScreen() {
        
    }
    
    
    // MARK: UIScrollViewDelegate
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == galleryScrollView {
            loadGalleryImageForPage(Int(targetContentOffset.memory.x / _scrollViewPageWidth))
        }
    }
    
    
    // MARK: Actions
    @IBAction func playFirstItem(sender: UIButton?) {
        _didPlayFirstItem = true
        
        previewImageView?.removeFromSuperview()
        previewPlayButton?.removeFromSuperview()
        previewImageView = nil
        previewPlayButton = nil
        
        if let videoURL = _previewPlayURL {
            _videoPlayerViewController?.playVideoWithURL(videoURL)
        }
    }
    
}