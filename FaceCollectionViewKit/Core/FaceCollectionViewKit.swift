//
//  FaceCollectionView.swift
//  FaceCollectionView
//
//  Created by serhat akalin on 30.08.2022.
//

import Foundation
import Photos
import UIKit

public class FaceCollectionViewKit {
    struct Constant {
        static let frameworkBundle = "com.lyrebirdstudio.faceCollectionViewKit"
        static let queLabel = "FaceCollectionViewKit.asset.identifier"
        static let assetKey = "facesAssetKey"
    }

    public static let shared = FaceCollectionViewKit()
    private var viewPresent: FaceAlbumView?
    public var imageSelected: ((UIImage) -> Void)? = nil
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical
    public var numberPhotoPerRow: CGFloat = 2
    public var detectMinSize = 200
    public var detectMaxSize = 2000
    public var numberOfDetection = 12
    public var settingsStatus: Bool = false
    public var limitedStatus: Bool = false
    var faceAlbumAssets: [String: Bool]? {
        didSet {
            self.setObject(faceAlbumAssets, forKey: Constant.assetKey)
        }
    }

    private init() {
        faceAlbumAssets = self.getObject([String: Bool].self, forKey: Constant.assetKey)
    }

    public func setup(for superview: UIView) {
        if viewPresent == nil {
            viewPresent = FaceAlbumView.loadFromNib()
        }
        viewPresent?.frame = superview.bounds
        DispatchQueue.main.async {
            if let view = self.viewPresent {
                superview.addSubview(view)
            }
        }
    }

    public func sync() {
        viewPresent?.sync()
    }

    private func setObject<T>(_ value: T, forKey: String) where T: Codable {
        if let encoded = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(encoded, forKey: forKey)
        }
    }

    private func getObject<T>(_ type: T.Type, forKey: String) -> T? where T: Codable {
        if let jsonData = UserDefaults.standard.value(forKey: forKey) as? Data,
            let obj = try? JSONDecoder().decode(type, from: jsonData) {
            return obj
        }
        return nil
    }
}
