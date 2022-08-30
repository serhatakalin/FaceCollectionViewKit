//
//  ShowVC.swift
//  FaceCollectionView
//
//  Created by serhat akalin on 30.08.2022.
//

import UIKit

class ShowVC: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let image = image {
            imageView.image = image
        }
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
