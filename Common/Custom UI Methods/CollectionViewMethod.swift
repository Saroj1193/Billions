//
//  CollectionViewMethod.swift
//  
//
//  Created by Tristate on 12/12/19.
//  Copyright © 2019 Tristate. All rights reserved.
//

import UIKit

class SelfSizedCollectionView: UICollectionView {
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        let s = self.collectionViewLayout.collectionViewContentSize
        return CGSize(width: max(s.width, 1), height: max(s.height,1))
    }
}
