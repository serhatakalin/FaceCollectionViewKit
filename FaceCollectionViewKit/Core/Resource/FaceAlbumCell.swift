//
//  FaceAlbumCell.swift
//  FaceCollectionView
//
//  Created by serhat akalin on 30.08.2022.
//

import UIKit
import Photos

class FaceAlbumCell: UICollectionViewCell {
    @IBOutlet weak var assetImageView: UIImageView!
    
    var imageRequestID: PHImageRequestID?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageRequestID.map(PHCachingImageManager.default().cancelImageRequest)
        imageRequestID = nil
        assetImageView.image = nil
    }

    internal func configure(with asset: PHAsset) {
        let size = CGSize(
            width: frame.width * UIScreen.main.scale,
            height: frame.height * UIScreen.main.scale
        )

        let options = PHImageRequestOptions()
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = true

        imageRequestID = asset.image(maxSize: size,
            resizeMode: .exact,
            deliveryMode: .highQualityFormat,
            retry: true,
            networkAccess: true) { [weak self] photo in
            if photo != nil {
                self?.assetImageView.image = photo
            }
        }
    }

}
