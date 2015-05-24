//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Keng Siang Lee on 21/5/15.
//  Copyright (c) 2015 KSL. All rights reserved.
//

import UIKit

class MemeTableViewController: UITableViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //force reload of data every time view is about to show
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (UIApplication.sharedApplication().delegate as AppDelegate).memes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //dequeue a reusable cell
        let cell = tableView.dequeueReusableCellWithIdentifier("memeTableViewCell", forIndexPath: indexPath) as MemeTableViewCell
        
        //get the meme
        let meme = (UIApplication.sharedApplication().delegate as AppDelegate).memes[indexPath.row]
        
        //set appropriate data in the cell
        cell.textLabel!.text = meme.top + " "  + meme.bottom
        cell.textLabel!.textColor = UIColor.whiteColor()
        cell.imageView!.image = meme.memedImage
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //instantiate a MemeDetailViewController
        let vc = storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as MemeDetailViewController
        
        //pass meme data to the instance
        vc.meme = (UIApplication.sharedApplication().delegate as AppDelegate).memes[indexPath.row]
        vc.memeIndex = indexPath.row
        
        //push view controller onto navigation stack
        navigationController!.pushViewController(vc, animated: true)
    }
}

class MemeTableViewCell: UITableViewCell {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        //change some of the alignment so that landscape and portrait thumbnails will be aligned the same way
        imageView!.frame = CGRectMake(5, 0, 40, 40)
        imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        imageView!.backgroundColor = UIColor.blackColor()
        textLabel!.frame.origin.x = 50
    }
    
}