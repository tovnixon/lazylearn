//
//  AddWordsViewController.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 3/12/18.
//  Copyright © 2018 NikitaLevintsov. All rights reserved.
//

import UIKit

class AddWordsViewController: UIViewController {
  
  private var viewModel: AddWordsViewModel = AddWordsViewModel()
  @IBOutlet weak var txtSource: UnderlineTextField!
  @IBOutlet weak var txtTranslation: UnderlineTextField!
  @IBOutlet weak var btnNext: UIButton!
  
  var collectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let flowLayout = UICollectionViewFlowLayout()
    collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
    collectionView.delegate = self
    collectionView.dataSource = self
    
    collectionView.isScrollEnabled = false
    collectionView.backgroundColor = UIColor(0xeceef1)
    txtSource.inputAccessoryView = collectionView
    txtSource.inputAccessoryView?.autoresizingMask = .flexibleHeight
    
    txtTranslation.inputAccessoryView = collectionView
    txtTranslation.inputAccessoryView?.autoresizingMask = .flexibleHeight

    self.viewModel.suggestionsViewModelsTypes.forEach { $0.registerCell(collectionView: collectionView) }

    bindToViewModel()
  }
  
  //MARK: - ViewModel
  private func bindToViewModel() {
    self.viewModel.didUpdateInputSuggestions = { [weak self] _ in
      self?.viewModelDidUpdate()
    }
    
    viewModel.didSelectInput = { [weak self] suggestion in
      self?.txtSource.text = suggestion 
    }
    
    viewModel.didSelectTranslation = { [weak self] suggestion in
      self?.txtTranslation.text = suggestion
    }
    
    viewModel.didAddWord = {
      //self.btnNext.isEnabled = false
      self.txtSource.becomeFirstResponder()
      self.txtTranslation.isEnabled = false
    }

    viewModel.didUpdateState = { [weak self] newState in
      switch newState {
      case .inputWord:
        self?.btnNext.isEnabled = true
        self?.txtTranslation.isEnabled = false
        break
      case .inputTranslation:
        self?.txtTranslation.isEnabled = true
        self?.txtTranslation.becomeFirstResponder()

      case .inputConfirm: break
      }
    }
    viewModel.didUpdateState?(.inputWord)
  }
  
  private func viewModelDidUpdate() {
    collectionView.reloadData()
    self.txtSource.text = viewModel.source
    self.txtTranslation.text = viewModel.translation
    let count = viewModel.suggestionsViewModels.count
    let defaultCellHeight = suggestionCellHeight(for: count)
    var h: CGFloat = 3 * defaultCellHeight
    if count == 0 {
      h = 0
    } else if count <= 2 {
      h = defaultCellHeight
    } else if count <= 4 {
      h = 2 * defaultCellHeight
    }
    // highlight part of word which matches to input
    collectionView.frame = CGRect(x: collectionView.frame.origin.x, y: collectionView.frame.origin.y, width: collectionView.frame.size.width, height:h)
    if viewModel.state == .inputWord {
      txtSource.reloadInputViews()
    } else if viewModel.state == .inputTranslation {
      txtTranslation.reloadInputViews()
    }
  }
  
  @IBAction func next(_ sender: UIButton) {
    viewModel.next()
  }

}

extension AddWordsViewController: UITextFieldDelegate {
  @IBAction func textEditingChanged(sender: UITextField) {
    switch sender {
    case txtSource: viewModel.source = sender.text
    case txtTranslation: viewModel.translation = sender.text
    default: break
    }
  }
  
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    switch textField {
    case txtSource: viewModel.sourceDidEndEditing()
    case txtTranslation: break
    default: break
    }
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    switch textField {
    case txtSource: viewModel.sourceBeginEditing()
    case txtTranslation: viewModel.translationBeginEditing()
    default: break
    }

  }
}

extension AddWordsViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.viewModel.suggestionsViewModels.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    return self.viewModel.suggestionsViewModels[indexPath.row].dequeueCell(collectionView: collectionView, indexPath: indexPath)
  }
}

extension AddWordsViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    viewModel.suggestionsViewModels[indexPath.row].cellSelected()
  }
}

extension AddWordsViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize  {
    let cellsCount = viewModel.suggestionsViewModels.count
    let width = collectionView.bounds.size.width
    let defaultCellHeight = suggestionCellHeight(for: cellsCount)
    var size: CGSize
    let fullSize = CGSize(width: width, height: defaultCellHeight)
    let halfSize = CGSize(width: width * 0.5 - 10, height: defaultCellHeight);
    switch cellsCount {
    case 1: size = fullSize; break
    case 2,4,6: size = halfSize; break
    case 3,5: if indexPath.row == 0 {
      size = fullSize
    } else { size = halfSize}
    default:
      size = halfSize
    }
    return size
  }
  
  private   func suggestionCellHeight(for amount: Int) -> CGFloat {
    switch amount {
    case 1...2: return 60
    case 3...4: return 60
    default: return 40
    }
  }

}
