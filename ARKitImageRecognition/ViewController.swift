//
//  ViewController.swift
//  Image Recognition
//
//  Created by Jayven Nhan on 3/20/18.
//  Copyright © 2018 Jayven Nhan. All rights reserved.
//

import UIKit
import ARKit
import MetalKit
import WebKit
import Alamofire
import SwiftyJSON
import ModelIO
import SceneKit
import SceneKit.ModelIO



class ViewController: UIViewController {
    //progress
    @IBOutlet weak var taskProgress:UIProgressView!
    var progressValue = 0.0
    //progress
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var label: UILabel!

    
    //Btn on Navigation bar
    @IBOutlet weak var Menu: UIBarButtonItem!
    @IBOutlet weak var Info: UIButton!
    
    
    //Btn for document
    @IBOutlet weak var Toolbar: UIToolbar!
    @IBOutlet weak var Doc: UIBarButtonItem!
    @IBOutlet weak var fileNumber:UIBarButtonItem!
    @IBOutlet weak var docNumber:UITextField!

    
    let fadeDuration: TimeInterval = 0.3
    let rotateDuration: TimeInterval = 3
    let waitDuration: TimeInterval = 0.5
    
    //debug
    @IBOutlet weak var debugLabel: UILabel!
    @IBOutlet weak var debugLabel2: UILabel!
    
    //function elem controller
    var varView = Int()
    //explosion
    @IBOutlet weak var explosionSlider: UISlider!
    //cross section
    @IBOutlet weak var crossSectionDirection: UISegmentedControl!
    //element selector
    @IBOutlet weak var componentsViewerSlider: UISlider!
    //video or image list view
    @IBOutlet weak var VideoListTableView: UIView!
    //Test
    @IBOutlet weak var testView: UIView!
    @IBOutlet weak var testQuestion: UITextView!
    @IBOutlet weak var testQuestionNumber: UILabel!
    var questionNumber = Int()
    
    //for rotating action
    var object: SCNNode!
    var currentAngleY: Float = 0.0
    
    //for web view
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var webView: WKWebView!
    
    //for gif view
    @IBOutlet weak var gifView: UIImageView!
    @IBOutlet weak var gifViewCon: UIView!
    
    lazy var fadeAndSpinAction: SCNAction = {
        return .sequence([
            .fadeIn(duration: fadeDuration),
            .rotateBy(x: 0, y: 0, z: CGFloat.pi * 360 / 180, duration: rotateDuration),
            .wait(duration: waitDuration),
            .fadeOut(duration: fadeDuration)
            ])
    }()
    
    lazy var fadeInAction: SCNAction = {
        return .sequence([
            .fadeIn(duration: fadeDuration)
            ])
    }()
    
    lazy var fadeAction: SCNAction = {
        return .sequence([
            .fadeOpacity(by: 0.8, duration: fadeDuration),
            .wait(duration: waitDuration),
            .fadeOut(duration: fadeDuration)
            ])
    }()
    
