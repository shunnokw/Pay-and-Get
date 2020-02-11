//
//  qrcodeGen.swift
//  FYPππ
//
//  Created by Jason Wong on 9/2/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

import UIKit
import Firebase
import SwiftyRSA
import Foundation
import CoreLocation
import SystemConfiguration.CaptiveNetwork

class qrcodeGen: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var qrShow: UIImageView!
    var amount: String?
    var id: String?
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        id = uid
        qrShowFun()
        Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(qrcodeGen.qrShowFun), userInfo: nil, repeats: true)
    }
    
    func locationOfGender() -> String {
        guard let loc = locationManager.location?.coordinate else{
            let alertL = UIAlertController(title: "Alert", message: "Location Error", preferredStyle: .alert)
            alertL.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertL, animated: true, completion: nil)
            return "0/0"
        }
        let result = String(loc.latitude) + "/" + String (loc.longitude)
        return result
    }
    
    //function to show QR Code on screen
    @objc func qrShowFun(){
        var myString = ""
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy.HH.mm.ss"
        let i = locationOfGender()
        let genSSID = getNetworkInfos()
        let oldString = id! + "," + amount! + "," + formatter.string(from: date) + ","
        if (genSSID.count != 0){
            myString = oldString + i + "," + genSSID[0].bssid
        }
        else{
            myString = oldString + i + ",nowifi"
        }
        
        print("myString is: \(myString)")
        
        //generate a RSA key pair
        let keyPair = try! SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048)
        let privateKey = keyPair.privateKey
        let publicKey = keyPair.publicKey
        
        //Sign data with private key
        let dat = try! ClearMessage(string: myString, using: .utf8)
        let realData = myString
        let signature = try! dat.signed(with: privateKey, digestType: .sha1)
        //object to string
        let sign = signature.base64String
        let PKeyString = try! publicKey.base64String()
        //string to qr code
        myString = ("\(realData) \(sign) \(PKeyString)")
        
        let data = myString.data(using: String.Encoding.ascii)
        guard let qrFliter = CIFilter(name: "CIQRCodeGenerator")
            else {
                return
        }
        qrFliter.setValue(data, forKey: "inputMessage")
        guard let qrImage = qrFliter.outputImage
            else {
                return
        }
        
        //scale up
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.transformed(by: transform)
        
        //invert color
        guard let colorInvertFilter = CIFilter(name: "CIColorInvert") else {
            return
        }
        colorInvertFilter.setValue(scaledQrImage, forKey: "inputImage")
        guard let outputInvertedImage = colorInvertFilter.outputImage else {
            return
        }
        
        //black to transparent
        guard let maskToAlphaFilter = CIFilter(name: "CIMaskToAlpha") else {
            return
        }
        maskToAlphaFilter.setValue(outputInvertedImage, forKey: "inputImage")
        guard let outputCIImage = maskToAlphaFilter.outputImage else {
            return
        }
        
        //display
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return
        }
        qrShow.image = UIImage(cgImage: cgImage)
    }
    
    struct NetworkInfo {
        public let interface:String
        public let ssid:String
        public let bssid:String
        init(_ interface:String, _ ssid:String,_ bssid:String) {
            self.interface = interface
            self.ssid = ssid
            self.bssid = bssid
        }
    }
    
    func getNetworkInfos() -> Array<NetworkInfo> {
        guard let interfaceNames = CNCopySupportedInterfaces() as? [String] else {
            return []
        }
        let networkInfos:[NetworkInfo] = interfaceNames.compactMap{ name in
            guard let info = CNCopyCurrentNetworkInfo(name as CFString) as? [String:AnyObject] else {
                return nil
            }
            guard let ssid = info[kCNNetworkInfoKeySSID as String] as? String else {
                return nil
            }
            guard let bssid = info[kCNNetworkInfoKeyBSSID as String] as? String else {
                return nil
            }
            return NetworkInfo(name, ssid,bssid)
        }
        return networkInfos
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
