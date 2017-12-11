//
//  SearchViewController.swift
//  MovieBrowser
//
//  Created by Aditya on 10/12/17.
//  Copyright © 2017 Aditya. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class SearchViewController: UIViewController {
    
    
    //Outlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    //Declarations
    
    var movies : [Movie] = [Movie]()
    var pageCount = 1
    var apiKey = "d2cf994786e92920bf7a4fbe77d2c9e7"
    

    override func viewDidLoad() {
        super.viewDidLoad()
      
        navigationController?.isNavigationBarHidden = true
        
         searchBar.becomeFirstResponder()
         searchBar.delegate = self
        
        movieCollectionView.delegate = self
        movieCollectionView.dataSource = self
        movieCollectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: "MovieCell")
        movieCollectionView.register(UINib(nibName: "MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier:"MovieCell")
        
        activityIndicator.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        navigationController?.isNavigationBarHidden = true
    }
    
    
    
    @IBAction func PopToDiscover(_ sender: Any) {

        navigationController?.popViewController(animated: true)
    }
    
    func fetchMovies(page : Int){
        
          let movieName = searchBar.text!.replacingOccurrences(of: " ", with: "%20")
        
        Alamofire.request("https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&language=en-US&query=\(movieName)&page=1&include_adult=false").responseJSON { response in
            
            if let json = response.result.value {
                
                if let receivedJson = json as? NSDictionary {
                    
                    if let totalResults = receivedJson.value(forKey: "total_results") as? Int {
                        
                        if totalResults == 0 {
                            
                            let alert = UIAlertController(title: "No results found", message: "We are out of movies, please use a different keyword", preferredStyle: .alert)
                            
                            let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
                            
                            alert.addAction(action)
                            
                            self.present(alert, animated: true, completion: nil)
                        }
                    }

                    if let resultsArray = receivedJson.value(forKey: "results") as? [[String : AnyObject]] {
                        
                        for movie in resultsArray {
                            
                            let movieName = movie["original_title"] as! String
                            let movieDescription = movie["overview"] as! String!
                            let movieReleaseDate = movie["release_date"] as! String!
                            let averageMovieRating = "\(String(describing: movie["vote_average"]!))"
                            
                            if let moviePosterPath = movie["poster_path"] as? String {
                                
                                let movie = Movie(name: movieName, poster: moviePosterPath, description: movieDescription!, averageRating: averageMovieRating
                                    , synopsis: movieDescription!, releaseDate: movieReleaseDate!)
                                
                                self.movies.append(movie)
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                
                    self.activityIndicator.isHidden = true
                    self.movieCollectionView.reloadData()
                }
            }
            
        }
  
    }
    

}

extension SearchViewController : UISearchBarDelegate , UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCollectionViewCell

        cell.movieTitle.text = movies[indexPath.row].name!
        cell.moviePosterView.sd_setImage(with: NSURL(string: "https://image.tmdb.org/t/p/w500\(movies[indexPath.row].poster!)")! as URL, placeholderImage: nil, options: .continueInBackground, progress: nil, completed: nil)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let lastItem = self.movies.count - 3
        
        if indexPath.row == lastItem {
            
            DispatchQueue.global(qos: .background).async {
                
                self.fetchMovies(page: self.pageCount + 1)
                
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        activityIndicator.isHidden = false
        
        if searchBar.text != nil {
            
            movies.removeAll()
            fetchMovies(page: pageCount)
            
            searchBar.resignFirstResponder()
            
            
        }
        
    }

    
}
