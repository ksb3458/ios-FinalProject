//
//  TopTableViewCell.swift
//  FinalProject
//
//  Created by 컴퓨터공학부 on 2023/06/17.
//

import UIKit

class TopTableViewCell: UITableViewCell {

    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var poster: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
