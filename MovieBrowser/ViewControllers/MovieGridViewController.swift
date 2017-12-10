//
//  MovieGridViewController.swift
//  MovieBrowser
//
//  Created by Aditya on 10/12/17.
//  Copyright © 2017 Aditya. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class MovieGridViewController: UIViewController {
    
    
    //Outlets
    
    @IBOutlet weak var movieCollectionView: UICollectionView!
    
    //Declarations
    
    var movieNames = [String]()
    var moviePosterPaths = [String]()
    var movieDescriptions = [String]()
    var movieAverageRatings = [String]()
    var movieReleaseDates = [String]()
    var pageCount = 1
    var leftBarButtonItem : UIBarButtonItem?
    var currentFilter : filter = .popular
    
    enum filter {
        case topRated
        case popular
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        movieCollectionView.delegate  = self
        movieCollectionView.dataSource = self
        movieCollectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: "MovieCell")
        movieCollectionView.register(UINib(nibName: "MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier:"MovieCell")
        
        fetchMovies(page: pageCount, movieFilter: currentFilter)
        
        let barButtonItem = UIBarButtonItem(title: "Popular", style: .plain, target: self, action: #selector(changeFilter))
        leftBarButtonItem = barButtonItem
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(addTapped))
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = leftBarButtonItem!
        navigationController?.navigationBar.topItem?.title = "Discover"
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.isNavigationBarHidden = false
        
    }
    
    
    
    func fetchMovies(page : Int , movieFilter : filter){
        
        var filter : String!
        
        if movieFilter == .popular {
            
            filter = "popularity.desc"
            
        } else {
            
            filter = "vote_average.asc"
        }
        
        
        Alamofire.request("https://api.themoviedb.org/3/discover/movie?api_key=d2cf994786e92920bf7a4fbe77d2c9e7&language=en-US&sort_by=\(filter!)&include_adult=false&include_video=false&page=\(page)").responseJSON { response in
            
            if let json = response.result.value {
              
                if let receivedJson = json as? NSDictionary {
                    
                    print(receivedJson)
         
                    if let resultsArray = receivedJson.value(forKey: "results") as? [[String : AnyObject]] {
  
                        for movie in resultsArray {
                           
                            let movieName = movie["original_title"] as! String
                            let movieDescription = movie["overview"] as! String!
                            
                            let movieReleaseDate = movie["release_date"] as! String!
                            
                            
                            if let moviePosterPath = movie["poster_path"] as? String {
                                
                                self.moviePosterPaths.append(moviePosterPath)
                                self.movieNames.append(movieName)
                                self.movieDescriptions.append(movieDescription!)
//                                self.movieAverageRatings.append(movieAvgRating)
                                self.movieReleaseDates.append(movieReleaseDate!)
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                
                    self.movieCollectionView.reloadData()
                }
            }

        }
    }
    
    
    
    
    
    @objc func addTapped(){
        
        let searchController = SearchViewController(nibName: "SearchViewController", bundle: nil)
        self.navigationController?.pushViewController(searchController, animated: true)
        
    }
    
    @objc func changeFilter(){
        
        movieNames.removeAll()
        movieReleaseDates.removeAll()
        movieDescriptions.removeAll()
        moviePosterPaths.removeAll()
        movieAverageRatings.removeAll()
        movieDescriptions.removeAll()
        
        if currentFilter == .topRated {
            
          leftBarButtonItem?.title = "Popular"
          currentFilter = .popular
    
        } else {
            
            leftBarButtonItem?.title = "Top Rated"
            currentFilter = .topRated
        }
        
        fetchMovies(page: 1, movieFilter: currentFilter)
        
    }
    
    
}

extension MovieGridViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return movieNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCollectionViewCell
        
        cell.movieTitle.text = movieNames[indexPath.row]
        cell.moviePosterView.sd_setImage(with:   NSURL(string: "https://image.tmdb.org/t/p/w500\(moviePosterPaths[indexPath.row])")! as URL, placeholderImage: nil, options: .continueInBackground, progress: nil, completed: nil)
      

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let lastItem = self.movieNames.count - 3
        
        if indexPath.row == lastItem {
     
            DispatchQueue.global(qos: .background).async {
                
                self.fetchMovies(page:  self.pageCount + 1, movieFilter: filter.popular)
   
            }
 
        }
        self.pageCount = self.pageCount + 1
 
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detailedViewController = MovieDetailViewController(nibName: "MovieDetailViewController", bundle: nil)
        
        detailedViewController.posterImagePath = moviePosterPaths[indexPath.row]
        detailedViewController.averageRating = "5.0 Stars"
        detailedViewController.releaseDate = movieReleaseDates[indexPath.row]
        detailedViewController.movieTitle = movieNames[indexPath.row]
        detailedViewController.synopsis = movieDescriptions[indexPath.row]
        
        self.navigationController?.pushViewController(detailedViewController, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width : movieCollectionView.bounds.width/3.0 - 1 , height : 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(1,1,1,1)
    }
}

