//
//  RecordListViewController.swift
//  Storybook
//
//  Created by Ivan Pavlov on 11/7/15.
//  Copyright © 2015 FreshThinking. All rights reserved.
//

import UIKit

class RecordListViewController: UIViewController {

//    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//       return UIInterfaceOrientationMask.Portrait
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Record a reminder"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addRecord")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .Plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelPopover")
    }
    
    func cancelPopover() {
       dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addRecord() {
        let vc = RecordViewController()
        navigationController?.pushViewController(vc, animated: true)
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