    /*
    lazy var treeNode: SCNNode = {
        guard let scene = SCNScene(named: "tree.scn"),
            let node = scene.rootNode.childNode(withName: "tree", recursively: false) else { return SCNNode() }
        let scaleFactor = 0.005
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.eulerAngles.x = -.pi / 2
        return node
    }()
    
    lazy var bookNode: SCNNode = {
        guard let scene = SCNScene(named: "book.scn"),
            let node = scene.rootNode.childNode(withName: "book", recursively: false) else { return SCNNode() }
        let scaleFactor  = 0.1
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        return node
    }()
    
    lazy var mountainNode: SCNNode = {
        guard let scene = SCNScene(named: "mountain.scn"),
            let node = scene.rootNode.childNode(withName: "mountain", recursively: false) else { return SCNNode() }
        let scaleFactor  = 0.25
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.eulerAngles.x += -.pi / 2
        return node
    }()
    
    lazy var triangleNode: SCNNode = {
        guard let scene = SCNScene(named: "triangle.scn"),
            let node = scene.rootNode.childNode(withName: "triangle", recursively: false) else { return SCNNode() }
        let scaleFactor = 0.1
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        return node
    }()
 
    lazy var fremantleSteelNode: SCNNode = {
        guard let scene = SCNScene(named: "fremantleSteel.scn"),
            let node = scene.rootNode.childNode(withName: "fremantleSteel", recursively: false) else { return SCNNode() }
        let scaleFactor = 0.001
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        //node.eulerAngles.x = -.pi / 2
        return node
    }()
 
    lazy var newFremantleSteelNode: SCNNode = {
        guard let scene = SCNScene(named: "newFremantleSteel.scn"),
            let node = scene.rootNode.childNode(withName: "newFremantleSteel", recursively: false) else { return SCNNode() }
        let scaleFactor = 0.00004
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.eulerAngles.x = -.pi / 2
        
        return node
    }()
 */
    var customReferenceSet = Set<ARReferenceImage>()
    var mannode:SCNNode!
    var imageNameArray=[String]()
    var modelNameArray=[Any]()
    var textureNameArray=[Any]()
    var imageLocation:String!
    var imageLocationArray=[String]()
    var modelLocation:Any!
    var modelLocationArray=[Any]()
    var textureLocation:Any!
    var textureLocationArray=[Any]()
    var DocNameArray=[Array<Any>]()
    var DocLocArray=[Array<Any>]()
    var PngNameArray=[Array<Any>]()
    var PngLocArray=[Array<Any>]()
    var idArray=[String]()
    var count = 0
    var DetectImageName = ""
    var currentcount=0
    var textureURL: URL!
    var go_or_not = false
    var loading = false

    
    
    
    //camera check
    func cameraEnable() -> Bool {
        func cameraResult() {
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            
            if (authStatus == .authorized) { /****已授权，可以打开相机****/
                saveCamera(value: "1")
            }
                
            else if (authStatus == .denied) {
                saveCamera(value: "0")
                let alertV = UIAlertView.init(title: "未取用相机权限", message: "请前往\n [设置-课书房AR-允许相机取用]", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "确定")
                alertV.show()
            }
                
            else if (authStatus == .restricted) {//相机权限受限
                saveCamera(value: "0")
                let alertV = UIAlertView.init(title: "提示", message: "相机权限受限", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "确定")
                alertV.show()
            }
                
            else if (authStatus == .notDetermined) {//首次 使用
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (statusFirst) in
                    if statusFirst {
                        //用户首次允许
                        saveCamera(value: "1")
                    } else {
                        //用户首次拒接
                        saveCamera(value: "0")
                    }
                })
            }
        }
        func saveCamera(value: String) {
            UserDefaults.standard.setValue(value, forKey: "cameraEnablebs")
        }
        cameraResult()
        let result = (UserDefaults.standard.value(forKey: "cameraEnablebs") as! String) == "1"
        return result
    }
    
    //camera check
    
    
    
    override func viewDidLoad() {
        let status = Reach().connectionStatus()
        
        switch status {
        case .unknown, .offline:
            print("Not connected")
            //警示框：未連網
            let loginFailWarnAlertController = UIAlertController(title: "提醒", message: "请连接网络", preferredStyle: UIAlertController.Style.alert)
            let okAlertAction = UIAlertAction(title: "关闭", style: UIAlertAction.Style.default, handler: nil)
            loginFailWarnAlertController.addAction(okAlertAction)
            self.present(loginFailWarnAlertController, animated: true, completion: nil)
            //警示框：未連網

        case .online(.wwan):
            print("Connected via WWAN")
        case .online(.wiFi):
            print("Connected via WiFi")
            
        }
       cameraEnable()
       
        //
//        Toolbar.tintColor = UIColor.white
//        Toolbar.isTranslucent = true
//        Toolbar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.any, barMetrics: UIBarMetrics.default)
//        Toolbar.setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.any)
//
        //
        go_or_not = true
        self.docNumber.isHidden=true;
        self.taskProgress.isHidden=true;
        self.navigationController?.isNavigationBarHidden = true
        /*let url = "https://ar-material-management.herokuapp.com/api/ar/arMaterials?fbclid=IwAR3pIDJFtoUogqLqH2W6b3Z8Yh91FJCXjkPi3q67P5udb0x6xMZOxdmUijg"*/
        let url = "https://ar.keshufang.com/api/ar/arMaterials"
        Alamofire.request(url).responseJSON { response in
            //避免取得的資料為nil
            if let json = response.result.value {
                //取得json
                //print("json: \(json)")
                // 找到id
                let json = JSON(json)
                if let id = json[0]["_id"].string {
                    print("_id: \(id)")  }
                
                self.count = json.count
                print(json)
                print("count: \(self.count)") 
                
                for n in 0..<self.count{
                    //print(json[n]["modelLocation"])
                    self.imageNameArray.append(json[n]["imageName"].string!)
                    
                   
                    //self.modelNameArray.append(json[n]["modelName"].string!)
                    //self.textureNameArray.append(json[n]["textureName"].string!)
                    self.imageLocationArray.append(json[n]["imageLocation"].string!)
                    //self.modelLocationArray.append(json[n]["modelLocation"].string!)
                    self.idArray.append(json[n]["_id"].string!)
                    
                    //if((json[n]["imageLocation"].string) != nil){self.imageLocationArray.append(json[n]["imageLocation"].string!)}
                    //if((json[n]["imageLocation"].string) == nil){self.imageLocationArray.append([])}
                    
                    if((json[n]["modelName"].string) != nil){self.modelNameArray.append(json[n]["modelName"].string!)}
                    if((json[n]["modelName"]).string == nil){self.modelNameArray.append([])}
                   
                    if((json[n]["modelLocation"].string) != nil){self.modelLocationArray.append(json[n]["modelLocation"].string!)}
                    if((json[n]["modelLocation"].string) == nil){self.modelLocationArray.append([])}
                    
                    
                    if((json[n]["textureLocation"].string) != nil){self.textureLocationArray.append(json[n]["textureLocation"].string!)}
                    if((json[n]["textureLocation"].string) == nil){self.textureLocationArray.append([])}
                    if((json[n]["textureName"].string) != nil){self.textureNameArray.append(json[n]["textureName"].string!)}
                    if((json[n]["textureName"].string) == nil){self.textureNameArray.append([])}
                    
                    
                    if((json[n]["document_locations"].array) != nil){self.DocLocArray.append(json[n]["document_locations"].array!)}
                    if((json[n]["document_locations"].array) == nil){self.DocLocArray.append([])}
                    if((json[n]["document_names"].array) != nil){
                        self.DocNameArray.append(json[n]["document_names"].array!)}
                    if((json[n]["document_names"].array) == nil){self.DocNameArray.append([])}
                    
                    if((json[n]["PNG_locations"].array) != nil){self.PngLocArray.append(json[n]["PNG_locations"].array!)}
                    if((json[n]["PNG_locations"].array) == nil){self.PngLocArray.append([])}
                    if((json[n]["PNG_names"].array) != nil){
                        self.PngNameArray.append(json[n]["PNG_names"].array!)}
                    if((json[n]["PNG_names"].array) == nil){self.PngNameArray.append([])}
                    /*print(self.imageNameArray[n])
                    print(self.modelNameArray[n])
                    print(self.imageLocationArray[n])
                    print(self.modelLocationArray[n])
                    print(self.idArray[n])*/
                }
                }
            print(self.DocNameArray)
            
            print(self.DocLocArray)
            
            print("PngNameArray",self.PngNameArray)
            //沙盒
            //let urlString = "https://s3.ap-southeast-1.amazonaws.com/ar.materials/1555726054227.M4iIjKs.jpg"
            for n in 0...self.count-1{
               
                let urlString = self.imageLocationArray[n]
                var safeurl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//                print("$$$$ urlString: \(urlString)")
                let destination = DownloadRequest.suggestedDownloadDestination()
                self.label.text = "教材库加载中，请等待教材库加载完成......"
//                self.docNumber.isHidden=false;
//                self.docNumber.text="9";
                    Alamofire.download(safeurl!, encoding: URLEncoding.default, to: destination).response { response in /////ooo
                        
//                        self.label.text = "教材库加载中，请等待教材库加载完成......"
                       
                        //self.FileNumber.text = "2"
                        // 預設為 `.get` 方法
                    /*print("response.request : \(String(describing: response.request))")
                    print(response.response!)
                    print("@@@response.temporaryURL : \(String(describing: response.temporaryURL))")
                    print(response.temporaryURL!)
                    print(response.destinationURL!)
                    print(response.error!)*/
                    
                    var image: UIImage?
                    //let urlStringUI = String(contentsOf: response.destinationURL!)
                    
                    let url = response.destinationURL
                        print("fuu",url)
                        if url != nil{
                        if let imageData: NSData =  NSData(contentsOf: url!) {
                        image = UIImage(data: imageData as Data)
                        
                        let tcdisp = UITraitCollection(displayScale: UIScreen.main.scale)
                        let tcphone = UITraitCollection(userInterfaceIdiom: .phone)
                        let tcreg = UITraitCollection(verticalSizeClass: .regular)
                        let tc1 = UITraitCollection(traitsFrom: [tcdisp, tcphone, tcreg])
                        
                        let moods = UIImageAsset()
                        //let frowney = UIImage(named:"frowney")
                        //let frowney = UIImage(named:self.imageNameArray[n])
                        let frowney = UIImage(named:self.idArray[n])
                        moods.register(image ?? frowney!, with: tc1)
                        
                        //add arrefference image
                        let cgImage = image!.cgImage
                        
                        let referenceImages = ARReferenceImage.init(cgImage!, orientation: .up, physicalWidth: 0.595)
                        //referenceImages.name = "Reference Image"     //用來找模型用的keyword
                        referenceImages.name = self.imageNameArray[n]
                       
                        
                        self.customReferenceSet.insert(referenceImages)
                        
                        let configuration = ARWorldTrackingConfiguration()
                        configuration.detectionImages = self.customReferenceSet
                        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
                        configuration.maximumNumberOfTrackedImages = 1
                        self.sceneView.session.run(configuration, options: options)
                        self.label.text = "教材库加载完成，请扫描图片以载入AR模型"
                    
                
                            }}else{print("bad t")}
                            
                       

                }
            }///for
            
        }
        
        
        /// Converts A CIImage To A CGImage
        ///
        /// - Parameter inputImage: CIImage
        /// - Returns: CGImage
        func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
            let context = CIContext(options: nil)
            if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
                return cgImage
            }
            return nil
        }
      
        
        super.viewDidLoad()
        sceneView.delegate = self
        configureLighting()
        
        //show the slide-out side bar (both left and right)
        //Menu.target = self.revealViewController()     //4/15
        //Menu.action = #selector(SWRevealViewController.revealToggle(_:))   //4/15
        Info.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        
        Doc.target = self.revealViewController()
        Doc.action = #selector(SWRevealViewController.revealToggle(_:))
        
        //
       
        
        
        
        //progress
