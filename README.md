# FaceCollectionViewKit
A framework that lists all images in the album that contain faces.

## Features
- [x] It uses the detection features of CIDetectorTypeFace.
- [x] Scans all albums, presents you photos with face detected.
- [x] The quality of the photos does not deteriorate.
- [x] Detection settings can be changed.
- [x] Caching photo asset workaround.
- [x] Simple and fast.

## Usage

### Initialize
Firstly, use this wherever you want to show the album.
```ruby
FaceCollectionViewKit.shared.initialize(for: YOUR_CUSTOM_VIEW)
```
### Select Photo
This is triggered when you select a photo from the album, just call it once in *viewDidLoad()*.
```ruby
FaceCollectionViewKit.shared.imageSelected = { [weak self] image in
            //whatever you would like to do.
}
```
### Cache Sync
Use this when exiting the screen with the album. Saves cached images.
```ruby
override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FaceCollectionViewKit.shared.sync()
}
```

## Installation
### CocoaPods
To integrate FaceCollectionViewKit into your Xcode project using  [CocoaPods](https://cocoapods.org/), specify it in your Podfile:

```ruby
pod 'FaceCollectionViewKit', :git => 'https://github.com/serhatakalin/FaceCollectionViewKit.git'
```

### Carthage
To integrate FaceCollectionViewKit into your Xcode project using [Carthage](https://github.com/Carthage/Carthage), specify it in your Cartfile:

```ruby
pod 'serhatakalin/FaceCollectionViewKit'
```

### Manually
Add the [Core](https://github.com/serhatakalin/FaceCollectionViewKit/tree/master/FaceCollectionViewKit/Core) folder to your Xcode project.

### License
FaceCollectionViewKit is released under the MIT license. See [LICENSE](https://github.com/serhatakalin/FaceCollectionViewKit/blob/master/LICENSE) for more information.
