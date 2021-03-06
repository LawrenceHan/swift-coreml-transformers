//
//  ViewController.swift
//  CoreMLBert
//
//  Created by Julien Chaumond on 27/06/2019.
//  Copyright © 2019 Hugging Face. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {
    
    @IBOutlet weak var shuffleBtn: UIButton!
    @IBOutlet weak var subjectField: UITextView!
    @IBOutlet weak var questionField: UITextView!
    @IBOutlet weak var answerBtn: UIButton!
    @IBOutlet weak var answerLabel: UILabel!
    let loaderView = LoaderView()
    
    var m: BertForQuestionAnswering!
    var subjects: [String] = []
    var questions: [String] = []
    var currentIndex = -1
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(loaderView)
        loaderView.isLoading = true
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            self.loaderView.isLoading = false
        }
        
        shuffle()
        shuffleBtn.addTarget(self, action: #selector(shuffle), for: .touchUpInside)
        answerBtn.addTarget(self, action: #selector(answer), for: .touchUpInside)
        
        subjectField.flashScrollIndicators()
        subjectField.keyboardDismissMode = .onDrag
        subjectField.delegate = self
        questionField.flashScrollIndicators()
        questionField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(moveView(noti:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func shuffle() {
        subjectField.scrollRangeToVisible(.init(location: 0, length: 0))
        answerLabel.text = ""
        
        guard subjects.isEmpty == false,
            questions.isEmpty == false else {
                return
        }
        currentIndex += 1
        if currentIndex >= subjects.count {
            currentIndex = 0
        }
        subjectField.text = subjects[currentIndex]
        questionField.text = questions[currentIndex]
    }
    
    @objc func answer() {
        answerLabel.text = "Loading..."
        loaderView.isLoading = true
        
        let question = questionField.text ?? ""
        let context = subjectField.text ?? ""
        
        DispatchQueue.global(qos: .userInitiated).async {
            let prediction = self.m.predict(question: question, context: context)
            print("🎉", prediction)
            DispatchQueue.main.async {
                self.answerLabel.text = "Is the answer correct?"
                self.loaderView.isLoading = false
                self.say(text: prediction.answer)
            }
        }
    }
    
    func say(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
        
        let alert = UIAlertController(title: "Answer:", message: text, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
        subjectField.textStorage.removeAttribute(.backgroundColor, range: .init(location: 0, length: subjectField.text.count))
        
        guard let range = subjectField.text.range(of: text) else { return }
        let nsrange = NSRange(range, in: subjectField.text)
        subjectField.scrollRangeToVisible(nsrange)
        subjectField.textStorage.addAttribute(.backgroundColor, value: UIColor.systemYellow, range: nsrange)
    }
    
    @objc func moveView(noti: Notification) {
        guard let info = noti.userInfo,
            let value = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            questionField.isFirstResponder else {
                return
        }
        
        let offsetY = value.cgRectValue.origin.y
        if offsetY < view.bounds.height {
            UIView.animate(withDuration: 0.25) {
                let transform = self.questionField.transform.translatedBy(x: 0, y: -value.cgRectValue.height)
                self.questionField.transform = transform
            }
            subjectField.isUserInteractionEnabled = false
        } else {
            UIView.animate(withDuration: 0.25) {
                self.questionField.transform = .identity
            }
            subjectField.isUserInteractionEnabled = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