//        self.perform(#selector(updateProgress), with: nil, afterDelay: 0.2) 
//        self.taskProgress.isHidden=false;
//        self.taskProgress.progress = Float(1.0)
        //progress
        
        
    
        
        
        //show the slide-out sidebar with guestures -> try to use screen edge pan guesture recognizer
        //self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        functionController(index: varView)
        testViewSetting(index: questionNumber)
    }
    
    //progress
    @objc func updateProgress() {
        let fraction = Float.random(in: 0..<0.05)
        progressValue = progressValue + Double(fraction)
        DispatchQueue.main.async {
            self.taskProgress.progress = Float(self.progressValue)
            if self.progressValue <= 0.75 {
                self.perform(#selector(self.updateProgress), with: nil, afterDelay: 0.5)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //progress
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if self.loading==false
//        {
            resetTrackingConfiguration()
//        }
        //self.label.text = "教材库加载中，请等待教材库加载完成......"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //sceneView.session.pause()
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    @IBAction func resetButtonDidTouch(_ sender: UIBarButtonItem) {
        if self.loading==false
        {
            self.object=nil
            resetTrackingConfiguration()
            //clear Document tablevoew
            let CVC = parent?.parent?.children[0] as! backTableViewController
            let CVCtableview = CVC.view as! UITableView
            CVC.TableArray = []
            CVCtableview.reloadData()
            label.text = "请扫描图片以载入模型"
            self.go_or_not = true
            self.taskProgress.isHidden=true;
            self.taskProgress.progress = Float(0.0)
            progressValue = 0.0
        }
    }
    
    @IBAction func videoListTableViewDoneBtnDidTouch(_ sender: Any) {
        varView = 0
        VideoListTableView.isHidden = true
    }
    @IBAction func loadGIFBtnDidTouch(_ sender: Any) {
        addGifImage(Name: "testGif")
    }
    @IBAction func TestViewCancelBtnDidTouch(_ sender: Any) {
        varView = 0
        testView.isHidden = true
    }
    @IBAction func TestViewNextBtnDidTouch(_ sender: Any) {
        questionNumber = questionNumber + 1
        testViewSetting(index: questionNumber)
    }
    @IBAction func componentViewerSliderDidChange(_ sender: Any) {
        let valueFloat = componentsViewerSlider.value
        
        var valueInt = Int(floor(valueFloat))
        if valueInt == Int(componentsViewerSlider.maximumValue) {
            valueInt = valueInt - 1
        }
        
        debugLabel2.text = "Now the value is " + String(valueInt)
        let childNodeList = object.childNodes
        
        var count = Int()
        count = 0
        for i in childNodeList {
            if valueInt == 0{
                i.isHidden = false
            }
            else {
                if count == Int(valueInt) - 1 {
                    i.isHidden = false
                }
                else {
                    i.isHidden = true                }
            }
            count = count + 1
        }
    }
    //VR and AR swicher!
    
    /*@IBAction func VRBtnDidTouch(_ sender: Any) {
     webViewContainer.isHidden = false
     }*/
    @IBOutlet weak var ARVRSegmentControl: UISegmentedControl!
    @IBAction func ARandVRSwitcherdidSwitch(_ sender:
        UISegmentedControl) {
        switch ARVRSegmentControl.selectedSegmentIndex
        {
        case 0:
            NSLog("AR selected")
            webViewContainer.isHidden = true
            if(self.label.text == "加载模型中，请稍等......") {
                self.taskProgress.isHidden=false;
            }
            else{
                self.taskProgress.isHidden=true;
            }
        case 1:
            NSLog("VR selected")
            webViewContainer.isHidden = false
            self.taskProgress.isHidden=true;
//            if let url = URL(string: "https://ar.keshufang.com/vr?id="+self.idArray[self.currentcount]){
////            if let url = URL(string: "https://arteachingmaterial.herokuapp.com/vr?id="+self.idArray[self.currentcount]){
//                UIApplication.shared.openURL(url as URL)
//            }
//         ARVRSegmentControl.selectedSegmentIndex = 0
            
        default:
            break;
        }
    }
    @IBAction func webViewStopBtnDidTouch(_ sender: Any) {
        webView.stopLoading()
    }
    @IBAction func webViewRefreshBtnDidTouch(_ sender: Any) {
        webView.reload()
    }
    @IBAction func gifViewCloseBtnDidTouch(_ sender: Any) {
        gifViewCon.isHidden = true
    }
    //active the interacting function with 3D obj
    @objc func didTap(_ gesture: UIPanGestureRecognizer) {
        guard let _ = object else { return }
        
        let tapLocation = gesture.location(in: sceneView)
        let results = sceneView.hitTest(tapLocation, types: .featurePoint)
        
        if let result = results.first {
            let translation = result.worldTransform.translation
            object.position = SCNVector3Make(translation.x, translation.y, translation.z)
            sceneView.scene.rootNode.addChildNode(object)
        }
    }
    @objc func didPinch(_ gesture: UIPinchGestureRecognizer) {
        guard let nodeToScale = object else { return }
        if gesture.state == .changed {
            
            let pinchScaleX: CGFloat = gesture.scale * CGFloat((nodeToScale.scale.x))
            let pinchScaleY: CGFloat = gesture.scale * CGFloat((nodeToScale.scale.y))
            let pinchScaleZ: CGFloat = gesture.scale * CGFloat((nodeToScale.scale.z))
            nodeToScale.scale = SCNVector3Make(Float(pinchScaleX), Float(pinchScaleY), Float(pinchScaleZ))
            gesture.scale = 1
            
        }
        if gesture.state == .ended { }
    }
    @objc func didPan(_ gesture: UIPanGestureRecognizer) {
        guard let _ = object else { return }
        let translation = gesture.translation(in: gesture.view)
        var newAngleY = (Float)(translation.x)*(Float)(Double.pi)/180.0
        
        newAngleY += currentAngleY
        object?.eulerAngles.y = newAngleY
        
        if gesture.state == .ended{
            currentAngleY = newAngleY
        }
    }
}




extension ViewController: ARSCNViewDelegate
{
    func resetTrackingConfiguration()
    {
        //if self.loading==false{
        self.docNumber.isHidden=true;  
        //guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else { return }
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = self.customReferenceSet
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        configuration.maximumNumberOfTrackedImages = 1
        sceneView.session.run(configuration, options: options)
        sceneView.scene.rootNode.enumerateChildNodes{(node, stop) in
            node.removeFromParentNode()
            //label.text = "请扫描图片以载入模型"
            label.text = " "
        }
        
        
//        //clear Document tablevoew
//        let CVC = parent?.parent?.children[0] as! backTableViewController
//        let CVCtableview = CVC.view as! UITableView
//        CVC.TableArray = []
//        CVCtableview.reloadData()
        
    //}

    }
    

    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)
    {
        if self.go_or_not==true {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        let imageName = referenceImage.name ?? "no name"
        
        
        print("@@@@@imageName: \(imageName)")
        self.DetectImageName = imageName
        //load gif file if it is exist
        //showGif(withImageName: imageName)
        
        //notify which image is detected
        for i in 0...self.count-1{
            if self.DetectImageName  == self.imageNameArray[i]{
                self.currentcount=i
                print("currentcount: \(self.currentcount)")
            }
        }
        DispatchQueue.main.async {
            self.label.text = "加载模型中，请稍等......"
        self.loading = true;
        self.taskProgress.isHidden=false;
        self.taskProgress.progress = Float(0.0)
        self.progressValue = 0.0
            }
        self.perform(#selector(updateProgress), with: nil, afterDelay: 0.5)
        //add the model on the detected image
        object = self.getNode(withImageName: imageName)
        object.opacity = 0
        object.position.y = 0.0
        object.runAction(self.fadeInAction)
        
        

//        object.scale = SCNVector3(0.1, 0.1, 0.1)
        node.addChildNode(object)
        
        
        
        //let urlStringＭ = "https://s3.ap-southeast-1.amazonaws.com/ar.materials/1555726054227.man.obj"
        let urlStringＭ = self.modelLocationArray[currentcount] as? String
        let urlStringT = self.textureLocationArray[currentcount]as? String
        
        var urlStringPNG=[String]()
        for i in 0..<self.PngLocArray[currentcount].count{
            urlStringPNG.append (String(describing: self.PngLocArray[currentcount][i]))
        }
        var PNGNameString=[String]()
        for i in 0..<self.PngNameArray[currentcount].count{
            PNGNameString.append (String(describing: self.PngNameArray[currentcount][i]))
        }
        print("print PNGNameString : ",PNGNameString)
        
        let destinationＭ = DownloadRequest.suggestedDownloadDestination()
        
        
        //set Document tableview function
        let CVC = parent?.parent?.children[0] as! backTableViewController
        let CVCtableview = CVC.view as! UITableView
        CVC.TableArray = []
            //close button
            CVC.close.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
            //close buton
            
        DocNameArray[currentcount].forEach{name in
            var jname = name as! JSON
            CVC.TableArray.append(jname.string!)
        
            if(DocNameArray[currentcount] != nil)
            {
                docNumber.isHidden=false
                docNumber.text=String(DocNameArray[currentcount].count)
            } //////0718
        }
        CVCtableview.reloadData()
        print("X urlStringPNG: ",urlStringPNG)
        if(urlStringＭ != nil){
            if(urlStringPNG != []){
                print("there are pngs on model")
                var safeurl = urlStringＭ!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                Alamofire.download(safeurl!, encoding: URLEncoding.default, to: destinationＭ).response { response in
                    //Alamofire.download(urlStringT, to: destinationT).response { response in
                    // 預設為 `.get` 方法
                    /*print("response.request : \(String(describing: response.request))")
                     print(response.response!)
                     print("@ response.temporaryURL : \(String(describing: response.temporaryURL))")
                     print(response.temporaryURL!)
                     print("@ response.destinationURL : \(String(describing: response.destinationURL))")
                     print(response.error!)*/
                    //            let url = response.destinationURL!
                    //            let source = SCNSceneSource(url: url, options: nil)
                    //            print("000 source: ",source)
                    //
                    //            let block = source?.entryWithIdentifier("Geo", withClass: SCNGeometry.self) as! SCNGeometry
                    //            self.sceneView.scene.rootNode.addChildNode(SCNNode(geometry: block))
                    //
                    //obj
                    let asset = MDLAsset(url: response.destinationURL!)
                    print("$$$$ asset: ",asset)
                    //let object = asset.object(at: 0)
                    var scene = SCNScene(mdlAsset: asset)
                    
                    
                    var safeurl = urlStringT!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    
                    let destinationT = DownloadRequest.suggestedDownloadDestination()
                    Alamofire.download(safeurl!, encoding: URLEncoding.default, to: destinationT).response { response in
                        //Alamofire.download(safeurl!, encoding: URLEncoding.default, to: destinationT)
                        var materials: [SCNMaterial] = Array()
                        var dictionary = [String:String]()
                        var dictionary2 = [String:String]()
                        var dictionary_alpha = [String:String]()
                        //mtl
                        do{
                            let text = try String(contentsOf:response.destinationURL!, encoding: .utf8)
                            
                            var textArr = text.components(separatedBy: "newmtl ")
                            print("textArr before:")
                            print(textArr)
                            textArr.remove(at: 0)
                            print("textArr after:")
                            print(textArr)
                            //                    for str in textArr{
                            //                        var str_child = str.components(separatedBy: "Ka ")
                            //                        var name = str_child[0].components(separatedBy: "\n")[0]
                            //                        dictionary[name] = str_child[1].components(separatedBy: "Kd ")[0].components(separatedBy: "\n")[0]
                            //                        //ex: ["material":"0.55 0.44 0.66"]
                            //                    }
                            
                            for str in textArr{
                                var str_child = str.components(separatedBy: "\n")
                                //                        var name = str_child[0] ///clear \r
                                var name = String(str_child[0].filter { !" \n\t\r".contains($0) })
                                for str_k in str_child
                                {
                                    print(str_k)
                                    if str_k.contains("Kd") && !str_k.contains("map_Kd")
                                    {
                                        
                                        print("Kd")
                                        print(str_k.components(separatedBy: "Kd ")[1])
                                        dictionary[name] = str_k.components(separatedBy: "Kd ")[1]
                                    }
                                    
                                    if str_k.contains("Tf")
                                    {
                                        
                                        print("Tf")
                                        print(str_k.components(separatedBy: "Tf ")[1])
                                        dictionary_alpha[name] = str_k.components(separatedBy: "Tf ")[1]
                                    }
                                    
                                    if str_k.contains("map_Kd")
                                    {
                                        print("map_Kd")
                                        print(str_k.components(separatedBy: "map_Kd ")[1])
                                        dictionary2[name] = str_k.components(separatedBy: "map_Kd ")[1].filter { !" \n\t\r".contains($0) }
                                    }
                                }
                                //ex: ["material":"0.55 0.44 0.66"]
                            }
                            
                        }
                        catch{
                            print("false")
                        }
                        print("dictionary:")
                        print(dictionary)
                        print("dictionary2:")
                        print(dictionary2)
                        //download texture png
                        //var safeurl = urlStringPNG[0].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                        //                    var safeurl=[String]()
                        //                    for i in 0..<urlStringPNG.count{
                        //                        safeurl.append(urlStringPNG[i].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                        //                    }
                        //                    print("safeurl for photo:",safeurl)
                        
                        //                let destinationPNG_1 = DownloadRequest.suggestedDownloadDestination()
                        //
                        //                    Alamofire.download(safeurl!, encoding: URLEncoding.default, to: destinationT).response { response in
                        //
                        //                        print("urlStringPNG_1 response.destinationURL: ",response.destinationURL!)
                        
                        
                        //                //download texture png
                        //                let asset2 = MDLAsset(url: response.destinationURL!)
                        //                print("$$$$ asset2: ",asset2,"99999")
                        //                print("$$$$ asset mtl: ",response.request,"99999")
                        //                //let object = asset.object(at: 0)
                        //                var scene2 = SCNScene(mdlAsset: asset2)
                        self.taskProgress.progress = Float(0.89)+Float.random(in: 0..<0.3)
                        
                        
                        
                        
                        var nodeArray = scene.rootNode.childNodes
                        
                        for chil in nodeArray{
                            self.object = chil as SCNNode
                            
                            let scaleFactor = CGFloat(imageAnchor.referenceImage.physicalSize.height)/CGFloat(self.object.boundingBox.max.y-self.object.boundingBox.min.y)
                            
                            self.object.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
                            print(dictionary)
                            // Kd
                            for mat in self.object.geometry!.materials
                            {
                                if dictionary[mat.name!] != nil
                                {
                                    
                                    var rgb_set = dictionary[mat.name!]?.split(separator: " ")
                                    var alphaa = dictionary_alpha[mat.name!]?.split(separator: " ")
                                    mat.diffuse.contents = UIColor.init(displayP3Red: CGFloat((rgb_set![0] as NSString).floatValue),
                                                                        green: CGFloat((rgb_set![1] as NSString).floatValue),
                                                                        blue: CGFloat((rgb_set![2] as NSString).floatValue), alpha:  CGFloat((alphaa![0] as NSString).floatValue))
                                    print("dictionary[mat.name!]",dictionary[mat.name!])
                                    print("mat",mat)
                                }
                                //                        if dictionary2[mat.name!] != nil
                                //                        {
                                //                            print("response.request in dictionary2: ",response.destinationURL)
                                //                            mat.diffuse.contents = response.destinationURL
                                ////                            mat.diffuse.contents = "1565864352835.fl03.png"
                                //                            print("mat.diffuse.contents: ",mat.diffuse.contents)
                                //                        }
                                //
                            }
                            let destinationPNG_1 = DownloadRequest.suggestedDownloadDestination()
                            var safeurl=[Any]()
                            for i in 0..<urlStringPNG.count{
                                safeurl.append(urlStringPNG[i].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                            }
                            print("safeurl for photo:",safeurl)
                            // texture Kd map
                            var j=0
                            //var appurl=[Any]()
                            print("pngname: ",PNGNameString)
                            for mat in self.object.geometry!.materials
                            {
                                //                        if dictionary[mat.name!] != nil
                                //                        {
                                //
                                //                            var rgb_set = dictionary[mat.name!]?.split(separator: " ")
                                //                            mat.diffuse.contents = UIColor.init(displayP3Red: CGFloat((rgb_set![0] as NSString).floatValue),
                                //                                                                green: CGFloat((rgb_set![1] as NSString).floatValue),
                                //                                                                blue: CGFloat((rgb_set![2] as NSString).floatValue), alpha: 1)
                                //                        }
                                if dictionary2[mat.name!] != nil && j < safeurl.count
                                {
                                    for i in 0..<PNGNameString.count{
                                        if String(dictionary2[mat.name!]!)==PNGNameString[i] {
                                            j=i
                                        }
                                    }
                                    print("\nj= ",j)
                                    print("\nsafeurl[",j,"]= ",safeurl[j])
                                    Alamofire.download(safeurl[j] as! URLConvertible, encoding: URLEncoding.default, to: destinationT).response { response in
                                        //print("name!!!: ",mat.name,"response.request in dictionary2: ",response.destinationURL)
                                        //mat.diffuse.contents = UIImage(named: response.destinationURL!.absoluteString)
                                        //print("str named",response.destinationURL!.absoluteString)
                                        mat.diffuse.contents = response.destinationURL
                                        //appurl.append(response.destinationURL)
                                        //                            mat.diffuse.contents = "1565864352835.fl03.png"
                                        print("dictionary2[mat.name!]",dictionary2[mat.name!])
                                        print("response.destinationURL",response.destinationURL!)
                                        //mat.diffuse.contents=appurl
                                    }
                                    j=0
                                }
                                print("mat: ",mat)
                            }
                            
                            
                            self.taskProgress.progress = Float(0.99)
                            node.addChildNode(self.object)
                            self.label.text = "模型已载入"
                            self.loading = false;
                            
                            self.taskProgress.isHidden=true;
                            self.taskProgress.progress = Float(0.0)
                            self.go_or_not = false
                            
                            //texture
                            
                            //texture
                            
                            
                        }
                    }
                }
            }
            else{
                print("there is no png on model")
                var safeurl = urlStringＭ!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                Alamofire.download(safeurl!, encoding: URLEncoding.default, to: destinationＭ).response { response in
                    //Alamofire.download(urlStringT, to: destinationT).response { response in
                    // 預設為 `.get` 方法
                    /*print("response.request : \(String(describing: response.request))")
                     print(response.response!)
                     print("@ response.temporaryURL : \(String(describing: response.temporaryURL))")
                     print(response.temporaryURL!)
                     print("@ response.destinationURL : \(String(describing: response.destinationURL))")
                     print(response.error!)*/
                    //            let url = response.destinationURL!
                    //            let source = SCNSceneSource(url: url, options: nil)
                    //            print("000 source: ",source)
                    //
                    //            let block = source?.entryWithIdentifier("Geo", withClass: SCNGeometry.self) as! SCNGeometry
                    //            self.sceneView.scene.rootNode.addChildNode(SCNNode(geometry: block))
                    //
                    //obj
                    let asset = MDLAsset(url: response.destinationURL!)
                    print("$$$$ asset: ",asset)
                    //let object = asset.object(at: 0)
                    var scene = SCNScene(mdlAsset: asset)
                    
                    
                    var safeurl = urlStringT!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    
                    let destinationT = DownloadRequest.suggestedDownloadDestination()
                    Alamofire.download(safeurl!, encoding: URLEncoding.default, to: destinationT).response { response in
                        //Alamofire.download(safeurl!, encoding: URLEncoding.default, to: destinationT)
                        var materials: [SCNMaterial] = Array()
                        var dictionary = [String:String]()
                        var dictionary_alpha = [String:String]()
                        //mtl
                        do{
                            let text = try String(contentsOf:response.destinationURL!, encoding: .utf8)
                            
                            var textArr = text.components(separatedBy: "newmtl ")
                            print("textArr before:")
                            print(textArr)
                            textArr.remove(at: 0)
                            print("textArr after:")
                            print(textArr)
                            //                    for str in textArr{
                            //                        var str_child = str.components(separatedBy: "Ka ")
                            //                        var name = str_child[0].components(separatedBy: "\n")[0]
                            //                        dictionary[name] = str_child[1].components(separatedBy: "Kd ")[0].components(separatedBy: "\n")[0]
                            //                        //ex: ["material":"0.55 0.44 0.66"]
                            //                    }
                            
                            for str in textArr{
                                var str_child = str.components(separatedBy: "\n")
                                //                        var name = str_child[0] ///clear \r
                                var name = String(str_child[0].filter { !" \n\t\r".contains($0) })
                                for str_k in str_child
                                {
                                    print(str_k)
                                    if str_k.contains("Kd") && !str_k.contains("map_Kd")
                                    {
                                        
                                        print("Kd")
                                        print(str_k.components(separatedBy: "Kd ")[1])
                                        dictionary[name] = str_k.components(separatedBy: "Kd ")[1]
                                    }
                                    
                                    if str_k.contains("Tf")
                                    {
                                        
                                        print("Tf")
                                        print(str_k.components(separatedBy: "Tf ")[1])
                                        dictionary_alpha[name] = str_k.components(separatedBy: "Tf ")[1]
                                    }
                                    
                                }
                                //ex: ["material":"0.55 0.44 0.66"]
                            }
                            
                        }
                        catch{
                            print("false")
                        }
                        print("dictionary:")
                        print(dictionary)
                        
                        let asset2 = MDLAsset(url: response.destinationURL!)
                        print("$$$$ asset mtl: ",asset2)
                        //let object = asset.object(at: 0)
                        var scene2 = SCNScene(mdlAsset: asset2)
                        
                        
                        
                        
                        var nodeArray = scene.rootNode.childNodes
                        
                        for chil in nodeArray{
                            self.object = chil as SCNNode
                            
                            let scaleFactor = CGFloat(imageAnchor.referenceImage.physicalSize.height)/CGFloat(self.object.boundingBox.max.y-self.object.boundingBox.min.y)
                            
                            self.object.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
                            print(dictionary)
                            for mat in self.object.geometry!.materials
                            {
                                if dictionary[mat.name!] != nil
                                {
                                    
                                    var rgb_set = dictionary[mat.name!]?.split(separator: " ")
                                    var alphaa = dictionary_alpha[mat.name!]?.split(separator: " ")
                                    mat.diffuse.contents = UIColor.init(displayP3Red: CGFloat((rgb_set![0] as NSString).floatValue),
                                                                        green: CGFloat((rgb_set![1] as NSString).floatValue),
                                                                        blue: CGFloat((rgb_set![2] as NSString).floatValue), alpha:  CGFloat((alphaa![0] as NSString).floatValue))
                                    print("dictionary[mat.name!]",dictionary[mat.name!])
                                    print("mat",mat)
                                }
                                
                            }
                            
                            
                            node.addChildNode(self.object)
                            self.label.text = "模型已载入"
                            self.loading = false;
                            self.taskProgress.isHidden=true;
                            self.go_or_not = false
                        }
                        
                        
                    }
                }
            }
        }
        else{
            
            label.text = "此教材尚无模型"
            self.loading = false;
            self.taskProgress.isHidden=true;
            self.go_or_not = false
            //show Document tablevoew
            //CVCtableview.isHidden=false
            
            // create the alert
//            let alert = UIAlertController(title: "提示", message: "此教材尚无模型", preferredStyle: UIAlertController.Style.alert)
//
//            // add an action (button)
//            alert.addAction(UIAlertAction(title: "确认", style: UIAlertAction.Style.default, handler: nil))
//
//            // show the alert
//            self.present(alert, animated: true, completion: nil)
        }
        
        
        DispatchQueue.main.async
            {
                //self.label.text = "Image detected: \"\(imageName)\""
                
                //count how many child node do the object contain
                let myInt = self.object.childNodes.count + 1
                self.componentsViewerSlider.maximumValue = Float(myInt)
                
                //load the vr (forge web view) version of detected 3d model
                let myRequest = URLRequest(url: self.getNodeURL(Node: self.object))
                self.webView.load(myRequest)
        }
        }
        
    }
    
    
    
    
    
    
    var imageHighlightAction: SCNAction
    {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOut(duration: 0.5),
            .removeFromParentNode()
            ])
    }
    func getPlaneNode(withReferenceImage image: ARReferenceImage) -> SCNNode
    {
        let plane = SCNPlane(width: image.physicalSize.width,
                             height: image.physicalSize.height)
        let node = SCNNode(geometry: plane)
        return node
    }
    func getNode(withImageName name: String) -> SCNNode
    {
        var node = SCNNode()
        switch name {
        /*case "Book":
            node = bookNode
        case "Snow Mountain":
            node = mountainNode
        */
        //case DetectImageName:
            //node = mannode
        /*case "Trees In the Dark":
            node = treeNode
        case "triangle is appeared":
            node = triangleNode   */
            //case "Fremantle Steel 3D":
            //node = fremantleSteelNode
        //case "Fremantle Steel":
        //node = newFremantleSteelNode
        default:
            break
        }
        return node
    }
 
    /*func showGif (withImageName name: String)
     {
     switch name {
     case "Snow Mountain":
     addGifImage(Name: "testGif")
     default:
     break
     }
     DispatchQueue.main.async
     {
     self.gifViewCon.isHidden = false
     }
     
     }*/
    func addGifImage (Name: String)
    {
        //let myGif = UIImage.gif(url: Name)
        gifView.loadGif(name: Name)
    }
    func getNodeURL (Node: SCNNode) -> URL
    {
        var myURL: URL!
        
        //myURL = URL(string: "http://ar-develope.herokuapp.com")
        myURL = URL(string: "https://ar.keshufang.com/vr?id="+self.idArray[self.currentcount])
        //myURL = URL(string: "https://arteachingmaterial.herokuapp.com/vr?id="+self.idArray[self.currentcount])
        print("---------------------------------")
        print(self.idArray[self.currentcount])
        print("---------------------------------")
        //self.label.text = "模型已载入： \"\(self.modelNameArray[self.currentcount])\""

        
        //myURL = URL(string: "http://nodewebar.herokuapp.com/?id=5cba7eeb21e2dcba4c887d41")
        //myURL = URL(string: "http://google.com")
        return myURL
    }
    func functionController(index : Int)
    {
        debugLabel.text = "varView is " + String(varView)
        //debugLabel.isHidden = false
        //debugLabel2.isHidden = false
        
        switch index + 1 {
        case 2:
            explosion()
        case 3:
            componentViewer()
        case 4, 5:
            showingVideos()
        case 6:
            givingTests()
        default:
            movingRotatingScaling()
        }
    }
    func movingRotatingScaling ()
    {
        //active guestures for interacting with 3D model (moving, scaling, rotating)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        sceneView.addGestureRecognizer(pinchGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        panGesture.delegate = self as? UIGestureRecognizerDelegate
        sceneView.addGestureRecognizer(panGesture)
    }
    func explosion ()
    {
        explosionSlider.isHidden = false
    }
    func crossSection ()
    {
        crossSectionDirection.isHidden = false
    }
    func componentViewer ()
    {
        componentsViewerSlider.isHidden = false
        debugLabel2.text = String(componentsViewerSlider.maximumValue)
        movingRotatingScaling()
    }
    func showingVideos ()
    {
        VideoListTableView.isHidden = false
        movingRotatingScaling()
    }
    func givingTests ()
    {
        testView.isHidden = false
        movingRotatingScaling()
    }
    func testViewSetting (index: Int)
    {
        testQuestion.text = "這邊要顯示問題"
        testQuestionNumber.text = String(index + 1) + "/10"
            + " (現在是第" + String(index + 1) + "題，總共10題)"
    }
    
}




//for tap guesture
extension float4x4
{
    var translation: float3
    {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
