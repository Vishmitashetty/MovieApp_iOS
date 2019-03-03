//
//  MovieListScreenCollectionViewController.swift
//  MovieApp
//
//  Created by Vishmita Shetty on 01/03/19.
//  Copyright © 2019 Vishmita Shetty. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
class MovieListCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UITextFieldDelegate,UIPopoverPresentationControllerDelegate,FilterTableDelegate {
    
    @IBOutlet weak var FilterBtn: UIButton!
    @IBOutlet weak var MovieListCollectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    var filterList = [["Title": "Popularity (By Asc)", "Value": "popularity.asc"],
                      ["Title": "Popularity (By Desc)", "Value": "popularity.desc"],
                      ["Title": "Rating (By Asc)", "Value": "vote_average.asc"],
                      ["Title": "Rating (By desc)", "Value": "vote_average.desc"]]
    
    var MovieList : [[String: AnyObject]] = []
    var page = 1
    var sortoption = "popularity.desc"
    var TotalResult = 0
    var TotalPage = 0
    var activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    var popController : UIPopoverPresentationController!
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.type = .ballRotateChase
        activityIndicator.color = UIColor.init(red: 81/255, green: 45/255, blue: 168/255, alpha: 1)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        let widthConstraint = FilterBtn.widthAnchor.constraint(equalToConstant: 35)
        let heightConstraint = FilterBtn.heightAnchor.constraint(equalToConstant: 35)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        
        if let layout = MovieListCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        {
            layout.scrollDirection = .vertical
        }
        
        MovieListCollectionView.dataSource = self
        MovieListCollectionView.delegate = self
        searchTextField.delegate = self
        getMovieList()
        
    }
    //MARK: Filter data delegate function
    func passFilterData(selectedIndexPath: IndexPath) {
        self.MovieList = []
        self.TotalResult = 0
        self.TotalPage = 0
        getMovieList()
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      
        return MovieList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "moviecell", for: indexPath) as! MovieListCell
        cell.MovieTitle.text = MovieList[indexPath.row]["original_title"] as? String ?? "N/A"
        cell.MoviePoster.tag = indexPath.row
        cell.MoviePoster.image = UIImage(named: "LoadingImage")
        //Load image from url if no image then load no image
        if let posterurl = MovieList[indexPath.row]["poster_path"] as? String
        {
            let imageurl = Endpoints.GetMoviePosterBaseUrl + posterurl
            Alamofire.request(imageurl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                .response(completionHandler: {
                    response in
                    if response.response?.statusCode == 200
                    {
                        DispatchQueue.main.async{
                            cell.MoviePoster.image = UIImage(data: response.data!)
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async{
                            cell.MoviePoster.image = UIImage(named: "NoImageAvailable")
                        }
                    }
                })
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width : 111, height: 157)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let moviedetailview = storyboard.instantiateViewController(withIdentifier: "moviedetailview") as! MovieDetailViewController
        moviedetailview.MovieDetails = self.MovieList[indexPath.row] 
        self.navigationController?.pushViewController(moviedetailview, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let row = indexPath.row + 1
        if row == self.MovieList.count - 10 && row < TotalResult
        {
            DispatchQueue.main.async {
                self.loadMoreMovies()
            }
            
        }
    }
    //MARK: Textfield function
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("TextField should return method called")
        textField.resignFirstResponder();
        if let searchText = textField.text
        {
            searchMovies(query: searchText)
        }
        return true;
    }
    //MARK: Get Movie List
    func getMovieList()
    {
        
        self.activityIndicator.startAnimating()
        Alamofire.request(Endpoints.GetAllMovies + "&sort_by=\(sortoption)&page=\(page)", method: .get, encoding: JSONEncoding.default, headers: nil)
            .responseJSON (completionHandler :
                {
                    response in
                    
                    if(response.response?.statusCode == 200)
                    {
                        var responseData = response.result.value as? [String: AnyObject]
                        let tempList = responseData?["results"] as? [[String: AnyObject]] ?? []
                        self.MovieList = self.MovieList + tempList
                        self.TotalPage = responseData?["total_pages"] as? Int ?? 0
                        self.TotalResult = responseData?["total_results"] as? Int ?? 0
                        self.activityIndicator.stopAnimating()
                        DispatchQueue.main.async {
                             self.MovieListCollectionView.reloadData()
                        }
                       
                        
                    }
            })
    }
    //MARK: Load more movies
    func loadMoreMovies()
    {
        if(self.page < TotalPage)
        {
            self.page = self.page + 1
            getMovieList()
            
        }
    }
    //MARK: Search Movies
    func searchMovies(query: String)
    {
        self.activityIndicator.startAnimating()
        Alamofire.request(Endpoints.SearchMovies + "&query=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, method: .get, encoding: JSONEncoding.default, headers: nil)
            .responseJSON (completionHandler :
                {
                    response in
                    
                    if(response.response?.statusCode == 200)
                    {
                        self.MovieList = []
                        self.TotalPage = 0
                        self.TotalResult = 0
                        
                        var responseData = response.result.value as? [String: AnyObject]
                        let tempList = responseData?["results"] as? [[String: AnyObject]] ?? []
                        self.MovieList = self.MovieList + tempList
                        self.TotalPage = responseData?["total_pages"] as? Int ?? 0
                        self.TotalResult = responseData?["total_results"] as? Int ?? 0
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            self.MovieListCollectionView.reloadData()
                        }
                        
                    }
                })
        
    }
    //MARK: Launch Filter View
    func adaptivePresentationStyle(for controller: UIPresentationController,traitCollection: UITraitCollection) -> UIModalPresentationStyle {
            return .none
    }
    
    @IBAction func LaunchFilter(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let popoverContent = storyboard.instantiateViewController(withIdentifier: "filterview") as! FilterTableViewController
        popoverContent.preferredContentSize = CGSize(width: 180, height: 75)
        popoverContent.modalPresentationStyle = UIModalPresentationStyle.popover
        popoverContent.filterTableData = filterList as [[String : AnyObject]]
        let popover = popoverContent.popoverPresentationController
        popoverContent.preferredContentSize = CGSize(width: 200,height: 300)
        popoverContent.delegate = self
        popover?.delegate = self
        popover?.permittedArrowDirections = .up
        popover?.sourceView = self.view
        popover?.sourceRect = CGRect(x:UIScreen.main.bounds.width - 50,y:70,width:0,height:0)
        self.present(popoverContent, animated: true, completion: nil)
    }
}

