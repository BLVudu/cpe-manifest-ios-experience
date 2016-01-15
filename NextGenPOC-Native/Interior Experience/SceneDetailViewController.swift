//
//  SceneDetailViewController.swift
//  NextGenPOC-Native
//
//  Created by Alec Ananian on 1/13/16.
//  Copyright © 2016 Warner Bros. Entertainment, Inc.. All rights reserved.
//

import UIKit

class SceneDetailViewController: UIViewController {
    
    @IBOutlet weak var triviaCellView: SceneDetailCellView!
    @IBOutlet weak var mapCellView: SceneDetailCellView!
    @IBOutlet weak var galleryCellView: SceneDetailCellView!
    @IBOutlet weak var shopCellView: SceneDetailCellView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
