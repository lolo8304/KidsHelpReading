//
//  CreatorViewController.swift
//  KidsHelpReading
//
//  Created by Lorenz Hänggi on 27.10.16.
//  Copyright © 2016 lolo. All rights reserved.
//

import UIKit
import CoreGraphics

class CreatorViewController: UIViewController, UITextViewDelegate, UINavigationControllerDelegate {

    var appDelegate:AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var container:DataContainer {
        return self.appDelegate.container!
    }
    @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    var activityIndicator:UIActivityIndicatorView!
    var originalTopMargin:CGFloat!
    var story: StoryModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.container.selectedStory != nil) {
            self.story = self.container.selectedStory!
            self.titleField.text = self.story?.title
            self.textView.text = self.story?.text
            self.deleteButton.isEnabled = true
        } else {
            self.deleteButton.isEnabled = false
            self.deleteButton.image = nil
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        originalTopMargin = topMarginConstraint.constant
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.25)
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    
    func removeActivityIndicator() {
        activityIndicator.removeFromSuperview()
        activityIndicator = nil
    }
    
    // MARK: navigation
    @IBAction func add(_ sender: UIBarButtonItem) {
        if (self.container.selectedStory != nil) {
            self.container.selectedStory?.title = self.titleField.text
            self.container.selectedStory?.text = self.textView.text
            self.container.selectedStory?.save()
        } else {
            DataContainer.sharedInstance.createNewStory(name: self.titleField.text!, text: self.textView.text)
        }
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func deleteItem(_ sender: UIBarButtonItem) {
        if (self.container.selectedStory != nil) {
            self.container.deleteStory(story: self.container.selectedStory!)
            self.container.selectedStory = nil
        }
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func capture(_ sender: UIBarButtonItem) {
        // 1
        view.endEditing(true)
        moveViewDown()
        // 2
        let imagePickerActionSheet = UIAlertController(title: "Snap/Upload Photo",
                                                       message: nil, preferredStyle: .actionSheet)
        // 3
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraButton = UIAlertAction(title: "Take Photo",
                                             style: .default) { (alert) -> Void in
                                                let imagePicker = UIImagePickerController()
                                                imagePicker.delegate = self
                                                imagePicker.sourceType = .camera
                                                self.present(imagePicker,
                                                                           animated: true,
                                                                           completion: nil)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        // 4
        let libraryButton = UIAlertAction(title: "Choose Existing",
                                          style: .default) { (alert) -> Void in
                                            let imagePicker = UIImagePickerController()
                                            imagePicker.delegate = self
                                            imagePicker.sourceType = .photoLibrary
                                            self.present(imagePicker,
                                                                       animated: true,
                                                                       completion: nil)
        }
        imagePickerActionSheet.addAction(libraryButton)
        // 5
        let cancelButton = UIAlertAction(title: "Cancel",
                                         style: .cancel) { (alert) -> Void in
        }
        imagePickerActionSheet.addAction(cancelButton)
        imagePickerActionSheet.popoverPresentationController?.barButtonItem = sender
        // 6
        present(imagePickerActionSheet, animated: true,
                              completion: nil)
    }
    
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        var scaleFactor: CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    
    // The remaining methods handle the keyboard resignation/
    // move the view so that the first responders aren't hidden
    
    func moveViewUp() {
        if topMarginConstraint.constant != originalTopMargin {
            return
        }
        
        topMarginConstraint.constant -= 135
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func moveViewDown() {
        if topMarginConstraint.constant == originalTopMargin {
            return
        }
        
        topMarginConstraint.constant = originalTopMargin
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
    }
    
    @IBAction func backgroundTapped(sender: AnyObject) {
        view.endEditing(true)
        moveViewDown()
    }

}



extension CreatorViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveViewUp()
    }
    
    private func textFieldEndEditing(_ sender: AnyObject) {
        view.endEditing(true)
        moveViewDown()
    }
    
    private func textViewDidBeginEditing(_ textView: UITextView) {
        moveViewDown()
    }
    
    
    func performImageRecognition(image: UIImage) {
        // 1
        let tesseract = G8Tesseract(language: "deu", engineMode: .tesseractOnly)

        tesseract?.pageSegmentationMode = .autoOSD
        // 5
        tesseract?.maximumRecognitionTime = 60.0
        // 6
        tesseract?.image = image.g8_grayScale()
        tesseract?.recognize()
        // 7
        if (textView.text == nil) {
            textView.text = ""
        }
        if (tesseract?.recognizedText != nil) {
            textView.text.append((tesseract?.recognizedText)!)
        }
        textView.isEditable = true
        textView.attributedText = spellChecker(string: textView.text).fromBracketsToAttributes()
        // 8
        removeActivityIndicator()
    }
    
    func spellChecker(string: String) -> String {
        
        let checker:UITextChecker = UITextChecker()
        var textToCheck = string
        var index = 0
        var misspelledRange: NSRange
        repeat {
            let text:NSString = textToCheck as NSString
            let checkRange: NSRange = NSMakeRange(index, text.length-index)

            misspelledRange = checker.rangeOfMisspelledWord(in: textToCheck,
                                                            range: checkRange, startingAt: 0, wrap: false, language: "de_CH")
            if misspelledRange.location != NSNotFound {
                let arrGuessed = checker.guesses(forWordRange: misspelledRange, in: textToCheck, language: "de_CH")
                if (arrGuessed != nil && !arrGuessed!.isEmpty) {
                    let replacement = "{{\(arrGuessed!.first!)}}"
                    let toReplace = text.substring(with: misspelledRange)
                    print("replaced \(toReplace) -> \(replacement)")
        
                    textToCheck = text.replacingCharacters(in: misspelledRange, with: replacement )
                    index = misspelledRange.location + misspelledRange.length + ((replacement as NSString).length - misspelledRange.length)
                    print("new index \(index)")
                } else {
                    index = misspelledRange.location + misspelledRange.length

                }
            }
        } while (misspelledRange.location != NSNotFound)
        return textToCheck
    }
}

extension CreatorViewController: UIImagePickerControllerDelegate {
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        let scaledImage = scaleImage(image: selectedPhoto, maxDimension: 640)
        self.image.image = scaledImage
        
        addActivityIndicator()
        
        dismiss(animated: true, completion: {
            self.performImageRecognition(image: scaledImage)
        })

    }
}


extension CreatorViewController : UIPopoverPresentationControllerDelegate {
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        
    }
}
