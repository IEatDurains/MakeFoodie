//
//  Post.swift
//  MakeFoodie
//
//  Created by Chen Kang Ning on 7/7/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit

class Post: Codable {
    var id: Int
    var title: String
    var price: Double
    var desc: String
    var thumbnail: Image
    var category: String
    var uid: String
        
    init(id: Int, title: String, price: Double, desc: String, thumbnail: Image, category: String, uid: String)
    {
        self.id = id
        self.title = title
        self.price = price
        self.desc = desc
        self.thumbnail = thumbnail
        self.category = category
        self.uid = uid
    }
    
    struct Image: Codable {
        let imageData: Data?
        
        init(withImage image: UIImage) {
            self.imageData = image.pngData()
        }

        func getImage() -> UIImage? {
            guard let imageData = self.imageData else {
                return nil
            }
            let image = UIImage(data: imageData)
            
            return image
        }
    }
}
