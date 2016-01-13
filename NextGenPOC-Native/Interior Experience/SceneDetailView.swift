//
//  SceneDetailView.swift
//  NextGenPOC-Native
//
//  Created by Alec Ananian on 1/12/16.
//  Copyright © 2016 Sedinam Gadzekpo. All rights reserved.
//

import UIKit

class SceneDetailView: UIView {
    
    @IBOutlet weak var triviaCellView: SceneDetailCellView!
    @IBOutlet weak var mapCellView: SceneDetailCellView!
    @IBOutlet weak var galleryCellView: SceneDetailCellView!
    @IBOutlet weak var shopCellView: SceneDetailCellView!
    
    override func awakeFromNib() {
        triviaCellView.viewType = .Detail
        mapCellView.viewType = .Map
        galleryCellView.viewType = .Image
        shopCellView.viewType = .Shop
    }

}
