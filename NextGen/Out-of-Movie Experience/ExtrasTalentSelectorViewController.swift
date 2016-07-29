//
//  ExtrasTalentSelectorViewController.swift
//


import UIKit
import AVFoundation
import NextGenDataManager

class ExtrasTalentSelectorViewController: ExtrasExperienceViewController, UITableViewDelegate, UITableViewDataSource, TalentDetailViewPresenter {
    
    @IBOutlet weak var talentTableView: UITableView!
    @IBOutlet weak var talentDetailView: UIView!
    
    private var talentDetailViewController: TalentDetailViewController?
    private var selectedIndexPath: NSIndexPath?
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        talentTableView.registerNib(UINib(nibName: "TalentTableViewCell-Narrow", bundle: nil), forCellReuseIdentifier: TalentTableViewCell.ReuseIdentifier)
        
        showBackButton()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let path = NSIndexPath(forRow: 0, inSection: 0)
        self.talentTableView.selectRowAtIndexPath(path, animated: false, scrollPosition: .Top)
        self.tableView(self.talentTableView, didSelectRowAtIndexPath: path)
    }
    
    // MARK: Talent Details
    func showTalentDetailView() {
        if selectedIndexPath != nil {
            if let cell = talentTableView?.cellForRowAtIndexPath(selectedIndexPath!) as? TalentTableViewCell, talent = cell.talent {
                if talentDetailViewController != nil {
                    talentDetailViewController!.loadTalent(talent)
                } else {
                    if let talentDetailViewController = UIStoryboard.getNextGenViewController(TalentDetailViewController) as? TalentDetailViewController {
                        talentDetailViewController.talent = talent
                        
                        talentDetailViewController.view.frame = talentDetailView.bounds
                        talentDetailView.addSubview(talentDetailViewController.view)
                        self.addChildViewController(talentDetailViewController)
                        talentDetailViewController.didMoveToParentViewController(self)
                        
                        talentDetailView.alpha = 0
                        talentDetailView.hidden = false
                        showBackButton()
                        
                        UIView.animateWithDuration(0.25, animations: {
                            self.talentDetailView.alpha = 1
                        })
                        
                        self.talentDetailViewController = talentDetailViewController
                    }
                }
            }
        }
    }
    
    func hideTalentDetailView() {
        if selectedIndexPath != nil {
            talentTableView?.deselectRowAtIndexPath(selectedIndexPath!, animated: true)
            selectedIndexPath = nil
        }
        
        showHomeButton()
        
        UIView.animateWithDuration(0.25, animations: {
            self.talentDetailView.alpha = 0
        }, completion: { (Bool) -> Void in
            self.talentDetailView.hidden = true
            self.talentDetailViewController?.willMoveToParentViewController(nil)
            self.talentDetailViewController?.view.removeFromSuperview()
            self.talentDetailViewController?.removeFromParentViewController()
            self.talentDetailViewController = nil
        })
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NGDMManifest.sharedInstance.mainExperience?.orderedActors?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TalentTableViewCell.ReuseIdentifier) as! TalentTableViewCell
        cell.talent = NGDMManifest.sharedInstance.mainExperience?.orderedActors?[indexPath.row]
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return (indexPath != selectedIndexPath ? indexPath : nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
        showTalentDetailView()
    }
    
    // MARK: TalentDetailViewPresenter
    func talentDetailViewShouldClose() {
        hideTalentDetailView()
    }
    
}
