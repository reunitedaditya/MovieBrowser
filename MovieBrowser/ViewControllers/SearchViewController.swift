//
//  SearchViewController.swift
//  MovieBrowser
//
//  Created by Aditya on 10/12/17.
//  Copyright © 2017 Aditya. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    

    override func viewDidLoad() {
        super.viewDidLoad()
      
        navigationController?.isNavigationBarHidden = true
         searchBar.becomeFirstResponder()
    }
    
    
    
    @IBAction func PopToDiscover(_ sender: Any) {
        
       
        navigationController?.popViewController(animated: true)
    }
    

}
