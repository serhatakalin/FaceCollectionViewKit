//
//  UIView+Ext.swift
//  FaceCollectionView
//
//  Created by serhat akalin on 30.08.2022.
//

import Foundation
import UIKit

public extension UIView {
   class func loadFromNib(withOwner owner: Any? = nil) -> Self? {
       let frameworkBundle = Bundle.main
        let names = String(describing: type(of: self)).components(separatedBy: ".")
        if names.indices.contains(0) {
            let name = names[0]
            let views =  UINib(nibName: name, bundle: frameworkBundle).instantiate(withOwner: owner, options: nil)
            if views.indices.contains(0) {
                let view = views[0]
                return cast(view)
            }
        }
        return nil
    }

  func loadFromNibIfEmbeddedInDifferentNib() -> Self? {
        if subviews.isEmpty {
            let view = type(of: self).loadFromNib()
            translatesAutoresizingMaskIntoConstraints = false
            view?.translatesAutoresizingMaskIntoConstraints = false
            return view
        }
        return self
    }
}

private func cast<T, U>(_ value: T) -> U? {
    return value as? U
}
