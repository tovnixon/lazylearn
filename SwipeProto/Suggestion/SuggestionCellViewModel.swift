//
//  SuggestionCellViewModel.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 3/12/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import Foundation
import UIKit.UICollectionView

struct SuggestionCellViewModel {
  var text: String = ""
  var didSelectSuggestion: ((String) -> Void)?
}

extension SuggestionCellViewModel: CellRepresentable {
  static func registerCell(collectionView: UICollectionView) {
    let name = String(describing: SuggestionViewCell.self)
    let nib = UINib(nibName: name, bundle: nil)
    collectionView.register(nib, forCellWithReuseIdentifier: name)
  }
  
  func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
    let name = String(describing: SuggestionViewCell.self)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: name, for: indexPath) as! SuggestionViewCell
    cell.bind(viewModel: self)
    return cell
  }
  
  func cellSelected() {
    self.didSelectSuggestion?(self.text)
  }
}
