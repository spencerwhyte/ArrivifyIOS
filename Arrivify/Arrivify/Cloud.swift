//
//  Cloud.swift
//  Arrivify
//
//  Created by Spencer Whyte on 2016-01-16.
//  Copyright © 2016 Spencer Whyte. All rights reserved.
//

import UIKit
import Alamofire

class Cloud{
    
    func sendNotifications(message:String, recipients:[String]){
    
        print("\(message)")
        
        let parameters = [
            "message": message,
            "recipients": recipients
        ]
        
        Alamofire.request(.POST, "https://arrivify.com/api/v1/notification/send", parameters: parameters as? [String : AnyObject], encoding: .JSON).responseString { response in
            print("Success: \(response.result.isSuccess)")
            print("Response String: \(response.result.value)")
        }
        
    }
    
    
    
    
}
