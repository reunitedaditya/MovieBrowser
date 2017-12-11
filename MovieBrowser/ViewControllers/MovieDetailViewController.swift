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
    
    var movie : Movie!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupController()

    }

    //Setup ViewController
    
    func setupController(){

        posterImageView.sd_setImage(with: NSURL(string: "https://image.tmdb.org/t/p/w500\(movie.poster!)")! as URL, placeholderImage: nil, options: .continueInBackground, progress: nil, completed: nil)
        movieTitleLabel.text = movie?.name!
        averageRatingLabel.text = movie?.averageRating!
        releaseDateLabel.text = movie?.releaseDate!
        movieSynopsisLabel.text = movie?.synposis!
        
    }


}
