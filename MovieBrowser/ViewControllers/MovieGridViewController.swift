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

    var movies : [Movie] = [Movie]()
    var pageCount = 1
    var leftBarButtonItem : UIBarButtonItem?
    var currentFilter : filter = .popular
    var apiKey = "d2cf994786e92920bf7a4fbe77d2c9e7"
    
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearch))
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = leftBarButtonItem!
        navigationController?.navigationBar.topItem?.title = "Discover"
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.isNavigationBarHidden = false
    }
    
    
    // Fetch Movies from API
    
    func fetchMovies(page : Int , movieFilter : filter){
        
        var filter : String!
        
        if movieFilter == .popular {
            
            filter = "popularity.desc"
            
        } else {
            
            filter = "vote_average.asc"
        }
        
        
        Alamofire.request("https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&language=en-US&sort_by=\(filter!)&include_adult=false&include_video=false&page=\(page)").responseJSON { response in
            
            if let json = response.result.value {
              
                if let receivedJson = json as? NSDictionary {

                    if let resultsArray = receivedJson.value(forKey: "results") as? [[String : AnyObject]] {
  
                        for movie in resultsArray {
                           
                            let movieName = movie["original_title"] as! String
                            let movieDescription = movie["overview"] as! String!
                            
                            let movieReleaseDate = movie["release_date"] as! String!
                            
                            let averageMovieRating = "\(String(describing: movie["vote_average"]!))"
                    
                            if let moviePosterPath = movie["poster_path"] as? String {
                                
                            
                            let movie = Movie(name: movieName, poster: moviePosterPath, description: movieDescription!, averageRating: averageMovieRating , synopsis: movieDescription!, releaseDate: movieReleaseDate!)
                                
                                self.movies.append(movie)

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
    
    
    
   //Open SearchViewController
    
    @objc func showSearch(){
        
        let searchController = SearchViewController(nibName: "SearchViewController", bundle: nil)
        self.navigationController?.pushViewController(searchController, animated: true)
        
    }
    
    
    //Change filter of the GridView
    
    @objc func changeFilter(){
        
          movies.removeAll()
        
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
    
    
    //CollectionView DataSource and Delegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCollectionViewCell
        
        cell.movieTitle.text = movies[indexPath.row].name!
        cell.moviePosterView.sd_setImage(with:   NSURL(string: "https://image.tmdb.org/t/p/w500\(movies[indexPath.row].poster!)")! as URL, placeholderImage: nil, options: .continueInBackground, progress: nil, completed: nil)
      

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let lastItem = self.movies.count - 3
        
        if indexPath.row == lastItem {
     
            DispatchQueue.global(qos: .background).async {
                
                self.fetchMovies(page:  self.pageCount + 1, movieFilter: filter.popular)
                
            }
        }
        self.pageCount = self.pageCount + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detailedViewController = MovieDetailViewController(nibName: "MovieDetailViewController", bundle: nil)
        
        detailedViewController.posterImagePath = movies[indexPath.row].poster!
        detailedViewController.averageRating = "\(movies[indexPath.row].averageRating!) Stars"
        detailedViewController.releaseDate = movies[indexPath.row].releaseDate!
        detailedViewController.movieTitle = movies[indexPath.row].name!
        detailedViewController.synopsis = movies[indexPath.row].description!
        
        self.navigationController?.pushViewController(detailedViewController, animated: true)
        
    }
    
    
    
    //CollectionView DelegateFlowLayout Methods
    
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

