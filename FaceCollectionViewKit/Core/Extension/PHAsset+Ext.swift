//
//  PHAsset+Ext.swift
//  FaceCollectionView
//
//  Created by serhat akalin on 30.08.2022.
//

import Foundation
import UIKit
import Photos

public extension PHAsset {
    func image(isLimited: Bool = false,
               maxSize: CGSize,
               isSyncron: Bool = false,
               resizeMode: PHImageRequestOptionsResizeMode = .fast,
               deliveryMode: PHImageRequestOptionsDeliveryMode = .fastFormat,
               contentMode: PHImageContentMode = .default,
               retry: Bool = false,
               networkAccess: Bool = false,
               completionHandler: @escaping (UIImage?) -> ()) -> PHImageRequestID {
        let requestImageOption = PHImageRequestOptions()
        requestImageOption.resizeMode = resizeMode
        requestImageOption.deliveryMode = deliveryMode
        requestImageOption.isSynchronous = isSyncron
        requestImageOption.isNetworkAccessAllowed = networkAccess
        var targetSize = PHImageManagerMaximumSize

        if CGFloat(pixelWidth) > maxSize.width || CGFloat(pixelHeight) > maxSize.height {
            let scaleX = maxSize.width / CGFloat(pixelWidth)

            let scaleY = maxSize.height / CGFloat(pixelHeight)
            let scale = min(scaleX, scaleY)
            targetSize = CGSize(width: CGFloat(pixelWidth) * scale, height: CGFloat(pixelHeight) * scale)
        }
        
        let imageManager = PHCachingImageManager.default()
        
        
        if isLimited {
            return imageManager.requestImageData(for: self, options: requestImageOption) { (imgData, dataUTI, orientation, info) in
                if let data = imgData,
                   let img = UIImage(data: data) {
                    completionHandler(img)
                }
            }
        } else {
            return imageManager.requestImage(for: self,
                                             targetSize: targetSize,
                                             contentMode: contentMode,
                                             options: requestImageOption,
                                             resultHandler: { img, dict in
                                                if img != nil {
                                                    completionHandler(img)
                                                } else {
                                                    
                                                }
            })
        }
    }
    
    private func getImage(targetSize: CGSize, options: PHImageRequestOptions, retry: Bool = false, completionHandler: @escaping (UIImage?) -> ()) {
        let imageManager = PHCachingImageManager()
        imageManager.requestImage(for: self, targetSize: targetSize, contentMode: .default, options: options, resultHandler: { img, _ in
            if img == nil && retry {
                self.getImage(targetSize: targetSize, options: options, completionHandler: completionHandler)
            } else {
                completionHandler(img)
            }
        })
    }
}
