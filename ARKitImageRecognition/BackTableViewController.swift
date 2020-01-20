//
//  BackTableViewController.swift
//  ARKitImageRecognition
//
//  Created by Chia-Ying Wei on 20/7/18.
//  Copyright © 2018 ChiaYing. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class backTableViewController: UITableViewController,UIDocumentInteractionControllerDelegate
{
    //button
    @IBOutlet var close: UIButton!
   
    
    var documentInteractionController: UIDocumentInteractionController!
    var TableArray = [String]()

    
    override func viewDidLoad()
    {
        //button
        /*close.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)*/
        TableArray = [
        ]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return TableArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
//        let VC = parent?.children[1].children[0] as! ViewController
//        if(VC.DocNameArray[VC.currentcount] != nil){VC.docNumber.isHidden=false} //////0718
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        
        cell.textLabel?.text = TableArray[indexPath.row]
        
        return cell
    }
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
       
        return self
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var indexPath : IndexPath = self.tableView.indexPathForSelectedRow!
        let VC = parent?.children[1].children[0] as! ViewController
    
        print(indexPath.row)
        print(VC.DocLocArray[VC.currentcount])
        print((VC.DocLocArray[VC.currentcount][indexPath.row] as! JSON).string!)
        
        
        VC.label.text = "正在加载文档：\"\((VC.DocNameArray[VC.currentcount][indexPath.row] as! JSON).string!)\" 中，請稍等......"
        var url = (VC.DocLocArray[VC.currentcount][indexPath.row] as! JSON).string!
        var safeurl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)


        let destinationT = DownloadRequest.suggestedDownloadDestination()
        
        Alamofire.download(safeurl!, encoding: URLEncoding.default, to: destinationT).response { response in
            print(response.error)
            print(response.destinationURL)
         
            self.documentInteractionController = UIDocumentInteractionController()
            self.documentInteractionController.url = response.destinationURL
            self.documentInteractionController.delegate = self
            self.documentInteractionController.presentPreview(animated: true)
        }
        
        
        
        
    }
    
}
