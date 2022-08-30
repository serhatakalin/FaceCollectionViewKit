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
    public static let shared = FaceCollectionViewKit()
    private var viewPresent: FaceAlbumView?
    private let assetsCacheKey = "assetsCacheKey"
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
            self.setObject(faceAlbumAssets, forKey: assetsCacheKey)
        }
    }

    private init() {
        faceAlbumAssets = self.getObject([String: Bool].self, forKey: assetsCacheKey)
    }

    public func setup(for superview: UIView, completion: @escaping ((UIView) -> Void)) {
        if viewPresent == nil {
            viewPresent = FaceAlbumView.loadFromNib()
        }
        viewPresent?.frame = superview.bounds
        if let view = self.viewPresent {
            completion(view)
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
