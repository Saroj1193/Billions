//
//  CommonResponse.swift
//  
//
//  Created by Subture Creative Agency on 14/05/18.
//  Copyright © 2018 Subture Creative Agency. All rights reserved.
//

import UIKit

class CommonResponse: NSObject {
    var strMessage : String = ""
    var arrResponse : Array<Any> = Array<Any>()
    var dictResponse : Dictionary<String,Any> = Dictionary<String,Any>()
    var strStatusCode : String = ""
    var strStatus : String = ""
    var strSocketStatusCode : String = ""
    var strMethodName : String = ""
    var totalRecord : Int = 0
    var currentPage : Int = 0
    var hasMoreData : Bool = true
    var totalFollower : Int = 0
    var totalFollowing : Int = 0
    
    
    
    func initWithDictData(data : Dictionary<String,Any>,key : String = "data") -> CommonResponse{
    
        let commonResponse = CommonResponse()
        let dictResponse = data.dictionaryByReplacingNullsWithBlanks()
        if dictResponse.keys.contains("code"){
            commonResponse.strStatusCode = setDataInString(data: dictResponse["code"] as AnyObject)
        }
        if dictResponse.keys.contains("message"){
            commonResponse.strMessage = setDataInString(data: dictResponse["message"] as AnyObject)
        }
        if dictResponse.keys.contains("status"){
            commonResponse.strStatus = setDataInString(data: dictResponse["status"] as AnyObject)
        }
        if dictResponse.keys.contains(key){
            if (dictResponse[key] is [Dictionary<String,Any>]) {
                commonResponse.arrResponse = dictResponse[key] as! [Dictionary<String,Any>]
            }
            else if(dictResponse[key] is Dictionary<String,Any>){
                commonResponse.dictResponse = dictResponse[key] as! Dictionary<String,Any>
            }
            else if (dictResponse[key] is Array<Any>) {
                commonResponse.arrResponse = dictResponse[key] as! Array<Any>
            }
            
        }
        if dictResponse.keys.contains("method_name"){
            commonResponse.strMethodName = setDataInString(data: dictResponse["method_name"] as AnyObject)
        }
        if dictResponse.keys.contains("total_count"){
            commonResponse.totalRecord = Int(setDataInString(data: dictResponse["total_count"] as AnyObject)) ?? 0
        }
        if dictResponse.keys.contains("current_page"){
            commonResponse.currentPage = Int(setDataInString(data: dictResponse["current_page"] as AnyObject)) ?? 0
        }
        if dictResponse.keys.contains("total_followers"){
            commonResponse.totalFollower = Int(setDataInString(data: dictResponse["total_followers"] as AnyObject)) ?? 0
        }
        if dictResponse.keys.contains("total_following"){
            commonResponse.totalFollowing = Int(setDataInString(data: dictResponse["total_following"] as AnyObject)) ?? 0
        }
        if dictResponse.keys.contains("has_more"){
            let hasMoreData = Int(setDataInString(data: dictResponse["has_more"] as AnyObject)) ?? 0
            if hasMoreData == 0{
                commonResponse.hasMoreData = false
            }else{
                commonResponse.hasMoreData = true
            }
        }
        

        return commonResponse
    }
    
    func getArrayFormKey(data : Dictionary<String,Any>,key : String) -> [Dictionary<String,Any>]{
        if data.keys.contains(key){
            if (data[key] is [Dictionary<String,Any>]) {
                return data[key] as! Array<Dictionary<String,Any>>
            }else{
                return self.arrResponse as? [Dictionary<String, Any>] ?? []
            }
            
        }else{
            return self.arrResponse as? [Dictionary<String, Any>] ?? []
        }
    }
    
    func getDictionaryFormKey(data : Dictionary<String,Any>,key : String) -> Dictionary<String,Any>{
        if data.keys.contains(key){
            if (dictResponse[key] is Dictionary<String,Any>) {
                return data[key] as! Dictionary<String,Any>
            }else{
                return self.dictResponse 
            }
            
        }else{
            return self.dictResponse 
        }
    }
    
    
    func initWithResponse(data : Array<Any>) ->CommonResponse{
        let commonResponse = CommonResponse()
        if (data is [Dictionary<String,Any>]) {
            let dictResponse = (data.first as! Dictionary<String,Any>).dictionaryByReplacingNullsWithBlanks()
            if dictResponse.keys.contains("code"){
                commonResponse.strStatusCode = setDataInString(data: dictResponse["code"] as AnyObject)
            }
            if dictResponse.keys.contains("message"){
                commonResponse.strMessage = setDataInString(data: dictResponse["message"] as AnyObject)
            }
            if dictResponse.keys.contains("status"){
                commonResponse.strStatus = setDataInString(data: dictResponse["status"] as AnyObject)
            }
            if dictResponse.keys.contains("code"){
                commonResponse.strSocketStatusCode = setDataInString(data: dictResponse["code"] as AnyObject)
            }
            if dictResponse.keys.contains("data"){
                if (dictResponse["data"] is [Dictionary<String,Any>]) {
                    commonResponse.arrResponse = dictResponse["data"] as! [Dictionary<String,Any>]
                }
                else if(dictResponse["data"] is Dictionary<String,Any>){
                    commonResponse.dictResponse = dictResponse["data"] as! Dictionary<String,Any>
                }
                else if (dictResponse["data"] is Array<Any>) {
                    commonResponse.arrResponse = dictResponse["data"] as! Array<Any>
                }
            
            }
            if dictResponse.keys.contains("method_name"){
                commonResponse.strMethodName = setDataInString(data: dictResponse["method_name"] as AnyObject)
            }
            
        }else{
            
        }
        return commonResponse
    }
}

func setDataInString(data : AnyObject!) -> String {
    let checkDataType = data
    var strResponseData : String = ""
    if checkDataType is String {
        strResponseData  =  checkDataType as! String
    }else if checkDataType is Int {
        strResponseData  = "\(checkDataType as! Int)"// checkDataType as! String
    }else if checkDataType is Float {
        strResponseData  =  "\(checkDataType as! Float)"//  checkDataType as! String
    }
    else if checkDataType is NSNumber {
        strResponseData  =  String(describing: checkDataType as! NSNumber)
    }else if checkDataType is Double {
        strResponseData  =  "\(checkDataType as! Double)"
    }
    
    return strResponseData
}
