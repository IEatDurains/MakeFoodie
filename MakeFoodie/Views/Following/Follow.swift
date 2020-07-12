//
//  Item.swift
//  MakeFoodie
//
//  Created by NIgel Cheong on 11/7/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit

class Follow: Codable {

    var followeruid: String
    var following: Int
    
    init(followeruid: String, following: Int)
    {
        self.followeruid = followeruid
        self.following = following
        
    }
}

class followDetails: Codable {
    var id: Int
    var title: String
    var price: Decimal
    var desc: String
    var thumbnail: Image
    var category: String
    var uid: String
        
    init(id:Int, title: String, price: Decimal, desc: String, thumbnail: Image, category: String, uid: String)
    {
        self.id = id
        self.title = title
        self.price = price
        self.desc = desc
        self.thumbnail = thumbnail
        self.category = category
        self.uid = uid
    }
    
    struct Image: Codable{
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
