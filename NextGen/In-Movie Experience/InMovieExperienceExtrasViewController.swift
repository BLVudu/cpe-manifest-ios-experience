//
//  InMovieExperienceViewController.swift
//

import UIKit
import NextGenDataManager

class InMovieExperienceExtrasViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate {
    
    private struct Constants {
        static let HeaderHeight: CGFloat = 35
        static let FooterHeight: CGFloat = 50
    }
    
    private struct SegueIdentifier {
        static let ShowTalent = "ShowTalentSegueIdentifier"
    }
    
    @IBOutlet weak private var talentTableView: UITableView?
    @IBOutlet weak private var backgroundImageView: UIImageView!
    @IBOutlet weak private var showLessContainer: UIView!
    @IBOutlet weak private var showLessGradientView: UIView!
    @IBOutlet weak private var showLessButton: UIButton!
    var appApperance: NGDMAppearance!
    
    private var didChangeTimeObserver: NSObjectProtocol?
    
    private var currentTime: Double = -1
    private var currentTalents = [Talent]()
    private var hiddenTalents: [Talent]?
    private var isShowingMore = false
    
    deinit {
        if let observer = didChangeTimeObserver {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
            didChangeTimeObserver = nil
        }
    }

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let backgroundImageURL = CurrentManifest.inMovieExperience.appearance?.backgroundImageURL {
            backgroundImageView.setImageWithURL(backgroundImageURL)
        }
        
        if let actors = CurrentManifest.mainExperience.orderedActors where actors.count > 0 {
            talentTableView?.registerNib(UINib(nibName: "TalentTableViewCell-Narrow", bundle: nil), forCellReuseIdentifier: TalentTableViewCell.ReuseIdentifier)
        } else {
            talentTableView?.removeFromSuperview()
            talentTableView = nil
        }
        
        let gradient = CAGradientLayer()
        gradient.frame = showLessGradientView.bounds
        gradient.colors = [UIColor.clearColor().CGColor, UIColor.blackColor().CGColor]
        showLessGradientView.layer.insertSublayer(gradient, atIndex: 0)
        
        showLessButton.setTitle(String.localize("talent.show_less"), forState: .Normal)
        
        didChangeTimeObserver = NSNotificationCenter.defaultCenter().addObserverForName(VideoPlayerNotification.DidChangeTime, object: nil, queue: nil) { [weak self] (notification) -> Void in
            if let strongSelf = self, userInfo = notification.userInfo, time = userInfo["time"] as? Double where time != strongSelf.currentTime {
                strongSelf.processTimedEvents(time)
            }
        }
    }
    
    func processTimedEvents(time: Double) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            self.currentTime = time
            
            let newTalents = NGDMTimedEvent.findByTimecode(time, type: .Talent).sort({ (timedEvent1, timedEvent2) -> Bool in
                return timedEvent1.talent!.billingBlockOrder < timedEvent2.talent!.billingBlockOrder
            }).map({ $0.talent! })
            
            if self.isShowingMore {
                self.hiddenTalents = newTalents
            } else {
                var hasNewData = newTalents.count != self.currentTalents.count
                if !hasNewData {
                    for talent in newTalents {
                        if !self.currentTalents.contains(talent) {
                            hasNewData = true
                            break
                        }
                    }
                }
                    
                if hasNewData {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.currentTalents = newTalents
                        self.talentTableView?.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentTalents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TalentTableViewCell.ReuseIdentifier) as! TalentTableViewCell
        if currentTalents.count > indexPath.row {
            cell.talent = currentTalents[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String.localize("label.actors").uppercaseString
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.HeaderHeight
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return Constants.FooterHeight
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return (isShowingMore ? nil : String.localize("talent.show_more"))
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textAlignment = .Center
            header.textLabel?.font = UIFont.themeCondensedFont(19)
            header.textLabel?.textColor = UIColor(netHex: 0xe5e5e5)
        }
    }
    
    func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footer = view as? UITableViewHeaderFooterView {
            footer.textLabel?.textAlignment = .Center
            footer.textLabel?.font = UIFont.themeCondensedFont(19)
            footer.textLabel?.textColor = UIColor(netHex: 0xe5e5e5)
            
            if footer.gestureRecognizers == nil || footer.gestureRecognizers!.count == 0 {
                footer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onTapFooter)))
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TalentTableViewCell, talent = cell.talent {
            self.performSegueWithIdentifier(SegueIdentifier.ShowTalent, sender: talent)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Actions
    func onTapFooter() {
        toggleShowMore()
    }
    
    @IBAction func onTapShowLess() {
        toggleShowMore()
    }
    
    func toggleShowMore() {
        isShowingMore = !isShowingMore
        showLessContainer.hidden = !isShowingMore
        
        if isShowingMore {
            currentTalents = CurrentManifest.mainExperience.orderedActors ?? [Talent]()
        } else if let talents = hiddenTalents {
            currentTalents = talents
        }
        
        talentTableView?.contentOffset = CGPointZero
        talentTableView?.reloadData()
    }
    
    // MARK: Storyboard Methods
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.ShowTalent {
            let talentDetailViewController = segue.destinationViewController as! TalentDetailViewController
            talentDetailViewController.title = String.localize("talentdetail.title")
            talentDetailViewController.talent = sender as! Talent
            talentDetailViewController.mode = TalentDetailMode.Synced
        }
    }

}
