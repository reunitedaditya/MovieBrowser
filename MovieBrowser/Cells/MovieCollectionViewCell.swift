//
//  MovieCollectionViewCell.swift
//  MovieBrowser
//
//  Created by Aditya on 10/12/17.
//  Copyright © 2017 Aditya. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    
    //Outlets
    
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var moviePosterView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
