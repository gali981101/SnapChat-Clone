//
//  FeedCell.swift
//  SnapChatClone
//
//  Created by Terry Jason on 2023/8/29.
//

import UIKit

class FeedCell: UITableViewCell {

    @IBOutlet weak var feedUserNameLabel: UILabel!
    @IBOutlet weak var feedImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
