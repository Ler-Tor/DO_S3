//
//  ViewController.swift
//  DO_S3
//
//  Created by Andrey on 14.10.2021.
//

import UIKit
import AWSS3

class ViewController: UIViewController {
    private let spacesRepository = SpacesRepository()
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func uploadExampleFile(){
        spacesRepository.uploadExampleFile()
    }
    
    @IBAction func downloadExampleFile(){
        spacesRepository.downloadExampleFile { (data, error) in
            guard let data = data else {
                print("Image failed to download")
                return
            }
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
                
            }
        }
    }
    
    
    // Для спиннера 
    private func showSpinner() {
        activityIndicator.startAnimating()
        
    }
    
    private func hideSpinner(){
        
    }

}

