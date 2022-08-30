Pod::Spec.new do |spec|
  spec.name         = "FaceCollectionViewKit"
  spec.version      = "1.0.0"
  spec.summary      = "A framework that lists all images in the album that contain faces."
  spec.description  = "Quickly sorts photos with faces in all albums by detecting them. Sorting style or detection sizes can be changed."
  spec.homepage     = "https://github.com/serhatakalin/FaceCollectionViewKit.git"
  spec.license      = "MIT"
  spec.author             = { "Serhat A." => "akalinst@gmail.com" }
  spec.social_media_url   = "https://twitter.com/serhatakalin_"
  spec.platform     = :ios, "12.0"
  spec.source       = { :git => "https://github.com/serhatakalin/FaceCollectionViewKit.git", :tag => "1.0.0" }
  spec.source_files  = "FaceCollectionViewKit/**/*"
  spec.resource_bundles = {
    "FaceCollectionViewKit" => ["FaceCollectionViewKit/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"]
  }
  spec.swift_version = '5.0'
end