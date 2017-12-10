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
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var movieNames = [String]()
    var moviePosterPaths = [String]()
    var movieDescriptions = [String]()
    var movieAverageRatings = [String]()
    var movieReleaseDates = [String]()
    var pageCount = 1
    

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
        
        Alamofire.request("https://api.themoviedb.org/3/search/movie?api_key=d2cf994786e92920bf7a4fbe77d2c9e7&language=en-US&query=\(movieName)&page=1&include_adult=false").responseJSON { response in
            
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
                            
                            if let moviePosterPath = movie["poster_path"] as? String {
                                
                                self.moviePosterPaths.append(moviePosterPath)
                                self.movieNames.append(movieName)
                                self.movieDescriptions.append(movieDescription!)
                                self.movieReleaseDates.append(movieReleaseDate!)
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    
                    print(self.moviePosterPaths)
                    self.activityIndicator.isHidden = true
                    self.movieCollectionView.reloadData()
                }
            }
            
        }
  
    }
    

}

extension SearchViewController : UISearchBarDelegate , UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return movieNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCollectionViewCell

        cell.movieTitle.text = movieNames[indexPath.row]
        cell.moviePosterView.sd_setImage(with: NSURL(string: "https://image.tmdb.org/t/p/w500\(moviePosterPaths[indexPath.row])")! as URL, placeholderImage: nil, options: .continueInBackground, progress: nil, completed: nil)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let lastItem = self.movieNames.count - 3
        
        if indexPath.row == lastItem {
            
            DispatchQueue.global(qos: .background).async {
                
                self.fetchMovies(page: self.pageCount + 1)
                
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        activityIndicator.isHidden = false
        
        if searchBar.text != nil {
            
            movieNames.removeAll()
            moviePosterPaths.removeAll()
            fetchMovies(page: pageCount)
            
            searchBar.resignFirstResponder()
            
        }
        
    }

    
}
