//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Keng Siang Lee on 22/5/15.
//  Copyright (c) 2015 KSL. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var meme: Meme?
    var memeIndex: Int?
    
    override func viewWillAppear(animated: Bool) {
        if let image = meme?.memedImage {
            imageView.image = image
        }
    }
    
    @IBAction func deleteButtonClicked(sender: UIBarButtonItem) {
        
        //create an alert view controller
        let vc = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete this meme?", preferredStyle: UIAlertControllerStyle.Alert)
        vc.addAction(
            UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: {
                action in
                
                //remove meme
                self.removeThisMeme()
                
                //pop this detail view controller
                self.navigationController!.popViewControllerAnimated(true)
                
                //dismiss the alert
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        )
        vc.addAction(
            UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
                action in
                
                //just dismiss the alert
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        )
        
        //show the alert
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func removeThisMeme() {
        //remove meme from array
        if let index = memeIndex {
            (UIApplication.sharedApplication().delegate as! AppDelegate).memes.removeAtIndex(index)
        }
    }
}