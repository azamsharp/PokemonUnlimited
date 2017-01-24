//
//  Pokemon.swift
//  PokemonGO
//
//  Created by Mohammad Azam on 1/23/17.
//  Copyright © 2017 Mohammad Azam. All rights reserved.
//

import Foundation

struct Pokemon {
    
    var name :String
    var imageURL :String
    var latitude :Double
    var longitude :Double
}

extension Pokemon {
    
    init(dictionary :[String:Any]) {
        
        self.name = dictionary["name"] as! String
        self.imageURL = dictionary["imageURL"] as! String
        self.latitude = dictionary["latitude"] as! Double
        self.longitude = dictionary["longitude"] as! Double
    }
    
}
