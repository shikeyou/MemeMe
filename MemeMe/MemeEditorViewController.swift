//
//  ViewController.swift
//  MemeMe
//
//  Created by Keng Siang Lee on 19/5/15.
//  Copyright (c) 2015 KSL. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //outlets for ui elements
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    //outlets for constraints
    @IBOutlet weak var topTextFieldTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var topTextFieldLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var topTextFieldRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextFieldLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextFieldRightConstraint: NSLayoutConstraint!
 
    //default placeholder texts for top and bottom text fields when no text is entered
    let defaultTexts: [String] = ["TOP", "BOTTOM"]
    
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //assign delegates
        imagePickerController.delegate = self
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        //do not enable the share button until an image is selected
        shareButton.enabled = false
        
        //do not enable the camera button if camera is not available (e.g. iOS Simulator)
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //subscribe to notifications
        subscribeToKeyboardNotifications()
        subscribeToOrientationChanges()

        //style the top and bottom text fields
        var memeStyleAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSStrokeWidthAttributeName: -5.0  //negative width so that the foreground color will show up
        ]
        let impactFont = UIFont(name: "Impact", size: 25.0)
        if let font = impactFont {
            memeStyleAttributes[NSFontAttributeName] = font
        }
        topTextField.attributedText = NSAttributedString(string: topTextField.text, attributes: memeStyleAttributes)
        bottomTextField.attributedText = NSAttributedString(string: bottomTextField.text, attributes: memeStyleAttributes)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //unsubscribe from notifications
        unsubscribeFromKeyboardNotifications()
        unsubscribeFromOrientationChanges()
    }
    
    
    //================================================
    // TEXT FIELD DELEGATE PROTOCOL METHODS
    //================================================
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        //obtain edited text
        var newText: NSString = textField.text
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        
        //convert text to uppercase
        textField.text = newText.uppercaseString as String
        
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        //empty the text field if text field currently contains the default placeholder text
        if defaultTexts[textField.tag] == textField.text.uppercaseString {
            textField.text = ""
        }
        
        //disable share button when text editing has started
        shareButton.enabled = false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        //put default placeholder text back into the text field if user has emptied the field
        if textField.text.isEmpty {
            textField.text = defaultTexts[textField.tag]
        }
        
        //enable share button after text editing only if an image has been selected
        shareButton.enabled = imageView.image != nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        //finish editing and dismiss keyboard
        textField.resignFirstResponder()
        
        return true
    }
    
    
    //================================================
    // METHODS FOR HANDLING CAMERA AND IMAGE SELECTION
    //================================================

    @IBAction func cameraButtonClicked(sender: UIBarButtonItem) {
        activateCamera()
    }
    
    @IBAction func albumButtonClicked(sender: UIBarButtonItem) {
        pickImage()
    }
    
    @IBAction func cancelButtonClicked(sender: UIBarButtonItem) {
        //just dismiss the modal when cancel button is clicked
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func shareButtonClicked(sender: UIBarButtonItem) {
        
        //generate the memed image first
        let image = generateMemedImage()
        
        if let i = image {  //meme image can be generated
            
            //create an activity view controller with completion handler
            let vc = UIActivityViewController(activityItems: [i], applicationActivities: nil)
            vc.completionWithItemsHandler = {
                (activityType, completed, returnedItems, activityError) in
                if completed {
                    
                    //save the meme into the model first
                    self.saveMeme()
                    
                    //dismiss the modal
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            
            //finally present the view controller
            self.presentViewController(vc, animated: true, completion: nil)
            
        } else {  //meme image cannot be generated
            
            //show an error dialog
            let vc = UIAlertController(title: "Failed Operation", message: "Unable to generated memed image", preferredStyle: UIAlertControllerStyle.Alert)
            vc.addAction(
                UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                    action in
                    //dismiss the alert
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            )
            presentViewController(vc, animated: true, completion: nil)
        }
        
    }
    
    func activateCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            imagePickerController.allowsEditing = false
            imagePickerController.sourceType = .Camera
            presentViewController(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func pickImage() {
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = .PhotoLibrary
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage? {
        
        assert(imageView.image != nil, "imageView must have an image when trying to generate a memed image")
        
        //begin the graphics context first
        UIGraphicsBeginImageContext(view.frame.size)
        
        //screenshot the whole window
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let rawImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        //calculate crop rectangle based on whole window's coordinates
        let rect = calculateScaledImageSizeInView(imageView, image: imageView.image!)
        let transformedOrigin = imageView.convertPoint(rect.origin, toView: view)
        let cropRect = CGRectMake(transformedOrigin.x + 1, transformedOrigin.y + 1, rect.width - 2, rect.height - 2)  //shave away 1 pixel of border to remove some unsightly background color bleed
        
        //crop the screenshot
        let croppedImage = CGImageCreateWithImageInRect(rawImage.CGImage, cropRect)
        let memedImage = UIImage(CGImage: croppedImage)
        
        //end the context
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    func saveMeme() {
        
        //create a meme
        var meme = Meme(top: topTextField.text, bottom: bottomTextField.text, image: imageView.image, memedImage: generateMemedImage())
        
        //add it to the memes array
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        //get user selected image and set it to imageView
        var pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.image = pickedImage
        
        //enable the share button since an image has been selected
        shareButton.enabled = true
        
        //move the top and bottom text fields according to the scaled image
        repositionTextFields()
        
        //also dismiss the image picker view controller
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        //dismiss the image picker view controller
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //calculates the scaled image size within an UIImageView which uses Aspect Fit mode.
    //codes obtained and translated from: http://stackoverflow.com/a/4987554
    func calculateScaledImageSizeInView(imageView: UIImageView, image: UIImage) -> CGRect {
        
        let imageRatio = image.size.width / image.size.height
        let viewRatio = imageView.frame.size.width / imageView.frame.size.height
        
        if imageRatio < viewRatio {
            let scale = imageView.frame.size.height / image.size.height
            let width = scale * image.size.width
            let topLeftX = (imageView.frame.size.width - width) * 0.5
            return CGRectMake(topLeftX, 0, width, imageView.frame.size.height)
        } else {
            let scale = imageView.frame.size.width / image.size.width
            let height = scale * image.size.height
            let topLeftY = (imageView.frame.size.height - height) * 0.5
            return CGRectMake(0, topLeftY, imageView.frame.size.width, height)
        }
    }
    
    func repositionTextFields() {
        
        if let image = imageView.image {
            
            //calculate frame size of scaled image inside the image view
            let rect = calculateScaledImageSizeInView(imageView, image: image)
            
            //change constants on existing constraints to reposition them
            //NOTE: 5 is an arbitrary offset value that visually looks nice
            topTextFieldTopConstraint.constant = rect.origin.y + 5
            topTextFieldLeftConstraint.constant = rect.origin.x - 5
            topTextFieldRightConstraint.constant = imageView.frame.size.width - rect.origin.x - rect.width - 5
            bottomTextFieldBottomConstraint.constant = imageView.frame.size.height - rect.origin.y - rect.height + 5
            bottomTextFieldLeftConstraint.constant = topTextFieldLeftConstraint.constant
            bottomTextFieldRightConstraint.constant = topTextFieldRightConstraint.constant
            
        }
    }
    
    
    //================================================
    // METHODS FOR HANDLING KEYBOARD / ORIENTATION
    //================================================
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillShow(notification: NSNotification) {
        //shift whole view up only if bottom text field is being edited
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //shift whole view down only if bottom text field has been being edited
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func subscribeToOrientationChanges() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func unsubscribeFromOrientationChanges() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func rotated() {
        repositionTextFields()
    }
    
}

