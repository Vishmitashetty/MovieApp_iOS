//
//  Endpoints.swift
//  MovieApp
//
//  Created by Vishmita Shetty on 01/03/19.
//  Copyright © 2019 Vishmita Shetty. All rights reserved.
//

import UIKit

class Endpoints {
    
    //MARK: Get All Movies list
    private static let GETALLMOVIES:String = "https://api.themoviedb.org/3/discover/movie?api_key=fc02d275df59dbf73d1cde2629ccfdb1&language=en-US&include_adult=false&include_video=false"
    
     public static var GetAllMovies:String { get { return GETALLMOVIES} }
    
    //MARK: Get Movie Poster base url
    private static let GETMOVIEPOSTERBASEURL = "https://image.tmdb.org/t/p/w500"
    public static var GetMoviePosterBaseUrl: String {get {return GETMOVIEPOSTERBASEURL}}
    
    //MARK: Search movie
    private static let SEARCHMOVIES = "https://api.themoviedb.org/3/search/movie?api_key=fc02d275df59dbf73d1cde2629ccfdb1&language=en-US&page=1&include_adult=false"
    public static var SearchMovies : String {get { return SEARCHMOVIES}}

}
