//
//  SearchTableViewCell.swift
//  FinalProject
//
//  Created by 컴퓨터공학부 on 2023/06/11.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    
    @IBOutlet weak var Poster: UIImageView!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Id: UILabel!
    @IBOutlet weak var Overview: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
