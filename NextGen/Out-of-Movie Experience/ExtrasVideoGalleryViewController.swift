//
//  SecondTemplateViewController.swift
//

import UIKit
import NextGenDataManager

class ExtrasVideoGalleryViewController: ExtrasExperienceViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    private struct Constants {
        static let GalleryTableViewImageAspectRatio: CGFloat = 16 / 9
        static let GalleryTableViewLabelHeight: CGFloat = 10
        static let GalleryTableViewPadding: CGFloat = 50
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
    
    @IBOutlet private var containerTopConstraint: NSLayoutConstraint?
    @IBOutlet private var containerBottomConstraint: NSLayoutConstraint?
    @IBOutlet private var containerAspectRatioConstraint: NSLayoutConstraint?
    
    @IBOutlet weak private var shareButton: UIButton!
    
    private var didInitialSetup = false
    private var didPlayFirstItem = false
    
    private var willPlayNextItemObserver: NSObjectProtocol?
    private var didEndLastVideoObserver: NSObjectProtocol?
    
    // MARK: Initialization
    deinit {
        let center = NotificationCenter.default
        
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

        willPlayNextItemObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: VideoPlayerNotification.WillPlayNextItem), object: nil, queue: OperationQueue.main) { [weak self] (notification) -> Void in
            if let strongSelf = self, let userInfo = (notification as NSNotification).userInfo, let index = userInfo["index"] as? Int , index < (strongSelf.experience.childExperiences?.count ?? 0) {
                let indexPath = IndexPath(row: index, section: 0)
                strongSelf.galleryTableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.top)
                strongSelf.tableView(strongSelf.galleryTableView, didSelectRowAt: indexPath)
            }
        }
        
        didEndLastVideoObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: VideoPlayerNotification.DidEndLastVideo), object: nil, queue: OperationQueue.main, using: { [weak self] (_) in
            self?.previewImageView.isHidden = false
            self?.previewPlayButton.isHidden = false
            self?.destroyVideoPlayer()
            
            if let selectedIndexPath = self?.galleryTableView.indexPathForSelectedRow, let cell = self?.galleryTableView.cellForRow(at: selectedIndexPath) as? VideoCell {
                cell.setWatched()
            }
        })
        
        galleryDidScrollToPageObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ImageGalleryNotification.DidScrollToPage), object: nil, queue: OperationQueue.main, using: { [weak self] (notification) in
            if let strongSelf = self, let page = (notification as NSNotification).userInfo?["page"] as? Int {
                strongSelf.galleryPageControl.currentPage = page
            }
        })
        
        galleryTableView.register(UINib(nibName: VideoCell.NibName, bundle: nil), forCellReuseIdentifier: VideoCell.ReuseIdentifier)
        galleryScrollView.allowsFullScreen = DeviceType.IS_IPAD
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return (DeviceType.IS_IPAD ? .landscape : .all)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !didInitialSetup {
            let selectedPath = IndexPath(row: 0, section: 0)
            galleryTableView.selectRow(at: selectedPath, animated: false, scrollPosition: UITableViewScrollPosition.top)
            self.tableView(galleryTableView, didSelectRowAt: selectedPath)
            didInitialSetup = true
        } else {
            galleryScrollView.layoutPages()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let toLandscape = (size.width > size.height)
        containerAspectRatioConstraint?.isActive = !toLandscape
        containerTopConstraint?.constant = (toLandscape ? 0 : ExtrasExperienceViewController.Constants.TitleImageHeight)
        containerBottomConstraint?.isActive = !toLandscape
    }
    
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VideoCell.ReuseIdentifier, for: indexPath) as! VideoCell
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        cell.experience = experience.childExperiences?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return experience.childExperiences?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if DeviceType.IS_IPAD {
            return (tableView.frame.width / Constants.GalleryTableViewImageAspectRatio) + Constants.GalleryTableViewLabelHeight + Constants.GalleryTableViewPadding
        }
        
        return tableView.frame.width / Constants.GalleryTableViewMobileAspectRatio
    }
    
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let cell = tableView.cellForRow(at: indexPath), !cell.isSelected {
            return indexPath
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row > 0 {
            didPlayFirstItem = true
        }
        
        if let thisExperience = experience.childExperiences?[indexPath.row] {
            mediaTitleLabel.isHidden = true
            mediaDescriptionLabel.isHidden = true
            
            // Reset media detail views
            shareButton.isHidden = true
            galleryPageControl.isHidden = true
            galleryScrollView.isHidden = true
            videoContainerView.isHidden = false
            previewImageView.isHidden = didPlayFirstItem
            previewPlayButton.isHidden = didPlayFirstItem
            
            // Set new media detail views
            if let gallery = thisExperience.gallery {
                mediaTitleLabel.text = nil
                galleryScrollView.isHidden = false
                videoContainerView.isHidden = true
                previewImageView.isHidden = true
                previewPlayButton.isHidden = true
                
                galleryScrollView.loadGallery(gallery)
                if !gallery.isTurntable {
                    shareButton.isHidden = false
                    shareButton.setTitle(String.localize("gallery.share_button").uppercased(), for: UIControlState())
                    if gallery.totalCount < 20 {
                        galleryPageControl.isHidden = false
                        galleryPageControl.numberOfPages = gallery.totalCount
                    }
                }
            } else if thisExperience.isType(.audioVisual) {
                mediaTitleLabel.text = thisExperience.metadata?.title
                mediaDescriptionLabel.text = thisExperience.metadata?.description
                mediaTitleLabel.isHidden = false
                mediaDescriptionLabel.isHidden = false
                playSelectedExperience()
            }
        }
    }
    
    private func playSelectedExperience() {
        if let selectedIndexPath = galleryTableView.indexPathForSelectedRow, let selectedExperience = experience.childExperiences?[selectedIndexPath.row] {
            if let imageURL = selectedExperience.imageURL {
                previewImageView.sd_setImage(with: imageURL)
            }
            
            if didPlayFirstItem, let videoURL = selectedExperience.videoURL, let videoPlayerViewController = videoPlayerViewController ?? UIStoryboard.getNextGenViewController(VideoPlayerViewController.self) as? VideoPlayerViewController {
                previewImageView.isHidden = true
                previewPlayButton.isHidden = true
                
                videoPlayerViewController.player?.removeAllItems()
                videoPlayerViewController.mode = VideoPlayerMode.supplemental
                videoPlayerViewController.queueTotalCount = experience.childExperiences?.count ?? 0
                videoPlayerViewController.queueCurrentIndex = (selectedIndexPath as NSIndexPath).row
                videoPlayerViewController.view.frame = videoContainerView.bounds
                videoContainerView.addSubview(videoPlayerViewController.view)
                self.addChildViewController(videoPlayerViewController)
                videoPlayerViewController.didMove(toParentViewController: self)
                videoPlayerViewController.playVideo(with: videoURL)
                
                if !DeviceType.IS_IPAD && videoPlayerViewController.fullScreenButton != nil {
                    videoPlayerViewController.fullScreenButton.removeFromSuperview()
                }
                
                self.videoPlayerViewController = videoPlayerViewController
            }
        }
    }
    
    private func destroyVideoPlayer() {
        videoPlayerViewController?.willMove(toParentViewController: nil)
        videoPlayerViewController?.view.removeFromSuperview()
        videoPlayerViewController?.removeFromParentViewController()
        videoPlayerViewController = nil
    }
    
    // MARK: Actions
    @IBAction func onPlay() {
        didPlayFirstItem = true
        playSelectedExperience()
    }
    
    @IBAction func onShare(_ sender: UIButton?) {
        if !galleryScrollView.isHidden, let url = galleryScrollView.currentImageURL, let title = NGDMManifest.sharedInstance.mainExperience?.title {
            let activityViewController = UIActivityViewController(activityItems: [String.localize("gallery.share_message", variables: ["movie_name": title, "url": url.absoluteString])], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = sender
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func onPageControlValueChanged() {
        galleryScrollView.gotoPage(galleryPageControl.currentPage, animated: true)
    }
    
}
