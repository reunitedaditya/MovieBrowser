//
//  MovieDetailViewController.swift
//  MovieBrowser
//
//  Created by Aditya on 10/12/17.
//  Copyright © 2017 Aditya. All rights reserved.
//

import UIKit
import SDWebImage

class MovieDetailViewController: UIViewController {
    
    
    //Outlets
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var movieSynopsisLabel: UILabel!
    
    
    //Declarations
    
    var posterImagePath : String?
    var movieTitle : String?
    var averageRating : String?
    var releaseDate : String?
    var synopsis : String?
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupController()

    }
    
    func setupController(){
        
        posterImageView.sd_setImage(with: NSURL(string: "https://image.tmdb.org/t/p/w500\(posterImagePath!)")! as URL, placeholderImage: nil, options: .continueInBackground, progress: nil, completed: nil)
        movieTitleLabel.text = movieTitle!
        averageRatingLabel.text = averageRating!
        releaseDateLabel.text = releaseDate!
        movieSynopsisLabel.text = synopsis!
        
    }


}
