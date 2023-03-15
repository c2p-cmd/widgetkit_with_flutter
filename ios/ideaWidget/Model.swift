//
//  Model.swift
//  Runner
//
//  Created by Sharan Thakur on 15/03/23.
//

import Foundation
import SwiftUI
import WidgetKit

let image_getter = "https://dummyjson.com/products/\(Int.random(in: 0...100))"

enum ApiResponse {
    case Success(image: UIImage)
    case Failure
}

struct MyEntry : TimelineEntry {
    var date: Date
    var image: UIImage
    var title: String = "Sample Idea"
}

struct Model : Decodable {
    var title: String
    var thumbnail: String
}

class IdeaProvider {
    static func getIdeaOfTheDayImage(completion: ((ApiResponse, String) -> Void)?) {
        let urlString = image_getter
        let url = URL(string: urlString)!
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            parseResponseAndGetImage(data: data, urlResponse: urlResponse, error: error, completion: completion)
        }
        task.resume()
    }

    static func parseResponseAndGetImage(data: Data?, urlResponse: URLResponse?, error: Error?, completion: ((ApiResponse, String) -> Void)?) {
        guard error == nil, let content = data else {
            print("Error getting data from api")
            completion?(ApiResponse.Failure, "")
            return
        }

        var apiData: Model
        do {
            apiData = try JSONDecoder().decode(Model.self, from: content)
        } catch {
            completion?(ApiResponse.Failure, "")
            return
        }
        
        let url = URL(string: apiData.thumbnail)!
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            imageFromResponse(title: apiData.title, data: data, urlResponse: urlResponse, error: error, completion: completion)
        }
        task.resume()
    }
    
    static func imageFromResponse(title: String, data: Data?, urlResponse: URLResponse?, error: Error?, completion: ((ApiResponse, String) -> Void)?) {
        guard error == nil, let content = data else {
            print("Error fetching image")
            completion?(ApiResponse.Failure, "-")
            return
        }
        
        completion?(ApiResponse.Success(image: UIImage(data: content)!), title)
    }
}
