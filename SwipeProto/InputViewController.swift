//
//  TestTableViewViewController.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 11/17/17.
//  Copyright © 2017 NikitaLevintsov. All rights reserved.
//

import UIKit
import  AVFoundation

class InputViewController: UIViewController,  UITextFieldDelegate, UIGestureRecognizerDelegate,
UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  enum InputState: NSInteger {
    case inputWord
    case inputTranslation
    case inputConfirm
  }

  @IBOutlet weak var lblTitle: UILabel!
  @IBOutlet weak var txtInput: UnderlineTextField!
  @IBOutlet weak var txtTrans: UnderlineTextField!
  @IBOutlet weak var cnstrWordTop: NSLayoutConstraint!
  @IBOutlet weak var btnNext: UIButton!
  @IBOutlet weak var btnVoice: UIButton!
  @IBOutlet weak var cnstrNextWidth: NSLayoutConstraint!
  @IBOutlet weak var cnstrNextHeight: NSLayoutConstraint!
  var synthesizer = AVSpeechSynthesizer()
  
  var collectionView: UICollectionView!
  var inputState = InputState.inputWord
  
  var suggestions = [SQLRecord]()
  var suggestionsTrans = [String]()
  
  let dbProvider = SQLiteManager(name: DAO.shared.currentVocabulary.database)
  
  let colorScheme0 = [UIColor.init(red: 0.067, green: 0.467, blue: 0.722, alpha: 1.0),
                     UIColor.init(red: 0.110, green: 0.643, blue: 0.988, alpha: 1.0),
                     UIColor.init(red: 0.361, green: 0.371, blue: 0.988, alpha: 1.0),
                     UIColor.init(red: 0.969, green: 0.725, blue: 0.169, alpha: 1.0),
                     UIColor.init(red: 0.992, green: 0.576, blue: 0.149, alpha: 1.0)]
  
  let colorScheme = [UIColor.init(red:0.04, green:0.01, blue:0.11, alpha:1.0),
                     UIColor.init(red:0.08, green:0.02, blue:0.19, alpha:1.0),
                     UIColor.init(red:0.11, green:0.01, blue:0.31, alpha:1.0),
                     UIColor.init(red:0.17, green:0.04, blue:0.45, alpha:1.0),
                     UIColor.init(red:0.05, green:0.01, blue:0.15, alpha:1.0)]

  let myTextInputMode = UITextInputMode()
  var myInputViewController = UIInputViewController()
  var inputValue: String? = ""
  var translationValue: String? = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    _ = dbProvider.openDataBase()
    
    lblTitle.textColor = UIColor.vocInputText
    lblTitle.font = UIFont.vocHeaders
    lblTitle.text = DAO.shared.currentVocabulary.title()
    btnNext.layer.cornerRadius = 10.0
    cnstrNextWidth.constant = 280
    cnstrNextHeight.constant = 50
    
    txtInput.text = ""
    txtInput.forceLanguageCode = DAO.shared.currentVocabulary.sourceLang.code.rawValue
    txtInput.textColor = UIColor.vocInputText
    txtInput.attributedPlaceholder = NSAttributedString(string: "new word", attributes:[NSAttributedStringKey.foregroundColor : UIColor.vocInputPlaceholder])
    txtInput.backgroundColor = .clear
    txtInput.placeholder = "new word"
    txtInput.becomeFirstResponder()
    txtInput.textAlignment = .center
    txtInput.font = UIFont(name: "SanFranciscoDisplay-Bold", size: 50)
    //
    txtTrans.text = ""
    txtTrans.forceLanguageCode = DAO.shared.currentVocabulary.translationLang.code.rawValue
    txtTrans.textColor = UIColor.vocTranslationText
    txtTrans.attributedPlaceholder = NSAttributedString(string: "translation", attributes:[NSAttributedStringKey.foregroundColor : UIColor.vocTranslationPlaceholder])
    
    txtTrans.backgroundColor = .clear
    txtTrans.placeholder = "translation"
    txtTrans.textAlignment = .center
    txtTrans.font = UIFont(name: "SanFranciscoDisplay-Bold", size: 50)
    txtTrans.isHidden = true
    //
    let flowLayout = UICollectionViewFlowLayout()
    //flowLayout.itemSize = CGSize(width: view.frame.size.width * 0.5 - 10, height: 40)
    
    collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 160), collectionViewLayout: flowLayout)
    collectionView.delegate = self
    collectionView.dataSource = self
    
    collectionView.isScrollEnabled = false
    collectionView.backgroundColor = .lightGray
    
    let nibName3 = UINib(nibName: "SuggestionCollectionViewCell", bundle: nil)
    collectionView.register(nibName3, forCellWithReuseIdentifier: "suggestionCell")
    txtInput.inputAccessoryView = collectionView
    txtInput.inputAccessoryView?.autoresizingMask = .flexibleHeight
    //
    txtTrans.inputAccessoryView = collectionView
    txtTrans.inputAccessoryView?.autoresizingMask = .flexibleHeight
    self.reloadTableView()
    self.reloadTableViewTrans()
  }
  
  @IBAction func tapRecognizer(tapRecognizer: UITapGestureRecognizer) {
    suggestions.removeAll()
    suggestionsTrans.removeAll()
    reloadTableView()
    reloadTableViewTrans()
    self.view.endEditing(true)
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    return touch.view === self.view
  }
  
  func reloadTableView() {
    //tableView.reloadData()
    collectionView.reloadData()
    let defaultCellHeight = suggestionCellHeight(for: suggestions.count)
    var h: CGFloat = 3 * defaultCellHeight
    if suggestions.count == 0 {
      h = 0
    } else if suggestions.count <= 2 {
      h = defaultCellHeight
    } else if suggestions.count <= 4 {
      h = 2 * defaultCellHeight
    }
    //UIView.animate(withDuration: 0.1) {
    //  self.view.layoutIfNeeded()
        collectionView.frame = CGRect(x: collectionView.frame.origin.x, y: collectionView.frame.origin.y, width: collectionView.frame.size.width, height:h)
      self.txtInput.reloadInputViews()
    //}
  }
  
  func reloadTableViewTrans() {
    //tableViewTrans.reloadData()
    collectionView.reloadData()
    let defaultCellHeight = suggestionCellHeight(for: suggestionsTrans.count)
    
    var h: CGFloat = 3 * defaultCellHeight
    if suggestionsTrans.count == 0 {
      h = 0
    } else if suggestionsTrans.count <= 2 {
      h = defaultCellHeight
    } else if suggestionsTrans.count <= 4 {
      h = 2 * defaultCellHeight
    }

    collectionView.frame = CGRect(x: collectionView.frame.origin.x, y: collectionView.frame.origin.y, width: collectionView.frame.size.width, height:h)
    self.txtTrans.reloadInputViews()

  }
  
  func suggestionCellHeight(for amount: Int) -> CGFloat {
    switch amount {
    case 1...2: return 50 //60
    case 3...4: return 35 //40
    default: return 27 //32
    }
  }

  @IBAction func next() {
    proceedToNextState()
  }
  
  @IBAction func voice() {
    if let text = txtInput.text {
      let utterance = AVSpeechUtterance(string: text)
      utterance.voice = AVSpeechSynthesisVoice(language: DAO.shared.currentVocabulary.sourceLang.code.rawValue)
      utterance.rate = 0.4
      synthesizer.speak(utterance)
    }
  }
  
  func proceedToNextState() {
    switch inputState {
    case .inputWord:
      if txtInput.text?.count == 0 {
        return
      }
      txtTrans.isHidden = false
      txtTrans.alpha = 0
      cnstrWordTop.constant = 20 //70
      UIView.animate(withDuration: 0.27, animations: {
        self.view.layoutIfNeeded()
        self.txtTrans.alpha = 1
        self.txtTrans.becomeFirstResponder()
        self.btnNext.setTitle("Next", for: .normal) // button could blink
        self.inputState = .inputConfirm
      })
    case .inputTranslation:
      let check = UIImageView(image: #imageLiteral(resourceName: "check"))
      self.view.addSubview(check)
      check.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 100)
      UIView.animate(withDuration: 0.27, animations: {
        check.transform = CGAffineTransform.init(scaleX: 2.7, y: 2.7)
        check.alpha = 0
      }, completion: { (completed) in
        check.removeFromSuperview()
      })
      cnstrWordTop.constant = 20.0 //120
      cnstrNextWidth.constant = 280
      cnstrNextHeight.constant = 50
      UIView.animate(withDuration: 0.1, animations: {
        self.view.layoutIfNeeded()
        self.txtTrans.alpha = 0
        self.txtInput.becomeFirstResponder()
        self.btnNext.setTitle("Next", for: .normal)

      }, completion: { (completed) in
        let r = VocRecord(self.txtInput.text!, trans: self.txtTrans.text!, vocabulary: DAO.shared.currentVocabulary)
        DAO.shared.insert(r)
        
        self.txtInput.text = nil
        self.txtTrans.text = nil
        self.txtTrans.isHidden = true
        self.txtTrans.font = UIFont(name: "SanFranciscoDisplay-Bold", size: 50)
        self.txtInput.font = UIFont(name: "SanFranciscoDisplay-Bold", size: 50)
        self.suggestions.removeAll()
        self.suggestionsTrans.removeAll()
        self.reloadTableViewTrans()
        self.reloadTableView()
        self.inputValue = ""
        self.translationValue = ""
        self.inputState = .inputWord
        
      })
    case .inputConfirm:
      if txtTrans.text?.count == 0 {
        return
      }
      self.suggestionsTrans.removeAll()
      self.reloadTableViewTrans()
      
      txtTrans.textAlignment = .center
      cnstrNextWidth.constant = cnstrNextWidth.constant * 1.2
      cnstrNextHeight.constant = cnstrNextHeight.constant * 1.2
      UIView.animate(withDuration: 0.2, animations: {
        self.btnNext.setTitle("Confirm", for: .normal)
        self.view.layoutIfNeeded()
      }, completion: { (completed) in
      
      })
      
      txtTrans.font = UIFont(name: "SanFranciscoDisplay-Heavy", size: 50)
      txtInput.font = UIFont(name: "SanFranciscoDisplay-Heavy", size: 50)
      self.inputState = .inputTranslation
      break
    }
  }

  @IBAction func settings() {
    let menu = UIAlertController(title: "Pick vocabulary", message: nil, preferredStyle: .actionSheet)
    let one = UIAlertAction(title: Vocabulary.en_ru_Vocabulary.title(), style: .default) { action in  self.vocabularyChanged(newVoc: Vocabulary.en_ru_Vocabulary)}
    menu.addAction(one)
    let two = UIAlertAction(title: Vocabulary.es_en_Vocabulary.title(), style: .default) { action in self.vocabularyChanged(newVoc: Vocabulary.es_en_Vocabulary)}
    menu.addAction(two)
    let three = UIAlertAction(title: Vocabulary.ede_en_Vocabulary.title(), style: .default) { action in self.vocabularyChanged(newVoc: Vocabulary.ede_en_Vocabulary)}
    menu.addAction(three)
    menu.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    self.present(menu, animated: true, completion: nil)
  }
  
  func vocabularyChanged(newVoc: Vocabulary) {
    if newVoc.title() != DAO.shared.currentVocabulary.title() {
      _ = dbProvider.closeDataBase()
      DAO.shared.currentVocabulary = newVoc
      dbProvider.dbName = newVoc.database
      _ = dbProvider.openDataBase()
      txtInput.forceLanguageCode = DAO.shared.currentVocabulary.sourceLang.code.rawValue
      txtTrans.forceLanguageCode = DAO.shared.currentVocabulary.translationLang.code.rawValue
    
      lblTitle.text = newVoc.title()
    }
  }
  
  @IBAction func textEditingChanged(sender: UITextField) {
    if sender === txtInput {
      txtInput.textAlignment = .left
      if let text = sender.text {
        if text.count == 0 {
          txtInput.solidUnderline = false
        }
        if (text.count >= 2) {
          suggestions = dbProvider.fetchWords(by: text)
        } else {
          suggestions.removeAll()
        }
      }
      self.reloadTableView()
    } else {
      txtTrans.textAlignment = .left
      if let text = sender.text {
        if text.count == 0 {
          txtTrans.solidUnderline = false
        }
      }
      self.reloadTableViewTrans()
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField === txtInput {
      suggestions.removeAll()
      reloadTableView()
      reloadTableViewTrans()
    } else {
      //suggestionsTrans.removeAll()
      reloadTableViewTrans()
    }
    //textField.resignFirstResponder()
    self.proceedToNextState()
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if (textField === txtInput) {
      txtInput.textAlignment = .center
      txtInput.solidUnderline = true
      inputValue = txtInput.text
    } else {
      txtTrans.textAlignment = .center
      txtTrans.solidUnderline = true
      translationValue = txtTrans.text
    }
    if let t = textField.text {
      if t.count > 0 {
      //  _ = self.textFieldShouldReturn(textField)
      }
    }
    // move recent words down to fill keyboard's place
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
//    txtInput.textAlignment = .left
    if textField === txtInput {
      inputState = .inputWord
    } else if textField === txtTrans {
      inputState = .inputConfirm
    }
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if txtInput.isFirstResponder {
        return suggestions.count
    } else if txtTrans.isFirstResponder {
      return suggestionsTrans.count
    }
    return 0

  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    let cellId = "suggestionCell"
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath as IndexPath) as! SuggestionCollectionViewCell
    if txtInput.isFirstResponder {
      cell.word.text = suggestions[indexPath.row].word
    } else if txtTrans.isFirstResponder {
      cell.word.text = suggestionsTrans[indexPath.row]
    }
    cell.backgroundColor = .clear
    cell.contentView.backgroundColor = .lightGray
    if indexPath.row % 2 == 0 {
      cell.contentView.backgroundColor = .gray
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if (txtInput.isFirstResponder) {
      if let word = suggestions[safe: indexPath.row]?.word {
        txtInput.text = word
        suggestionsTrans = dbProvider.fetchTranslations(for: txtInput.text!)
        reloadTableViewTrans()
        proceedToNextState()
        //_ = textFieldShouldReturn(txtInput)
      }
    } else if txtTrans.isFirstResponder {
      if let trans = suggestionsTrans[safe: indexPath.row] {
        txtTrans.text = trans
        //_ = textFieldShouldReturn(txtTrans)
        proceedToNextState()
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize  {
    var cellsCount = txtInput.isFirstResponder ? suggestions.count : 0
    if txtTrans.isFirstResponder {
      cellsCount = suggestionsTrans.count
    }
    
    let width = collectionView.bounds.size.width
    let defaultCellHeight = suggestionCellHeight(for: cellsCount)
    var size = CGSize(width: 100, height: defaultCellHeight)
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
  
  private func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
  {
    return UIEdgeInsets(top: 0, left: 4, bottom: 4, right: 4)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  

}
