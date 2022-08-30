//
//  ViewController.swift
//  FaceCollectionView
//
//  Created by serhat akalin on 30.08.2022.
//

import UIKit

class MainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeCollectionView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FaceCollectionViewKit.shared.sync()
    }
    
    private func initializeCollectionView() {
        FaceCollectionViewKit.shared.initialize(for: self.view)
        FaceCollectionViewKit.shared.imageSelected = { [weak self] image in
            self?.openShowVC(image: image)
        }
    }
    
    private func openShowVC(image: UIImage?) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "ShowVC") as? ShowVC else { return }
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        if let image = image {
            vc.image = image
        }
        self.present(vc, animated: true)
    }
}

