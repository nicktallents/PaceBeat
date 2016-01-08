//
//  SongTableViewCell.swift
//  PaceBeat
//
//  Created by Nicholas Tallents on 10/15/15.
//  Copyright © 2015 Nicholas Tallents. All rights reserved.
//

import UIKit

protocol SongCellDelegate {
    func songMenuButtonPressed()
    var  selectedCell : Int { get set }
}

class SongTableViewCell: UITableViewCell {

    @IBOutlet weak var AlbumImageView: UIImageView!
    @IBOutlet weak var SongTitleLabel: UILabel!
    @IBOutlet weak var ArtistAlbumLabel: UILabel!
    @IBOutlet weak var BpmLabel: UILabel!
    
    var delegate : SongCellDelegate!
    var index    : Int = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func EllipsesButtonPressed(sender: AnyObject) {
        delegate.selectedCell = index
        delegate.songMenuButtonPressed()
    }
}
