//
//  NetworkInfo.swift
//  FYP
//
//  Created by Jason Wong on 6/4/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

class Network{
    func getWiFiSsid() -> String? {
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    // Changed line below from the "ssid =" to return the value directly.
                    return interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                }
            }
        }
        // Changed this to return nil
        return nil
    }
}
