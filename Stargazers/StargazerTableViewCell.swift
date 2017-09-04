//
//  StargazerTableViewCell.swift
//  Stargazers
//
//  Created by Pietro Santececca on 02/09/17.
//  Copyright © 2017 Tecnojam. All rights reserved.
//

import UIKit

class StargazerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    func configure(viewModel: StargazerViewModel) {
        name.text = viewModel.name
        avatar.imageFromServerURL(urlString: viewModel.imageUrl)
    }
}

extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error ?? "Generic error")
                return
            }
            
            if let response = response, let url = response.url, url.absoluteString == urlString {
                DispatchQueue.main.async(execute: { () -> Void in
                    let image = UIImage(data: data!)
                    self.image = image
                })
            }
        }).resume()
    }
}
