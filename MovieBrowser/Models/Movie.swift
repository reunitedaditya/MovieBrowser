//
//  Movie.swift
//  MovieBrowser
//
//  Created by Aditya on 11/12/17.
//  Copyright © 2017 Aditya. All rights reserved.
//

import Foundation

class Movie {
    
    var name : String?
    var poster : String?
    var description : String?
    var averageRating : String?
    var synposis : String?
    var releaseDate : String?
    
    
    init(name : String , poster : String , description : String , averageRating : String , synopsis : String , releaseDate : String) {
        
        self.name = name
        self.poster = poster
        self.description = description
        self.averageRating = averageRating
        self.synposis = synopsis
        self.releaseDate = releaseDate
    }
    
}
