//
//  ChatFooterCell.swift
//  BillionsApp
//
//  Created by Tristate on 11.11.21.
//

import UIKit

class ChatFooterCell: UITableViewCell {
    @IBOutlet var viewBG: UIView!
    @IBOutlet var lblTitle: CustomLblSFPDBold!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
