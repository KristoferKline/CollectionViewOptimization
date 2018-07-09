//
//  LoadImageOperation.swift
//  CardCollectionView
//
//  Created by Kristofer Kline on 7/3/18.
//  Copyright © 2018 Kristofer Kline. All rights reserved.
//

import UIKit

typealias LoadImageCompletion = ((Data) -> Void)

final class LoadImageOperation: Operation {
    private let imageURL: URL
    var completion: LoadImageCompletion
    weak var session: URLSession?
    
    init(url: URL, session: URLSession, completion: @escaping LoadImageCompletion) {
        imageURL = url
        self.session = session
        self.completion = completion
    }
    
    override func main() {
        print("Executing")
        loadImage(from: imageURL) { (error) in
            guard let error = error else { return }
            print("Ran into an error: \(error.localizedDescription)")
        }
    }
    
    private func loadImage(from imageURL: URL, completion: @escaping (Error?) -> Void) {
        session?.dataTask(with: imageURL) { [weak self] (data, response, error) in
            guard let data = data, error == nil else { return completion(error) }
            print("Did retrieve data")
            self?.completion(data)
        }.resume()
    }
}

