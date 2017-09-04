//
//  StargazerTableViewCell.swift
//  Stargazers
//
//  Created by Pietro Santececca on 02/09/17.
//  Copyright © 2017 Tecnojam. All rights reserved.
//

import UIKit

class StargazerTableViewCell: UITableViewCell, ImageLoaderProtocol  {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    var imageUrl: String? {
        didSet {
            downloadImageWithUrl { [unowned self] image in
                self.avatar.image = image
            }
        }
    }
    
    func configure(viewModel: StargazerViewModel) {
        name.text = viewModel.name
        imageUrl = viewModel.imageUrl
    }
}

protocol ImageLoaderProtocol {
    var imageUrl: String? { get set }
    func downloadImageWithUrl(completion: @escaping (UIImage) -> Void)
}

extension ImageLoaderProtocol {
    
    func downloadImageWithUrl(completion: @escaping (UIImage) -> Void) {
        
        guard let imageUrl = self.imageUrl else { return }
        
        URLSession.shared.dataTask(with: NSURL(string: imageUrl)! as URL, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error ?? "Generic error")
                return
            }
            
            if let response = response, let url = response.url, url.absoluteString == self.imageUrl {
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async(execute: { () -> Void in
                        completion(image)
                    })
                }
            }
        }).resume()
    }
}
