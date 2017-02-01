//
//  PokemonViewController.swift
//  PokemonGO
//
//  Created by Mohammad Azam on 1/23/17.
//  Copyright © 2017 Mohammad Azam. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import HDAugmentedReality

class PokemonViewController : UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate, ARDataSource, PokemonAnnotationViewDelegate {
   
    /// Asks the data source to provide annotation view for annotation. Annotation view must be subclass of ARAnnotationView.
    public func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        
        let pokemonAnnotationView = PokemonAnnotationView()
        pokemonAnnotationView.annotation = viewForAnnotation
        pokemonAnnotationView.delegate = self
        pokemonAnnotationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        return pokemonAnnotationView
    }

    
    @IBOutlet weak var collectionView :UICollectionView!
    fileprivate var locationManager = CLLocationManager()
    var capturedPokemons = [Pokemon]()
    
    var arViewController :ARViewController!
    var pokemons = [Pokemon]()
    var pokemonAnnotations = [PokemonAnnotation]()
   
    func pokemonAnnotationViewDidSelect(pokemon: Pokemon) {
        
        self.capturedPokemons.append(pokemon)
        self.collectionView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.capturedPokemons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokemonCollectionViewCell", for: indexPath) as! PokemonCollectionViewCell
        
        let pokemon = self.capturedPokemons[indexPath.row]
        
        DispatchQueue.global().async {
            let imageData = NSData(contentsOf: URL(string: pokemon.imageURL)!)
            let img = UIImage(data: imageData as! Data)
            DispatchQueue.main.async {
                cell.pokemonImageView.image = img
            }
        }
        
        return cell
    }
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.capturedPokemons = appDelegate.capturedPokemons
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.requestAlwaysAuthorization()
        
        
        populatePokemonsUsingFile()
       // populatePokemons()
        
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    @IBAction func showAR(sender :Any) {
        
        arViewController = ARViewController()
        arViewController.dataSource = self
        arViewController.maxDistance = 0
        arViewController.maxVisibleAnnotations = 30
        arViewController.maxVerticalLevel = 5
        arViewController.headingSmoothingFactor = 0.05
        
        arViewController.trackingManager.userDistanceFilter = 25
        arViewController.trackingManager.reloadDistanceFilter = 75
        arViewController.setAnnotations(self.pokemonAnnotations)
        arViewController.uiOptions.debugEnabled = false
        arViewController.uiOptions.closeButtonEnabled = true
        
        self.present(arViewController, animated: true, completion: nil)
    
    }
    
    
    private func populatePokemonsUsingFile() {
        
        guard let path = Bundle.main.path(forResource: "pokemons", ofType: "json") else {
            fatalError("Requested path does not exist")
        }
        
        let data = NSData(contentsOfFile: path)
        
        let dictionaries = try! JSONSerialization.jsonObject(with: (data! as? Data)!, options: []) as! [[String:Any]]
        
        self.pokemons = dictionaries.flatMap(Pokemon.init)
        
        for pokemon in self.pokemons {
            
            // create pokemon annotation
            let pokemonAnnotation = PokemonAnnotation()
            pokemonAnnotation.title = pokemon.name
            pokemonAnnotation.location = CLLocation(latitude: pokemon.latitude, longitude: pokemon.longitude)
            pokemonAnnotation.imageURL = pokemon.imageURL
            pokemonAnnotation.pokemon = pokemon
            
            
            self.pokemonAnnotations.append(pokemonAnnotation)
        }
        
    }
    
    
    private func populatePokemons() {
        
        let url = "http://highoncoding.com/publicfolder/pokemons.json"
        let pokemonURL = URL(string: url)
        
        URLSession.shared.dataTask(with: pokemonURL!) { (data, _, _) in
            
            let dictionaries = try! JSONSerialization.jsonObject(with: data!, options: []) as! [[String:Any]]
            
            self.pokemons = dictionaries.flatMap(Pokemon.init)
            
            for pokemon in self.pokemons {
                
                // create pokemon annotation
                let pokemonAnnotation = PokemonAnnotation()
                pokemonAnnotation.title = pokemon.name
                pokemonAnnotation.location = CLLocation(latitude: pokemon.latitude, longitude: pokemon.longitude)
                pokemonAnnotation.imageURL = pokemon.imageURL
                pokemonAnnotation.pokemon = pokemon
                

                self.pokemonAnnotations.append(pokemonAnnotation)
            }
            
            
        }.resume()
        
    }
   
}

