//
//  CellRepresentable.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 3/12/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import UIKit

protocol CellRepresentable {
  static func registerCell(collectionView: UICollectionView)
  func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell
  func cellSelected()
}
