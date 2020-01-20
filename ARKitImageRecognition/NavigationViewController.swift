//
//  NavigationViewController.swift
//  ARKitImageRecognition
//
//  Created by CAE on 2019/4/17.
//  Copyright © 2019 ChiaYing. All rights reserved.
//

import Foundation

class navigationViewController : UINavigationController
{
    @IBOutlet weak var NavigationBar: UINavigationBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage()
        
        NavigationBar.setBackgroundImage(image, for: .default)
        NavigationBar.shadowImage = image
        self.navigationController?.view.backgroundColor = UIColor.clear
    }
}
