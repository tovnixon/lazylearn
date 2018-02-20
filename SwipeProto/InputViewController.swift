//
//  TestTableViewViewController.swift
//  SwipeProto
//
//  Created by Nikita Levintsov on 11/17/17.
//  Copyright © 2017 NikitaLevintsov. All rights reserved.
//

import UIKit
import  AVFoundation

class InputViewController: BaseViewController,  UITextFieldDelegate, UIGestureRecognizerDelegate,
UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  enum InputState: NSInteger {
    case inputWord
    case inputTranslation
    case inputConfirm
  }

  @IBOutlet weak var lblPartOfSpeech: UILabel!
  @IBOutlet weak var txtInput: UnderlineTextField!
  @IBOutlet weak var txtTrans: UnderlineTextField!
  @IBOutlet weak var cnstrNextBottom: NSLayoutConstraint!
  @IBOutlet weak var btnNext: StagedButton!
  @IBOutlet weak var btnVoice: UIButton!
  @IBOutlet weak var cnstrNextHeight: NSLayoutConstraint!
  
  var synthesizer = AVSpeechSynthesizer()
  
  var collectionView: UICollectionView!
  var inputState = InputState.inputWord
  
  var suggestions = [SQLRecord]()
  var suggestionsTrans = [String]()
  var currentWord: SQLRecord?
  
  let dbProvider = SQLiteManager(name: Vocabulary.databaseName(sourceLang: DAO.shared.currentVocabulary.sourceLang, translationLang: DAO.shared.currentVocabulary.translationLang))
  
  let myTextInputMode = UITextInputMode()
  var myInputViewController = UIInputViewController()
  var inputValue: String? = ""
  var translationValue: String? = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
  NotificationCenter.default.addObserver(self,selector:#selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    _ = dbProvider.openDataBase()
    btnNext.isEnabled = false
    lblPartOfSpeech.text = nil
    btnVoice.isHidden = true
    navigationItem.title = DAO.shared.currentVocabulary.title()
    
    cnstrNextHeight.constant = 50
    // placeholder
    let fontAndColorMain = (UIFont.vocInputText, UIColor.vocInputPlaceholder)
    let fontAndColorText = (UIFont.vocTableCellText, UIColor.vocAction)
    txtInput.font = UIFont.vocInputText
    
    let inputPlaceholder = "".byConverting(with:
      [(NSMutableAttributedString(string: "new word"), fontAndColorMain),
      (NSMutableAttributedString(string: "(\(DAO.shared.currentVocabulary.sourceLang.code.rawValue))") , fontAndColorText)])
    txtInput.attributedPlaceholder = inputPlaceholder
    
    //-
    txtTrans.font = UIFont.vocInputText
    let translationPlaceholder = "".byConverting(with:
      [(NSMutableAttributedString(string: "translation"), fontAndColorMain),
       (NSMutableAttributedString(string: "(\(DAO.shared.currentVocabulary.translationLang.code.rawValue))") , fontAndColorText)])
    txtTrans.attributedPlaceholder = translationPlaceholder
    //
    txtInput.text = ""
    txtInput.forceLanguageCode = DAO.shared.currentVocabulary.sourceLang.code.rawValue
    txtInput.textColor = UIColor.vocInputText
    txtInput.backgroundColor = .clear
    txtInput.becomeFirstResponder()
    txtInput.textAlignment = .center
    
    //
    txtTrans.text = ""
    txtTrans.forceLanguageCode = DAO.shared.currentVocabulary.translationLang.code.rawValue
    txtTrans.textColor = UIColor.vocTranslationText
    txtTrans.backgroundColor = .clear
    txtTrans.textAlignment = .center
    
    txtTrans.isHidden = true
    //
    let flowLayout = UICollectionViewFlowLayout()
    collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
    collectionView.delegate = self
    collectionView.dataSource = self
    
    collectionView.isScrollEnabled = false
    collectionView.backgroundColor = UIColor(0xeceef1)
    
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
  
  @objc func keyboardWillShow(notification: Notification) {
    NotificationCenter.default.removeObserver(self, name: notification.name, object: nil)
    
    let userInfo:NSDictionary = notification.userInfo! as NSDictionary
    let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
    let keyboardRectangle = keyboardFrame.cgRectValue
    let keyboardHeight = keyboardRectangle.height
    cnstrNextBottom.constant = keyboardHeight - (self.tabBarController?.tabBar.frame.size.height)! + 10
    self.view.layoutIfNeeded()
    // do whatever you want with this keyboard height
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
    // highlight part of word which matches to input
    collectionView.frame = CGRect(x: collectionView.frame.origin.x, y: collectionView.frame.origin.y, width: collectionView.frame.size.width, height:h)
    self.txtInput.reloadInputViews()
  }
  
  func reloadTableViewTrans() {
    collectionView.reloadData()

    let suggestionsCount = filterSuggestionsTrans(by: txtTrans.text).count
    let defaultCellHeight = suggestionCellHeight(for: suggestionsCount)
    
    var h: CGFloat = 3 * defaultCellHeight
    
    if suggestionsCount == 0 {
      h = 0
    } else if suggestionsCount <= 2 {
      h = defaultCellHeight
    } else if suggestionsCount <= 4 {
      h = 2 * defaultCellHeight
    }

    collectionView.frame = CGRect(x: collectionView.frame.origin.x, y: collectionView.frame.origin.y, width: collectionView.frame.size.width, height:h)
    self.txtTrans.reloadInputViews()
  }
  
  func suggestionCellHeight(for amount: Int) -> CGFloat {
    switch amount {
    case 1...2: return 60
    case 3...4: return 60
    default: return 40
    }
  }

  @IBAction func next() {
    if txtInput.isFirstResponder && inputState == .inputWord {
      if let text = txtInput.text {
        var match = suggestions.filter {$0.word.trimmingCharacters(in: .whitespacesAndNewlines) == text}
        if match.count == 1 {
          // todo: refactor, fix duplication code
          let record = match[0]
          lblPartOfSpeech.text = record.partOfSpeech
          currentWord = record
          suggestionsTrans = dbProvider.fetchTranslations(for: record.word)
          reloadTableViewTrans()
          proceedToNextState()
          return
        }
      }

    }
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
     // cnstrWordTop.constant = 30 //70
      txtInput.solidUnderline = true
      UIView.animate(withDuration: 0.27, animations: {
        self.view.layoutIfNeeded()
        self.txtTrans.alpha = 1
        self.txtTrans.becomeFirstResponder()
        self.btnNext.setTitle("Next", for: .normal) // button could blink
        self.inputState = .inputConfirm
      })
    case .inputTranslation:
      if txtInput.text?.count == 0 || txtTrans.text?.count == 0 {
        return
      }
      let check = UIImageView(image: #imageLiteral(resourceName: "check"))
      self.view.addSubview(check)
      check.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 100)
      UIView.animate(withDuration: 0.27, animations: {
        check.transform = CGAffineTransform.init(scaleX: 2.7, y: 2.7)
        check.alpha = 0
      }, completion: { (completed) in
        check.removeFromSuperview()
      })
 //     cnstrWordTop.constant = 20.0 //120
    //  cnstrNextHeight.constant = 50
      UIView.animate(withDuration: 0.1, animations: {
        self.view.layoutIfNeeded()
        self.txtTrans.alpha = 0
        self.txtInput.becomeFirstResponder()
        self.btnNext.setTitle("Next", for: .normal)

      }, completion: { [unowned self] (completed) in
        var r = VocRecord(self.txtInput.text!, trans: self.txtTrans.text!, vocabulary: DAO.shared.currentVocabulary)
        if let partOfSpeech = self.currentWord?.partOfSpeech {
          r.word.partOfSpeech = partOfSpeech
        }
        
        DAO.shared.insert(r)
        
        self.txtInput.text = nil
        self.txtTrans.text = nil
        self.txtInput.solidUnderline = false
        self.txtTrans.solidUnderline = false
        self.txtTrans.isHidden = true
        self.btnVoice.isHidden = true
        self.suggestions.removeAll()
        self.suggestionsTrans.removeAll()
        self.reloadTableViewTrans()
        self.reloadTableView()
        self.inputValue = ""
        self.translationValue = ""
        self.btnNext.isEnabled = false
        self.currentWord = nil
        self.lblPartOfSpeech.text = nil
        self.inputState = .inputWord
        
      })
    case .inputConfirm:
      if txtTrans.text?.count == 0 {
        return
      }
      self.suggestionsTrans.removeAll()
      self.reloadTableViewTrans()
      txtTrans.solidUnderline = true
      //cnstrNextHeight.constant = cnstrNextHeight.constant * 1.2
      UIView.animate(withDuration: 0.2, animations: {
        self.btnNext.setTitle("Confirm", for: .normal)
        self.view.layoutIfNeeded()
      }, completion: { (completed) in
      
      })
      self.inputState = .inputTranslation
      break
    }
  }

  @IBAction func settings() {
    let menu = UIAlertController(title: "Pick vocabulary", message: nil, preferredStyle: .actionSheet)
    menu.view.tintColor = UIColor.vocAction
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
      DAO.shared.saveOnDisk()
      dbProvider.dbName = Vocabulary.databaseName(sourceLang: newVoc.sourceLang, translationLang: newVoc.translationLang)
      _ = dbProvider.closeDataBase()
      _ = dbProvider.openDataBase()
      txtInput.forceLanguageCode = DAO.shared.currentVocabulary.sourceLang.code.rawValue
      txtTrans.forceLanguageCode = DAO.shared.currentVocabulary.translationLang.code.rawValue
      txtInput.resignFirstResponder()
      txtInput.becomeFirstResponder()
      navigationItem.title = newVoc.title()
    }
  }
  
  func filterSuggestionsTrans(by text: String?) -> [String] {
    if let text = text {
      if text.count > 0 { return suggestionsTrans.filter {$0.contains(text)} }
    }
    return suggestionsTrans
  }
  
  @IBAction func textEditingChanged(sender: UITextField) {
    if sender === txtInput {
      
      if let text = sender.text {
        btnNext.isEnabled = true
        if currentWord?.word != text {
          lblPartOfSpeech.text = nil
        }
        if text.count == 0 {
          btnNext.isEnabled = false
          txtInput.solidUnderline = false
          btnVoice.isHidden = true
        }
        if (text.count >= 2) {
          suggestions = dbProvider.fetchWords(by: text)
          btnVoice.isHidden = false
        } else {
          suggestions.removeAll()
        }
      }
      self.reloadTableView()
    } else if sender == txtTrans {
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
      // check if input text matches to one of suggestions but user ignored it
      if let text = txtInput.text {
        var match = suggestions.filter {$0.word.trimmingCharacters(in: .whitespacesAndNewlines) == text}
        if match.count == 1 {
          // todo: refactor, fix duplication code
          let record = match[0]
          lblPartOfSpeech.text = record.partOfSpeech
          currentWord = record
          suggestionsTrans = dbProvider.fetchTranslations(for: record.word)
          reloadTableViewTrans()
          proceedToNextState()
          return true
        }
      }
      suggestions.removeAll()
      reloadTableView()
      reloadTableViewTrans()
    } else {
      reloadTableViewTrans()
    }
    self.proceedToNextState()
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if (textField === txtInput) {
      inputValue = txtInput.text
    } else {
      translationValue = txtTrans.text
    }
    if let text = textField.text {
      (textField as! UnderlineTextField).solidUnderline = text.count > 0
    }
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField === txtInput {
      inputState = .inputWord
    } else if textField === txtTrans {
      inputState = .inputConfirm
    }
    if let text = textField.text {
      (textField as! UnderlineTextField).solidUnderline = text.count != 0
    }
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let isBackspase = string.count == 0
    if isBackspase {
      print("Backspace pressed")
    }
    if textField == txtTrans {
      if textField.text?.count == 1  && isBackspase {
        print("to zero")
      }
    }
    return true
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if txtInput.isFirstResponder {
        return suggestions.count
    } else if txtTrans.isFirstResponder {
      return filterSuggestionsTrans(by: txtTrans.text).count
    }
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
  {
    let cellId = "suggestionCell"
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath as IndexPath) as! SuggestionCollectionViewCell
    if txtInput.isFirstResponder {
      cell.word.text = suggestions[indexPath.row].word
      cell.word.textColor = UIColor.vocInputText
    } else if txtTrans.isFirstResponder {
      cell.word.text = filterSuggestionsTrans(by: txtTrans.text)[indexPath.row]
      cell.word.textColor = UIColor.vocTranslationText
    }
    cell.backgroundColor = .clear
    cell.contentView.backgroundColor = .clear
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if (txtInput.isFirstResponder) {
      if let record = suggestions[safe: indexPath.row] {
        txtInput.text = record.word//.trimmingCharacters(in: .whitespacesAndNewlines)
        lblPartOfSpeech.text = record.partOfSpeech
        currentWord = record
        suggestionsTrans = dbProvider.fetchTranslations(for: txtInput.text!)
        reloadTableViewTrans()
        proceedToNextState()
      }
    } else if txtTrans.isFirstResponder {
      if let trans = filterSuggestionsTrans(by: txtTrans.text)[safe: indexPath.row] {
        txtTrans.text = trans
        proceedToNextState()
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize  {
    var cellsCount = txtInput.isFirstResponder ? suggestions.count : 0
    if txtTrans.isFirstResponder {
      cellsCount = filterSuggestionsTrans(by: txtTrans.text).count
    }
    
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
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  

}
