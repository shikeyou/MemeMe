//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Keng Siang Lee on 21/5/15.
//  Copyright (c) 2015 KSL. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //force reload of data every time view is about to show
        collectionView!.reloadData()
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (UIApplication.sharedApplication().delegate as AppDelegate).memes.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        //dequeue a reusable cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("memeCollectionCell", forIndexPath: indexPath) as MemeCollectionViewCell
        
        //get the meme
        let meme = (UIApplication.sharedApplication().delegate as AppDelegate).memes[indexPath.row]
        
        //set appropriate data in the cell
        cell.imageView.image = meme.memedImage
        cell.backgroundColor = UIColor.blackColor()
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        //instantiate a MemeDetailViewController
        let vc = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as MemeDetailViewController
        
        //pass meme data to the instance
        vc.meme = (UIApplication.sharedApplication().delegate as AppDelegate).memes[indexPath.row]
        vc.memeIndex = indexPath.row
        
        //push view controller onto navigation stack
        navigationController!.pushViewController(vc, animated: true)
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
}

class MemeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}