//
//  RecordViewController.swift
//  Storybook
//
//  Created by Ivan Pavlov on 11/7/15.
//  Copyright © 2015 FreshThinking. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate {
    
    // Creating a variable audioURL, which value will always be last recorded record
    struct LastRecord {
        static var cachesAudioURL = NSURL()
        static var name = ""
    }
    
    static var dicOfRecords = [String: String]()
    
    var stackView: UIStackView!
    var recordButton: UIButton!
    var recordingSession: AVAudioSession!
    var sbRecorder: AVAudioRecorder!
    
    class func getDocumentsDirectory() -> NSString {
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [String]
        let documentsDirectory = paths[0]
        
        return documentsDirectory
    }
    
    class func getCachesDirectory() -> NSString {
      
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true) as [String]
        let cachesDirectory = paths[0]
        
        return cachesDirectory
    }
    
    class func getRecordURL() -> NSURL {
        LastRecord.name = "sbrecord\(String(ViewController.Indexs.currentPageIndex)).m4a"
        let audioFilename = getCachesDirectory().stringByAppendingPathComponent(LastRecord.name)
        
        
        LastRecord.cachesAudioURL = NSURL(fileURLWithPath: audioFilename)
        
        print("\(LastRecord.cachesAudioURL)")
        return LastRecord.cachesAudioURL
    }
    
    func loadRecordingUI() {
        recordButton = UIButton()
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.setTitle("Tap to Record", forState: .Normal)
        recordButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
        recordButton.addTarget(self, action: "recordTapped", forControlEvents: .TouchUpInside)
        stackView.addArrangedSubview(recordButton)
    }
    
    func loadFailUI() {
        let failLabel = UILabel()
        failLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        failLabel.text = "Recording failed: please ensure the app has access to your microphone."
        failLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(failLabel)
    }
    
    func startRecording() {
        
        view.backgroundColor = UIColor(red: 0.6, green: 0, blue: 0, alpha: 1)
        
        recordButton.setTitle("Tap to Stop", forState: .Normal)
        
        let audioURL = RecordViewController.getRecordURL()
        print(audioURL.absoluteString)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        
        do {
            sbRecorder = try AVAudioRecorder(URL: audioURL, settings: settings)
            sbRecorder.delegate = self
            sbRecorder.record()
        } catch { finishRecording(success: false) }
    }
    
    func finishRecording(success success: Bool) {
        
        view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
        
        sbRecorder.stop()
        sbRecorder = nil
        
        if success {
            recordButton.setTitle("Tap to Re-record", forState: .Normal)
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: "saveTapped")
        } else {
            recordButton.setTitle("Tap to Record", forState: .Normal)
            
            let ac = UIAlertController(title: "Record failed", message: "There was a problem while recording. Please try again.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    func saveTapped() {
        
        // Reminder to add a check if the finishRecording was successful
     
        //Moving recordFile from Caches to Documents directory
        let sbFilemanager = NSFileManager()
        
        let audioString = RecordViewController.getDocumentsDirectory().stringByAppendingPathComponent(LastRecord.name)
        let documentsAudioURL = NSURL(fileURLWithPath: audioString)
        
        // Checking if file already exists in Documents folder
        if sbFilemanager.fileExistsAtPath(audioString) {
            print("File already exists. Deleting..."
            )
            do {
                try sbFilemanager.removeItemAtPath(audioString)
            }
            catch { print("File could not be deleted") }
        }
        
        do {
            try sbFilemanager.moveItemAtURL(LastRecord.cachesAudioURL, toURL: documentsAudioURL) }
        catch { print( "File with this name is already in Documents directory and can't be replaced" ) }
        
        // Adding a value(NSURL) for key(pageIndex)
        RecordViewController.dicOfRecords[String(ViewController.Indexs.currentPageIndex)] = audioString
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(RecordViewController.dicOfRecords, forKey: "dicOfRecords")
        
        print("\(RecordViewController.dicOfRecords)")
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func recordTapped() {
        
        if sbRecorder == nil {
            startRecording()
        } else { finishRecording(success: true) }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if !flag { finishRecording(success: false) }
    }
    
    override func loadView() {
        
        super.loadView()
        
        view.backgroundColor = UIColor.grayColor()
        
        stackView = UIStackView()
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = UIStackViewDistribution.FillEqually
        stackView.alignment = UIStackViewAlignment.Center
        stackView.axis = .Vertical
        view.addSubview(stackView)
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[stackView]|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: ["stackView": stackView]))
        view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant:0))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Record a reminder"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Record", style: .Plain, target: nil, action: nil)
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        self.loadFailUI()
                    }
                }
            }
        } catch { self.loadFailUI() }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
