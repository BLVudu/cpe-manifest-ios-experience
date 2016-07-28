//
//  SecondTemplateViewController.swift
//

import UIKit
import NextGenDataManager

class ExtrasVideoGalleryViewController: ExtrasExperienceViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    private struct Constants {
        static let GalleryTableViewImageAspectRatio: CGFloat = 16 / 9
        static let GalleryTableViewLabelHeight: CGFloat = 40
        static let GalleryTableViewPadding: CGFloat = 15
        static let GalleryTableViewMobileAspectRatio: CGFloat = 600 / 195
    }
    
    @IBOutlet weak private var galleryTableView: UITableView!
    
    @IBOutlet weak private var videoContainerView: UIView!
    @IBOutlet weak private var previewImageView: UIImageView!
    @IBOutlet weak private var previewPlayButton: UIButton!
    @IBOutlet weak private var mediaTitleLabel: UILabel!
    @IBOutlet weak private var mediaDescriptionLabel: UILabel!
    private var videoPlayerViewController: VideoPlayerViewController?
    
    @IBOutlet weak private var galleryScrollView: ImageGalleryScrollView!
    @IBOutlet weak private var galleryPageControl: UIPageControl!
    private var galleryDidScrollToPageObserver: NSObjectProtocol?
    
    @IBOutlet weak private var shareButton: UIButton!
    
    private var didPlayFirstItem = false
    
    private var willPlayNextItemObserver: NSObjectProtocol?
    private var didEndLastVideoObserver: NSObjectProtocol?
    
    // MARK: Initialization
    deinit {
        let center = NSNotificationCenter.defaultCenter()
        
        if let observer = willPlayNextItemObserver {
            center.removeObserver(observer)
            willPlayNextItemObserver = nil
        }
        
        if let observer = didEndLastVideoObserver {
            center.removeObserver(observer)
            didEndLastVideoObserver = nil
        }
        
        if let observer = galleryDidScrollToPageObserver {
            center.removeObserver(observer)
            galleryDidScrollToPageObserver = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        galleryScrollView.cleanInvisibleImages()
    }
    
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        galleryTableView.registerNib(UINib(nibName: VideoCell.NibName, bundle: nil), forCellReuseIdentifier: VideoCell.ReuseIdentifier)

        let selectedPath = NSIndexPath(forRow: 0, inSection: 0)
        self.galleryTableView.selectRowAtIndexPath(selectedPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
        self.tableView(self.galleryTableView, didSelectRowAtIndexPath: selectedPath)

        willPlayNextItemObserver = NSNotificationCenter.defaultCenter().addObserverForName(VideoPlayerNotification.WillPlayNextItem, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) -> Void in
            if let strongSelf = self, userInfo = notification.userInfo, index = userInfo["index"] as? Int where index < (strongSelf.experience.childExperiences?.count ?? 0) {
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                strongSelf.galleryTableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
                strongSelf.tableView(strongSelf.galleryTableView, didSelectRowAtIndexPath: indexPath)
            }
        }
        
        didEndLastVideoObserver = NSNotificationCenter.defaultCenter().addObserverForName(VideoPlayerNotification.DidEndLastVideo, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (_) in
            if let strongSelf = self {
                strongSelf.previewImageView.hidden = false
                strongSelf.previewPlayButton.hidden = false
                strongSelf.destroyVideoPlayer()
                
                if let selectedIndexPath = strongSelf.galleryTableView.indexPathForSelectedRow, cell = strongSelf.galleryTableView.cellForRowAtIndexPath(selectedIndexPath) as? VideoCell {
                    cell.setWatched()
                }
            }
        })
        
        galleryDidScrollToPageObserver = NSNotificationCenter.defaultCenter().addObserverForName(ImageGalleryNotification.DidScrollToPage, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (notification) in
            if let strongSelf = self, page = notification.userInfo?["page"] as? Int {
                strongSelf.galleryPageControl.currentPage = page
            }
        })
    }
    
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(VideoCell.ReuseIdentifier, forIndexPath: indexPath) as! VideoCell
        cell.backgroundColor = UIColor.clearColor()
        cell.selectionStyle = .None
        cell.experience = experience.childExperiences?[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return experience.childExperiences?.count ?? 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if DeviceType.IS_IPAD {
            return (CGRectGetWidth(tableView.frame) / Constants.GalleryTableViewImageAspectRatio) + Constants.GalleryTableViewLabelHeight + Constants.GalleryTableViewPadding
        }
        
        return CGRectGetWidth(tableView.frame) / Constants.GalleryTableViewMobileAspectRatio
    }
    
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) where !cell.selected {
            return indexPath
        }
        
        return nil
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row > 0 {
            didPlayFirstItem = true
        }
        
        if let thisExperience = experience.childExperiences?[indexPath.row] {
            mediaTitleLabel.hidden = true
            mediaDescriptionLabel.hidden = true
            
            // Reset media detail views
            shareButton.hidden = true
            galleryPageControl.hidden = true
            galleryScrollView.hidden = true
            videoContainerView.hidden = false
            previewImageView.hidden = didPlayFirstItem
            previewPlayButton.hidden = didPlayFirstItem
            
            // Set new media detail views
            if let gallery = thisExperience.gallery {
                mediaTitleLabel.text = nil
                galleryScrollView.hidden = false
                videoContainerView.hidden = true
                previewImageView.hidden = true
                previewPlayButton.hidden = true
                
                galleryScrollView.loadGallery(gallery)
                if !gallery.isTurntable {
                    shareButton.hidden = false
                    shareButton.setTitle(String.localize("gallery.share_button").uppercaseString, forState: .Normal)
                    galleryPageControl.hidden = false
                    galleryPageControl.numberOfPages = gallery.totalCount
                }
            } else if thisExperience.isType(.AudioVisual) {
                mediaTitleLabel.text = thisExperience.metadata?.title
                mediaDescriptionLabel.text = thisExperience.metadata?.description
                mediaTitleLabel.hidden = false
                mediaDescriptionLabel.hidden = false
                playSelectedExperience()
            }
        }
    }
    
    private func playSelectedExperience() {
        if let selectedIndexPath = galleryTableView.indexPathForSelectedRow, selectedExperience = experience.childExperiences?[selectedIndexPath.row] {
            if let imageURL = selectedExperience.imageURL {
                previewImageView.setImageWithURL(imageURL, completion: nil)
            }
            
            if didPlayFirstItem, let videoURL = selectedExperience.videoURL, videoPlayerViewController = videoPlayerViewController ?? UIStoryboard.getNextGenViewController(VideoPlayerViewController) as? VideoPlayerViewController {
                previewImageView.hidden = true
                previewPlayButton.hidden = true
                
                videoPlayerViewController.player?.removeAllItems()
                videoPlayerViewController.mode = VideoPlayerMode.Supplemental
                videoPlayerViewController.queueTotalCount = experience.childExperiences?.count ?? 0
                videoPlayerViewController.queueCurrentIndex = selectedIndexPath.row
                videoPlayerViewController.view.frame = videoContainerView.bounds
                videoContainerView.addSubview(videoPlayerViewController.view)
                self.addChildViewController(videoPlayerViewController)
                videoPlayerViewController.didMoveToParentViewController(self)
                videoPlayerViewController.playVideoWithURL(videoURL)
                
                self.videoPlayerViewController = videoPlayerViewController
            }
        }
    }
    
    private func destroyVideoPlayer() {
        videoPlayerViewController?.willMoveToParentViewController(nil)
        videoPlayerViewController?.view.removeFromSuperview()
        videoPlayerViewController?.removeFromParentViewController()
        videoPlayerViewController = nil
    }
    
    // MARK: Actions
    @IBAction func onPlay() {
        didPlayFirstItem = true
        playSelectedExperience()
    }
    
    @IBAction func onShare(sender: UIButton?) {
        if !galleryScrollView.hidden, let url = galleryScrollView.currentImageURL, title = NGDMManifest.sharedInstance.mainExperience?.title {
            let activityViewController = UIActivityViewController(activityItems: [String.localize("gallery.share_message", variables: ["movie_name": title, "url": url.absoluteString])], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = sender
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func onPageControlValueChanged() {
        galleryScrollView.gotoPage(galleryPageControl.currentPage, animated: true)
    }
    
}