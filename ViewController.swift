//
//  ViewController.swift
//  Storybook
//
//  Created by Ivan Pavlov on 11/7/15.
//  Copyright © 2015 FreshThinking. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    struct Indexs {
        static var currentPageIndex = 0
    }

    static var dicOfImages = [String: String]()
    
    var lastViewController = PageContentViewController()
    var recordToPlay: AVAudioPlayer?
    var pageViewController = UIPageViewController()
    var pageTitles: [String] = []
    var pageImages: [String] = []
    var pageRecords: [NSURL] = []
    
    @IBOutlet weak var titleBar: UILabel!
    @IBOutlet weak var remindMeOutlet: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var customNavBar: UIView!
    
    @IBAction func recordButton(sender: UIButton) {
        self.performSegueWithIdentifier("recordIdentifier" , sender: nil)
        presentViewController(RecordListViewController(), animated: true, completion: nil)
    }

    @IBAction func remindMeButton(sender: UIButton) {
        
        if RecordViewController.dicOfRecords[String(Indexs.currentPageIndex)] != nil {
            let audioString = RecordViewController.dicOfRecords[String(Indexs.currentPageIndex)]
            let audioURL = NSURL(fileURLWithPath: audioString!)
            if let recordToPlay = self.setupAudioPlayerWithFile(audioURL) {
                self.recordToPlay = recordToPlay
            }
            recordToPlay?.play()
        }
    }
    
    @IBAction func goToNextPage(sender: UIButton) {
        
        if Indexs.currentPageIndex >= self.pageTitles.count - 1 {
            
            // Reminder: Add code to end story album
            
        } else {
            
            ++Indexs.currentPageIndex
            self.refreshPageContent(true)
            lastViewController = self.pageViewController.viewControllers!.last! as! PageContentViewController
            self.titleBar.text = lastViewController.titleText
            
            if RecordViewController.dicOfRecords[String(Indexs.currentPageIndex)] != nil {
                remindMeOutlet.enabled = true
            } else { remindMeOutlet.enabled = false }
            
        }
        
    }
    
    @IBAction func AddPhotoButton(sender: UIButton) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        // Reminder: add cropping UI which will work on iPad and on will not crop image to rectange on iPhone
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        let jpegData = UIImageJPEGRepresentation(image, 1.0)
        let imagePath = RecordViewController.getDocumentsDirectory().stringByAppendingPathComponent("image\(ViewController.Indexs.currentPageIndex).jpg")
        jpegData?.writeToFile(imagePath, atomically: true)
        
        ViewController.dicOfImages[String(ViewController.Indexs.currentPageIndex)] = imagePath
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(ViewController.dicOfImages, forKey: "dicOfImages")
        
        // Refreshing image on the page
        self.refreshPageContent(false)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func refreshPageContent(animated: Bool) {
        
        let startingViewController = self.viewControllerAtIndex(Indexs.currentPageIndex)
        let viewControllers = [startingViewController! as UIViewController]
        self.pageViewController.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: animated, completion: nil)
    }

    func setupAudioPlayerWithFile(fileURL: NSURL) -> AVAudioPlayer?  {

        var audioPlayer:AVAudioPlayer?
        do {
             audioPlayer = try AVAudioPlayer(contentsOfURL: fileURL)
        } catch { print("Player is not available") }
        
        return audioPlayer
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as? PageContentViewController)!.pageIndex
        if index == 0 || index == NSNotFound { return nil }
        --index
        
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as? PageContentViewController)!.pageIndex
        if index == NSNotFound { return nil }
        ++index
        if index == self.pageTitles.count { return nil }
        
        return self.viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index: Int) -> PageContentViewController? {
        
        if self.pageTitles.count == 0 || index >= self.pageTitles.count { return nil }
        
        // Creating new view controller, passing data
        let pageContentViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PageContentViewController") as!PageContentViewController
        if ViewController.dicOfImages[String(index)] != nil {
            pageContentViewController.imageFile = ViewController.dicOfImages[String(index)]!
        } else {
            pageContentViewController.imageFile =  self.pageImages[index]
        }
        pageContentViewController.titleText = self.pageTitles[index]
        pageContentViewController.pageIndex = index
        
        return pageContentViewController
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return Indexs.currentPageIndex
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        ViewController.dicOfImages = defaults.objectForKey("dicOfImages") as? [String: String] ?? [String: String]()
        RecordViewController.dicOfRecords = defaults.objectForKey("dicOfRecords") as? [String: String] ?? [String: String]()

        // Printing app documents path
        print("viewdidload docdir\(RecordViewController.getDocumentsDirectory())")
        
        // Creating default data model
        
        pageTitles = ["blank image", "blank image", "blank image", "blank image", "blank image"]
        pageImages = ["blank_image_hq.jpg", "blank_image_hq.jpg", "blank_image_hq.jpg", "blank_image_hq.jpg", "blank_image_hq.jpg"]
        
        // Creating pageViewController
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        
        let startingViewController = self.viewControllerAtIndex(0)
        let viewControllers = [startingViewController! as UIViewController]
        self.pageViewController.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        // Sizing pageViewController
    
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30)
        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        self.view.bringSubviewToFront(customNavBar)
        lastViewController = self.pageViewController.viewControllers!.last! as! PageContentViewController
        self.titleBar.text = lastViewController.titleText
        
        Indexs.currentPageIndex = lastViewController.pageIndex
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if !completed { return }
        lastViewController = self.pageViewController.viewControllers!.last! as! PageContentViewController
        self.titleBar.text = lastViewController.titleText
        
        Indexs.currentPageIndex = lastViewController.pageIndex
//        print("\(Indexs.currentPageIndex)")
        
        if RecordViewController.dicOfRecords[String(Indexs.currentPageIndex)] != nil {
            remindMeOutlet.enabled = true
        } else { remindMeOutlet.enabled = false }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

