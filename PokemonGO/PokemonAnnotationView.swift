//
//  PokemonAnnotationView.swift
//  PokemonGO
//
//  Created by Mohammad Azam on 1/23/17.
//  Copyright © 2017 Mohammad Azam. All rights reserved.
//

import Foundation
import HDAugmentedReality
import UIKit
import SpriteKit

protocol PokemonAnnotationViewDelegate : class {
    
    func pokemonAnnotationViewDidSelect(pokemon :Pokemon)
    
}

class PokemonAnnotationView : ARAnnotationView {
    
    var label :UILabel!
    var imageView :UIImageView!
    weak var delegate :PokemonAnnotationViewDelegate!
    var pokemonAnnotation :PokemonAnnotation!
    
    override func didMoveToSuperview() {
        
        super.didMoveToSuperview()
        loadUI()
    }
    
    private func loadUI() {
        
        self.pokemonAnnotation = self.annotation as! PokemonAnnotation
        
        self.label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        self.label.text = self.annotation?.title
        
        self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.addSubview(imageView)
        
        // register gesture recognizers 
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pokemonTapped))
        
        self.addGestureRecognizer(tapGestureRecognizer)
        
        DispatchQueue.global().async {
            
            let imageData = try! Data(contentsOf: URL(string: self.pokemonAnnotation.imageURL)!)
            let img = UIImage(data: imageData)
            
            DispatchQueue.main.async {
                self.imageView.image = img
            }
        }
    }
    
    func pokemonTapped(recognizer :UIGestureRecognizer) {
        
        DispatchQueue.main.async {
              self.delegate.pokemonAnnotationViewDidSelect(pokemon: self.pokemonAnnotation.pokemon)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        UIView.animate(withDuration: 2.0, animations: { 
            
            self.transform = CGAffineTransform(rotationAngle:CGFloat(M_PI * 1))
            
        }) { (true) in
            
            UIView.animate(withDuration: 1.0, animations: { 
                
                    self.alpha = 0.0
            })
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        self.imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    }
    
}
