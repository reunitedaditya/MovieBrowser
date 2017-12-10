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
    
    //Variables
    
    var movieNames = [String]()
    var moviePosterPaths = [String]()
    var pageCount = 1
    

    override func viewDidLoad() {
        super.viewDidLoad()
        movieCollectionView.delegate  = self
        movieCollectionView.dataSource = self
        movieCollectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: "MovieCell")
        movieCollectionView.register(UINib(nibName: "MovieCollectionViewCell", bundle: nil), forCellWithReuseIdentifier:"MovieCell")
        
        fetchMovies(page: 1)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(addTapped))
        navigationController?.navigationBar.tintColor = .black
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.isNavigationBarHidden = false
        
    }
    
    func fetchMovies(page : Int){
        
        Alamofire.request("https://api.themoviedb.org/3/discover/movie?api_key=d2cf994786e92920bf7a4fbe77d2c9e7&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=\(page)").responseJSON { response in
            
            if let json = response.result.value {
              
                if let receivedJson = json as? NSDictionary {
                    
                    print(receivedJson)
                    
                    if let resultsArray = receivedJson.value(forKey: "results") as? [[String : AnyObject]] {
  
                        for movie in resultsArray {
                           
                            let movieName = movie["original_title"] as! String
                            
                            if let moviePosterPath = movie["poster_path"] as? String {
                                
                               self.moviePosterPaths.append(moviePosterPath)
                                self.movieNames.append(movieName)
                            }
                            
                            
                           
                        }
                    }
                }
                DispatchQueue.main.async {
                    
                    print(self.moviePosterPaths)
                    self.movieCollectionView.reloadData()
                }
            }

        }
    }
    
    
    
    @objc func addTapped(){
        
        let searchController = SearchViewController(nibName: "SearchViewController", bundle: nil)
        self.navigationController?.pushViewController(searchController, animated: true)
        
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
                
                self.fetchMovies(page: self.pageCount + 1)
   
            }
 
        }
        self.pageCount = self.pageCount + 1
      
        
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

