//
//  DetectionQueue.swift
//  FaceCollectionView
//
//  Created by serhat akalin on 30.08.2022.
//

import Foundation
import UIKit
import Photos

public class DetectionManager {
    enum ViewState {
        case imageSelected(UIImage)
        case faceDetectionCompleted(Int, Int)
        case faceDetectionFinished
    }
    lazy var queue = DispatchQueue(label: FaceCollectionViewKit.Constant.queLabel)
    private var isWaitingForAssets = false
    private var detectingFetchIndex = 0
    private var drawnFetchIndex = 0
    var stateHandler: ((ViewState) -> Void)?
    var detectMinSize = FaceCollectionViewKit.shared.detectMinSize
    var detectMaxSize = FaceCollectionViewKit.shared.detectMaxSize
    var numberOfDetection = FaceCollectionViewKit.shared.numberOfDetection
    var isLimitedPermission: Bool = false {
        didSet {
            FaceCollectionViewKit.shared.limitedStatus = isLimitedPermission
        }
    }
    var openSettingsForAllowAccess = false {
        didSet {
            FaceCollectionViewKit.shared.settingsStatus = openSettingsForAllowAccess
        }
    }
    var assetDictTemp: [String: Bool] =  FaceCollectionViewKit.shared.faceAlbumAssets ?? [:]
    var resultAssetsToDraw: [PHAsset] = []
    var resultAssets: [PHAsset] = []
    var fetchResults: PHFetchResult<PHAsset>? {
        didSet {
            self.detectAgain()
        }
    }
 
    private let detector = CIDetector(ofType: CIDetectorTypeFace,
                              context: nil,
                              options: [CIDetectorAccuracy: UIDevice.current.isBeforeIphoneX ? CIDetectorAccuracyLow : CIDetectorAccuracyHigh])
    required init() {}

    private func detectFace(counter: Int) {
        guard let results = fetchResults else { return }
        let startIndex = detectingFetchIndex
        var endIndex = detectingFetchIndex + counter
        detectingFetchIndex += counter
        if (detectingFetchIndex + counter) > results.count {
            endIndex = results.count
            detectingFetchIndex = results.count
        }

        if startIndex == endIndex {
            isWaitingForAssets = false
            stateHandler?(.faceDetectionFinished)
            return
        }

        let width = (UIScreen.main.bounds.width - 15) / 4.0
        let size = CGSize(
            width: width * UIScreen.main.scale,
            height: width * UIScreen.main.scale
        )
        autoreleasepool {
            for index in startIndex..<endIndex {
                let asset = results.object(at: index) as PHAsset
                let assetId = asset.localIdentifier
                if let value = assetDictTemp[assetId],
                   value == true {
                    resultAssets.append(asset)
                    continue
                } else if let value = assetDictTemp[assetId],
                          value == false {
                    continue
                } else {
                    _ = asset.image(isLimited: isLimitedPermission, maxSize: size, isSyncron: true) { image in
                        guard let img = image else { return }
                        guard let ciImage = CIImage(image: img) else { return }
                        let orientation = img.imageOrientation
                        var options: [String: Any]? = [:]
                        options?[CIDetectorImageOrientation] = orientation.rawValue
                        options?[CIDetectorMinFeatureSize] = 0.15

                        if let features = self.detector?.features(in: ciImage, options: options) {
                            if features.count > 0 {
                                var maxFaceheight = CGFloat(0)
                                var maxFaceWidth = CGFloat(0)
                                for feature in features {
                                    let rect = feature.bounds
                                    if rect.size.height > maxFaceheight {
                                        maxFaceheight = rect.size.height
                                    }
                                    if rect.size.width > maxFaceWidth {
                                        maxFaceWidth = rect.size.width
                                    }
                                }
                                
                                var ratio = CGFloat(1)
                                var assetWidth = CGFloat(asset.pixelWidth)
                                var assetHeight = CGFloat(asset.pixelHeight)
                                if asset.pixelWidth > self.detectMaxSize, asset.pixelWidth > asset.pixelHeight {
                                    let currRatio = CGFloat(self.detectMaxSize) / assetWidth
                                    assetWidth *=  currRatio
                                    assetHeight *= currRatio
                                } else if asset.pixelHeight > self.detectMaxSize {
                                    let currRatio =  CGFloat(self.detectMaxSize) / assetHeight
                                    assetWidth *=  currRatio
                                    assetHeight *= currRatio
                                }

                                ratio = assetWidth / img.size.width
                                if (maxFaceheight * ratio) > CGFloat(self.detectMinSize) + (UIDevice.current.isBeforeIphoneX ? 40.0 : 0)
                                    || (maxFaceWidth  * ratio) > CGFloat(self.detectMinSize) + (UIDevice.current.isBeforeIphoneX ? 40.0 : 0) {
                                    self.assetDictTemp[assetId] = true
                                    self.resultAssets.append(asset)
                                } else {
                                    self.assetDictTemp[assetId] = false
                                }
                            } else {
                                self.assetDictTemp[assetId] = false
                            }
                        } else {
                            self.assetDictTemp[assetId] = false
                        }
                    }
                }
            }
            assetsAreReady()
        }
    }
    
    private func detectAgain() {
        detectingFetchIndex = 0
        drawnFetchIndex = 0
        resultAssetsToDraw = []
        resultAssets = []
        DispatchQueue.global().async {
            var numberOfDetection = self.numberOfDetection
            numberOfDetection = UIDevice.current.isSmall ? 5 : numberOfDetection
            self.detectFace(counter: numberOfDetection)
        }
    }
    
    func checkAssetsAreReady() {
        if isWaitingForAssets {
            return
        }
        isWaitingForAssets = true
        var numberOfDetection =  self.numberOfDetection
        numberOfDetection = UIDevice.current.isSmall ? 5 : numberOfDetection
        self.detectFace(counter: numberOfDetection)
    }
    
    private func assetsAreReady() {
        isWaitingForAssets = false
        stateHandler?(.faceDetectionCompleted(resultAssetsToDraw.count, resultAssets.count))
    }
}
