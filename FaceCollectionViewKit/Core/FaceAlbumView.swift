//
//  FaceAlbumView.swift
//  FaceCollectionView
//
//  Created by serhat akalin on 30.08.2022.
//

import UIKit
import Photos

class FaceAlbumView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver {
    @IBOutlet weak var faceCollectionView: UICollectionView!

    lazy var detectionManager: DetectionManager = {
        DetectionManager()
    }()
    private var isViewSet = false
    private let nibName: String = "FaceAlbumCell"
    private let reuseIdentifier: String = "FaceAlbumCell"
    public var numberPhotoPerRow: CGFloat = 2

    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        return loadFromNibIfEmbeddedInDifferentNib()
    }

    override func draw(_ rect: CGRect) {
        superview?.draw(rect)
    }

    override func didMoveToSuperview() {
        if let _ = self.superview {
            if !isViewSet {
                didLoad()
                isViewSet = true
            }
        }
    }

    private func didLoad() {
        faceCollectionView.register(UINib(nibName: nibName, bundle: Bundle(for: FaceAlbumView.self)), forCellWithReuseIdentifier: reuseIdentifier)
        faceCollectionView.decelerationRate = .fast
        if let flowLayout = faceCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = FaceCollectionViewKit.shared.scrollDirection
        }
        authorizeAndShow()
        handleViewStates()
    }

    private func handleViewStates() {
        detectionManager.stateHandler = { [weak self] states in
            guard let self = self else { return }
            switch states {
            case .imageSelected(let image):
                FaceCollectionViewKit.shared.imageSelected?(image)
            case .faceDetectionCompleted(let start, let end):
                if start == end {
                    self.detectionManager.checkAssetsAreReady()
                    return
                }
                var indexPaths: [IndexPath] = []
                for index in start..<end {
                    let path = IndexPath(item: index, section: 0)
                    indexPaths.append(path)
                }
                DispatchQueue.main.async {
                    if self.detectionManager.resultAssets.count >= end {
                        self.detectionManager.resultAssetsToDraw.append(contentsOf: self.detectionManager.resultAssets[start..<end])
                        self.faceCollectionView.performBatchUpdates {
                            self.faceCollectionView.insertItems(at: indexPaths)
                        }
                    }
                }
            case .faceDetectionFinished:
                print("detection finished..")
            }
        }
    }

    private func authorizeAndShow() {
        var status = PHPhotoLibrary.authorizationStatus()
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        }

        handle(photoLibraryPermission: status) { permission in
            if permission {
                PHPhotoLibrary.shared().register(self)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.getImageAssets()
                }
            }
        }

        handle(photoLibraryPermission: status, askForPermission: true) { statusOk in
            if statusOk {
                self.getImageAssets()
            }
        }
    }

    private func handle(photoLibraryPermission status: PHAuthorizationStatus,
        askForPermission: Bool = false,
        completion: ((Bool) -> Void)? = nil) {
        if #available(iOS 14, *) {
            self.detectionManager.isLimitedPermission = status == PHAuthorizationStatus.limited
        }

        switch status {
        case .notDetermined:
            detectionManager.openSettingsForAllowAccess = false
            if askForPermission {
                if #available(iOS 14, *) {
                    PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                        DispatchQueue.main.async {
                            self.handle(photoLibraryPermission: status, completion: completion)
                        }
                    }
                } else {
                    PHPhotoLibrary.requestAuthorization { status in
                        DispatchQueue.main.async {
                            self.handle(photoLibraryPermission: status, completion: completion)
                        }
                    }
                }
            }
        case .denied, .restricted:
            detectionManager.openSettingsForAllowAccess = true
            completion?(false)
        case .authorized, .limited:
            PHPhotoLibrary.shared().register(self)
            detectionManager.openSettingsForAllowAccess = true
            completion?(true)
        @unknown default: break
        }
    }

    private func getImageAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        detectionManager.fetchResults = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    }

    private func centeredItems(collectionView: UICollectionView) -> CGSize {
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(numberPhotoPerRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(numberPhotoPerRow))
        return CGSize(width: size, height: size)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return detectionManager.resultAssetsToDraw.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return centeredItems(collectionView: faceCollectionView)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? FaceAlbumCell else {
            return UICollectionViewCell()
        }

        let asset = detectionManager.resultAssetsToDraw[indexPath.row]
        cell.configure(with: asset)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == detectionManager.resultAssetsToDraw.count - 1 {
            DispatchQueue.global().async {
                self.detectionManager.checkAssetsAreReady()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        let asset = self.detectionManager.resultAssetsToDraw[indexPath.row]
        _ = asset.image(maxSize: CGSize(width: 2000, height: 2000),
            resizeMode: .exact,
            deliveryMode: .highQualityFormat,
            contentMode: PHImageContentMode.aspectFit,
            retry: true,
            networkAccess: true) { [weak self] photo in
            if let photo = photo {
                self?.detectionManager.stateHandler?(.imageSelected(photo))
            }
        }
    }

    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let results = detectionManager.fetchResults else { return }
        if let change = changeInstance.changeDetails(for: results) {
            if change.fetchResultAfterChanges.count != results.count {
                DispatchQueue.main.async {
                    self.detectionManager.resultAssetsToDraw = []
                    self.faceCollectionView.reloadData()
                    self.faceCollectionView.performBatchUpdates(nil, completion: {
                        (result) in
                        self.detectionManager.fetchResults = change.fetchResultAfterChanges
                    })
                }
            }
        }
    }

    func sync() {
        detectionManager.queue.sync {
            FaceCollectionViewKit.shared.faceAlbumAssets = detectionManager.assetDictTemp
        }
        NotificationCenter.default.removeObserver(self)
    }
}
