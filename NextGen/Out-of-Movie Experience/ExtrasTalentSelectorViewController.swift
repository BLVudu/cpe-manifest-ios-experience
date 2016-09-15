//
//  ExtrasTalentSelectorViewController.swift
//


import UIKit
import AVFoundation
import NextGenDataManager

class ExtrasTalentSelectorViewController: ExtrasExperienceViewController, UITableViewDelegate, UITableViewDataSource, TalentDetailViewPresenter {
    
    @IBOutlet weak var talentTableView: UITableView!
    @IBOutlet weak var talentDetailView: UIView!
    
    fileprivate var talentDetailViewController: TalentDetailViewController?
    fileprivate var selectedIndexPath: IndexPath?
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        talentTableView.register(UINib(nibName: "TalentTableViewCell-Narrow", bundle: nil), forCellReuseIdentifier: TalentTableViewCell.ReuseIdentifier)
        
        showBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let path = IndexPath(row: 0, section: 0)
        self.talentTableView.selectRow(at: path, animated: false, scrollPosition: .top)
        self.tableView(self.talentTableView, didSelectRowAt: path)
    }
    
    // MARK: Talent Details
    func showTalentDetailView() {
        if selectedIndexPath != nil {
            if let cell = talentTableView?.cellForRow(at: selectedIndexPath!) as? TalentTableViewCell, let talent = cell.talent {
                if talentDetailViewController != nil {
                    talentDetailViewController!.loadTalent(talent)
                } else {
                    if let talentDetailViewController = UIStoryboard.getNextGenViewController(TalentDetailViewController.self) as? TalentDetailViewController {
                        talentDetailViewController.talent = talent
                        
                        talentDetailViewController.view.frame = talentDetailView.bounds
                        talentDetailView.addSubview(talentDetailViewController.view)
                        self.addChildViewController(talentDetailViewController)
                        talentDetailViewController.didMove(toParentViewController: self)
                        
                        talentDetailView.alpha = 0
                        talentDetailView.isHidden = false
                        showBackButton()
                        
                        UIView.animate(withDuration: 0.25, animations: {
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
            talentTableView?.deselectRow(at: selectedIndexPath!, animated: true)
            selectedIndexPath = nil
        }
        
        showHomeButton()
        
        UIView.animate(withDuration: 0.25, animations: {
            self.talentDetailView.alpha = 0
        }, completion: { (Bool) -> Void in
            self.talentDetailView.isHidden = true
            self.talentDetailViewController?.willMove(toParentViewController: nil)
            self.talentDetailViewController?.view.removeFromSuperview()
            self.talentDetailViewController?.removeFromParentViewController()
            self.talentDetailViewController = nil
        })
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NGDMManifest.sharedInstance.mainExperience?.orderedActors?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TalentTableViewCell.ReuseIdentifier) as! TalentTableViewCell
        cell.talent = NGDMManifest.sharedInstance.mainExperience?.orderedActors?[indexPath.row]
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return (indexPath != selectedIndexPath ? indexPath : nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        showTalentDetailView()
    }
    
    // MARK: TalentDetailViewPresenter
    func talentDetailViewShouldClose() {
        hideTalentDetailView()
    }
    
}
