//
//  Meme.swift
//  MemeMe
//
//  Created by Keng Siang Lee on 21/5/15.
//  Copyright (c) 2015 KSL. All rights reserved.
//

import UIKit

struct Meme {
    var top: String = ""
    var bottom: String = ""
    var image: UIImage?
    var memedImage: UIImage?
    
    init(top: String, bottom: String, image: UIImage?, memedImage: UIImage?) {
        self.top = top
        self.bottom = bottom
        self.image = image
        self.memedImage = memedImage
    }
}