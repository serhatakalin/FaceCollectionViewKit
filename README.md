# FaceCollectionViewKit
A framework that lists all images in the album that contain faces.

## Features
- It uses the detection features of CIDetectorTypeFace.
- Scans all albums, presents you photos with face detected.
- The quality of the photos does not deteriorate.
- Detection settings can be changed.
- Simple and fast.

## Usage

### Initialize
```ruby
FaceCollectionViewKit.shared.initialize(for: YOUR_CUSTOM_VIEW)
```
### Select Photo
```ruby
FaceCollectionViewKit.shared.imageSelected = { [weak self] image in
            //whatever you would like to do.
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
