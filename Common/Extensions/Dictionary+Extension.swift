//
//  Dictionary+Extension.swift
//  
//
//  Created by Tristate on 12/19/19.
//  Copyright © 2019 Tristate. All rights reserved.
//


import UIKit

//extension Dictionary {
//    func stringFromHttpParameters() -> String {
//        let parameterArray = self.map { (key, value) -> String in
//            let percentEscapedKey = (key as! String).addingPercentEncodingForURLQueryValue()!
//            let percentEscapedValue = (value as! String).addingPercentEncodingForURLQueryValue()!
//            return "\(percentEscapedKey)=\(percentEscapedValue)"
//        }
//        
//        return parameterArray.joined(separator: "&")
//    }
//    
//    var prettyprint : String {
//        for (key,value) in self {
//            print(key,value)
//        }
//        
//        return self.description
//    }
//    
//    func json() -> String {
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
//            guard let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) else {
//                //print("Can't create string with data.")
//                return "{}"
//            }
//            return jsonString
//        } catch  {
//            //print("json serialization error: \(parseError)")
//            return "{}"
//        }
//    }
//    
//}
