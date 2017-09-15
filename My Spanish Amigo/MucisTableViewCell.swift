//
//  MucisTableViewCell.swift
//  My Spanish Amigo
//
//  Created by Srivastava, Richa on 03/06/17.
//  Copyright © 2017 ShivHari Apps. All rights reserved.
//

import UIKit

class MucisTableViewCell: UITableViewCell {

    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var musicImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
