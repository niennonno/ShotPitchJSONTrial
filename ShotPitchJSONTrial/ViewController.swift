//
//  ViewController.swift
//  ShotPitchJSONTrial
//
//  Created by Aditya Vikram Godawat on 10/02/16.
//  Copyright © 2016 Wow Labz. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation


extension UIImageView {
    public func imageFromUrl(urlString: String) {
        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                if let imageData = data as NSData? {
                    self.image = UIImage(data: imageData)
                }
            }
        }
    }
}


class ViewController: UIViewController {

    @IBOutlet var startupNameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var startupLogo: UIImageView!
    @IBOutlet var startupLocationLabel: UILabel!
    
    
    var url = NSURL()
    var player = AVPlayer()
    var pitchVideoUrl = String()
    
    @IBAction func startupWebsiteAction(sender: AnyObject) {
        self.player = AVPlayer(URL: NSURL(string: pitchVideoUrl)!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = self.player
        playerViewController.view.frame = self.view.frame
        self.presentViewController(playerViewController, animated: true, completion: nil)
//        self.addChildViewController(playerViewController)
        player.play()
        
        print ("button clicked")
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let accessToken = "9f911797-27c1-4ead-8555-9be7c3e5e4db"
        var aResult: NSDictionary!
        let aRequest = NSMutableURLRequest(URL: NSURL(string: "http://devapi.shotpitch.com:8080/api/startupProfile")!)
        
        aRequest.HTTPMethod = "GET"
        aRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let aGroup = dispatch_group_create()
        dispatch_group_enter(aGroup)
        
        let aTask = NSURLSession.sharedSession().dataTaskWithRequest(aRequest, completionHandler: { (aData: NSData?,  aResponse: NSURLResponse?, aError: NSError?) -> Void in
            if let aHttpResponse = aResponse as? NSHTTPURLResponse {
//print(aHttpResponse)
                
                if aHttpResponse.statusCode == 200 {
                    
                    aResult = (try! NSJSONSerialization.JSONObjectWithData(aData!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
                    print(aResult)
                    
                    if let aData = aResult["data"] as! NSDictionary! {
                        
                        self.startupLocationLabel.text = (aData["location"] as! String)
                        self.startupNameLabel.text = (aData["startupName"] as! String)
                        self.descriptionLabel.text = (aData["description"] as! String)
                        let websiteLink = aData["url"] as! String
                        self.url = NSURL(string: "http://" + websiteLink)!
                        
                        let growthMetric = aData["primaryGrowthMetric"]
                        print(growthMetric!["metricType"])
                        print(growthMetric!["metricValue"])
                        
                        let videoID = aData["pitchVideoUrl"] as! String
                        self.pitchVideoUrl = "http://res.cloudinary.com/shotpitch/video/upload/" + videoID + ".mp4"
                        print(self.pitchVideoUrl)

                        
                        
                        
//                        self.moviePlayer = MPMoviePlayerController(contentURL: NSURL(string: pitchVideoUrl))
//                        self.moviePlayer.view.frame = CGRect(x: 20, y: 100, width: 200, height: 150)
//                        
//                        self.view.addSubview(self.moviePlayer.view)
//                        self.moviePlayer.fullscreen = true
//                        
//                        self.moviePlayer.controlStyle = MPMovieControlStyle.Embedded

                        
                        
                        let logoID = aData["logo"] as! String
                        let aURL = "http://res.cloudinary.com/shotpitch/image/upload/" + logoID + ".jpg"
                        self.startupLogo.imageFromUrl(aURL)

                        
                    }
                    
                }
                dispatch_group_leave(aGroup)
                
            } else {
                print(aError?.localizedDescription)
                dispatch_group_leave(aGroup)
            }
        })
        aTask.resume()
        
        dispatch_group_wait(aGroup, DISPATCH_TIME_FOREVER)
    
    
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

