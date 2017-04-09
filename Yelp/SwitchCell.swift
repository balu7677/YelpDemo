//
//  SwitchCell.swift
//  Yelp
//
//  Created by Tummala, Balaji on 4/7/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
    func SwitchCell(SwitchCell : SwitchCell, cellSelected: Bool)
}

class SwitchCell: UITableViewCell {

    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!
    weak var delegate: SwitchCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        onSwitch.addTarget(self, action: #selector(SwitchCell.SwitchCellSelect), for: UIControlEvents.valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func SwitchCellSelect(){
       delegate?.SwitchCell(SwitchCell: self, cellSelected: onSwitch.isOn)
    }

}
