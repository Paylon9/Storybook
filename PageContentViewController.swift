//
//  PageContentViewController.swift
//  Storybook
//
//  Created by Ivan Pavlov on 11/7/15.
//  Copyright © 2015 FreshThinking. All rights reserved.
//

import UIKit

class PageContentViewController: UIViewController {

    var pageIndex: Int = 0
    var titleText: String = ""
    var imageFile: String = ""
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.backgroundImageView.image = UIImage(named: self.imageFile)
        self.backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFit
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
