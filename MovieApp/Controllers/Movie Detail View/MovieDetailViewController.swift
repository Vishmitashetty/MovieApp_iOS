//
//  MovieDetailViewController.swift
//  MovieApp
//
//  Created by Vishmita Shetty on 02/03/19.
//  Copyright © 2019 Vishmita Shetty. All rights reserved.
//

import UIKit
import Alamofire
import SwiftRichString
class MovieDetailViewController: UIViewController {
    @IBOutlet weak var MoviePosterImage: UIImageView!
    @IBOutlet weak var MovieTitle: UILabel!
    @IBOutlet weak var UserRating: UILabel!
    @IBOutlet weak var ReleaseDate: UILabel!
    @IBOutlet weak var MovieOverview: UITextView!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    var MovieDetails : [String: AnyObject] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Detail"
        // assign movie details
        MovieTitle.text = MovieDetails["original_title"] as? String ?? "N/A"
        let votecount = String(MovieDetails["vote_average"] as? Double ?? 0.0)
        let averageVote = NSMutableAttributedString()
        let userVoteStyle = Style {
            $0.font = UIFont.init(name: "TrebuchetMS", size: 15)
            $0.color = UIColor.darkGray
        }
        
        let totalVoteStyle = Style {
            $0.font = UIFont.init(name: "TrebuchetMS", size: 12)
            $0.color = UIColor.gray
        }
        
        let attr = votecount.set(style: userVoteStyle)
        averageVote.append(attr)
        
        let attr1 = "/10".set(style: totalVoteStyle)
        averageVote.append(attr1)
        
        UserRating.attributedText = averageVote
        if let releasedate = MovieDetails["release_date"] as? String
        {
            if let formattedDate = formatDate(Date: releasedate)
            {
                let certificate = MovieDetails["adult"] as! Bool ? "Adult" : "U/A"
                ReleaseDate.text = certificate + " | " + String(formattedDate)
            }
           
        }
        MovieOverview.text = MovieDetails["overview"] as? String ?? "N/A"
        
        //Set Movie Poster
        if let posterurl = MovieDetails["poster_path"] as? String
        {
            let imageurl = Endpoints.GetMoviePosterBaseUrl + posterurl
            Alamofire.request(imageurl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                .response(completionHandler: {
                    response in
                    if response.response?.statusCode == 200
                    {
                        DispatchQueue.main.async{
                            
                            self.MoviePosterImage.image = UIImage(data: response.data!)
                            
                        }
                    }
                })
        }
        MovieOverview.frame = CGRect(x: 0, y: 388, width: UIScreen.main.bounds.width - 16, height: MovieOverview.contentSize.height + 10)
        viewHeight.constant = MovieOverview.contentSize.height
      
    }
    //MARK: Format Date
    func formatDate(Date: String) -> String?
    {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        
        if let date = dateFormatterGet.date(from: Date) {
            return dateFormatterPrint.string(from: date)
        } else {
            return nil
        }
    }

}
