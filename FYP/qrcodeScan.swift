//
//  qrcode.swift
//  FYP
//
//  Created by Jason Wong on 9/2/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyRSA
import CoreLocation

class qrcodeScan: UIViewController, AVCaptureMetadataOutputObjectsDelegate{

    var captureSession = AVCaptureSession()
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    @IBOutlet weak var back: UIButton!
    var printDataName = ""
    var printDataAmount = -1
    var printLocation = CLLocation(latitude: 0, longitude: 0)
    var printTime = Date()
    var printSSID = ""
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.destination is TouchFaceId{
            let vc = segue.destination as? TouchFaceId
            vc?.name = printDataName
            vc?.amount = printDataAmount
            vc?.targetLocation = printLocation
            vc?.time = printTime
            vc?.targetBSSID = printSSID
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let alert2 = UIAlertController(title: "Alert", message: "Please place the QR code in front of the camera", preferredStyle: .alert)
        alert2.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert2, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        //QR code green box
        qrCodeFrameView = UIView()
        if let qrCodeFrameView = qrCodeFrameView{
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
        view.bringSubview(toFront: back)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil{
                
                let result = metadataObj.stringValue!.split(separator: " ")
                print("data is: \(result[0]) sign is: \(result[1]) Public Key is: \(result[2])")
                let Ndat = try! ClearMessage(string: String(result[0]), using: .utf8)
                let Nsign = try! Signature(base64Encoded: String(result[1]))
                let NPKeyString = try! PublicKey(base64Encoded: String(result[2]))
                let isSuccessful = try! Ndat.verify(with: NPKeyString, signature: Nsign, digestType: .sha1)
                
                let finalResult = result[0].split(separator: ",")
                printDataName = String(finalResult[0])
                printDataAmount = Int(finalResult[1])!
                let addressResult = finalResult[3].split(separator: "/")
                let lat = Double(addressResult[0])!
                let long = Double(addressResult[1])!
                printLocation = CLLocation(latitude: lat, longitude: long)
                let iosDate = String(finalResult[2])
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy.HH.mm.ss"
                printTime = dateFormatter.date(from: iosDate)!
                printSSID = String(finalResult[4])
                
                if(isSuccessful){
                    //Stop scanning
                    videoPreviewLayer?.isHidden = true
                    qrCodeFrameView?.isHidden = true
                    self.captureSession.stopRunning()
                    
                    let alert = UIAlertController(title: "Alert", message: "Verified", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{action in self.performSegue(withIdentifier: "paySegue", sender: nil)}))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
