//
//  SecondTemplateViewController.swift
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
    
    @IBOutlet weak var galleryScrollView: ImageGalleryScrollView!
    @IBOutlet weak var galleryPageControl: UIPageControl!
    private var _galleryDidScrollToPageObserver: NSObjectProtocol?
    
    private var _didPlayFirstItem = false
    private var _previewPlayURL: NSURL?
    private var _userDidSelectNextItem = true
    
    private var _willPlayNextItemObserver: NSObjectProtocol!
    
    // MARK: Initialization
    deinit {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(_willPlayNextItemObserver)
        
        if let observer = _galleryDidScrollToPageObserver {
            center.removeObserver(observer)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        galleryScrollView.cleanInvisibleImages()
    }
    
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        galleryTableView.registerNib(UINib(nibName: String(VideoCell), bundle: nil), forCellReuseIdentifier: VideoCell.ReuseIdentifier)

        let selectedPath = NSIndexPath(forRow: 0, inSection: 0)
        self.galleryTableView.selectRowAtIndexPath(selectedPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
        self.tableView(self.galleryTableView, didSelectRowAtIndexPath: selectedPath)

        _willPlayNextItemObserver = NSNotificationCenter.defaultCenter().addObserverForName(kWBVideoPlayerWillPlayNextItem, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) -> Void in
            if let strongSelf = self, userInfo = notification.userInfo, index = userInfo["index"] as? Int where index < (strongSelf.experience.childExperiences?.count ?? 0) {
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                strongSelf.galleryTableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Top)
                strongSelf._userDidSelectNextItem = false
                strongSelf.tableView(strongSelf.galleryTableView, didSelectRowAtIndexPath: indexPath)
            }
        }
        
        _galleryDidScrollToPageObserver = NSNotificationCenter.defaultCenter().addObserverForName(ImageGalleryNotification.DidScrollToPage, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] (notification) in
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
        if let thisExperience = experience.childExperiences?[indexPath.row] {
            mediaTitleLabel.text = thisExperience.metadata?.title
            mediaDescriptionLabel.text = thisExperience.metadata?.description
            
            // Reset media detail views
            galleryPageControl.hidden = true
            galleryScrollView.hidden = true
            videoContainerView.hidden = false
            previewImageView?.hidden = _didPlayFirstItem
            previewPlayButton?.hidden = _didPlayFirstItem
            mediaRuntimeLabel.text = nil
            
            // Set new media detail views
            if let gallery = thisExperience.gallery {
                galleryPageControl.hidden = false
                galleryScrollView.hidden = false
                videoContainerView.hidden = true
                previewImageView?.hidden = true
                previewPlayButton?.hidden = true
                
                galleryPageControl.numberOfPages = gallery.pictures?.count ?? 0
                galleryScrollView.gallery = gallery
            } else if thisExperience.isType(.AudioVisual) {
                let runtime = thisExperience.videoRuntime
                if runtime > 0 {
                    mediaRuntimeLabel.text = String.localize("label.runtime", variables: ["runtime": runtime.timeString()])
                }
            
                if let videoURL = thisExperience.videoURL, videoPlayerViewController = _videoPlayerViewController ?? UIStoryboard.getNextGenViewController(VideoPlayerViewController) as? VideoPlayerViewController {
                    if let player = videoPlayerViewController.player {
                        player.removeAllItems()
                    }
                    
                    videoPlayerViewController.mode = VideoPlayerMode.Supplemental
                    videoPlayerViewController.curIndex = indexPath.row
                    videoPlayerViewController.indexMax = experience.childExperiences?.count ?? 0
                    
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