//
//  InMovieExperienceViewController.swift
//

import UIKit
import NextGenDataManager

class InMovieExperienceExtrasViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate {
    
    struct SegueIdentifier {
        static let ShowTalent = "ShowTalentSegueIdentifier"
    }
    
    @IBOutlet weak var talentTableView: UITableView?
    @IBOutlet weak var backgroundImageView: UIImageView!
    var appApperance: NGDMAppearance!
    
    private var _didChangeTimeObserver: NSObjectProtocol!
    
    private var _currentTime: Double = -1
    private var _currentTimedEvents = [NGDMTimedEvent]()
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(_didChangeTimeObserver)
    }

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let backgroundImageURL = CurrentManifest.inMovieExperience.appearance?.backgroundImageURL {
            backgroundImageView.setImageWithURL(backgroundImageURL)
        }
        
        if let actors = CurrentManifest.mainExperience.orderedActors where actors.count > 0 {
            talentTableView?.registerNib(UINib(nibName: "TalentTableViewCell-Narrow", bundle: nil), forCellReuseIdentifier: "TalentTableViewCell")
        } else {
            talentTableView?.removeFromSuperview()
            talentTableView = nil
        }
        
        _didChangeTimeObserver = NSNotificationCenter.defaultCenter().addObserverForName(VideoPlayerNotification.DidChangeTime, object: nil, queue: nil) { [weak self] (notification) -> Void in
            if let strongSelf = self, userInfo = notification.userInfo, time = userInfo["time"] as? Double {
                if time != strongSelf._currentTime {
                    strongSelf.processTimedEvents(time)
                }
            }
        }
    }
    
    func processTimedEvents(time: Double) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            self._currentTime = time
            
            let newTimedEvents = NGDMTimedEvent.findByTimecode(time, type: .Talent).sort({ (timedEvent1, timedEvent2) -> Bool in
                return timedEvent1.talent!.billingBlockOrder < timedEvent2.talent!.billingBlockOrder
            })
            
            var hasNewData = newTimedEvents.count != self._currentTimedEvents.count
            if !hasNewData {
                for timedEvent in newTimedEvents {
                    if !self._currentTimedEvents.contains(timedEvent) {
                        hasNewData = true
                        break
                    }
                }
            }
                
            if hasNewData {
                dispatch_async(dispatch_get_main_queue()) {
                    self._currentTimedEvents = newTimedEvents
                    self.talentTableView?.reloadData()
                }
            }
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _currentTimedEvents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TalentTableViewCell.ReuseIdentifier) as! TalentTableViewCell
        if _currentTimedEvents.count > indexPath.row {
            cell.talent = _currentTimedEvents[indexPath.row].talent
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String.localize("label.actors").uppercaseString
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textAlignment = NSTextAlignment.Center
        header.textLabel?.font = UIFont.themeCondensedFont(19)
        header.textLabel?.textColor = UIColor(netHex: 0xe5e5e5)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? TalentTableViewCell, talent = cell.talent {
            self.performSegueWithIdentifier(SegueIdentifier.ShowTalent, sender: talent)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
