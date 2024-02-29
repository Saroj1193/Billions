import UIKit
import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public typealias APICompletion = (_ response: [String: Any]?, _ error: Error?) -> Void
public typealias APIRetryBlock = (_ shouldRetry: Bool, _ delay: Double) -> Void

public protocol APIRetrier {
    func shouldRetry(request: URLRequest, response: URLResponse?, completion: @escaping APIRetryBlock)
}

class API {
    public static let shared: API = API()
    public let session: URLSession
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private var acceptableStatusCodes: [Int] = Array(200..<300)
    private let apiCallQueue = DispatchQueue(label: "com.lim.Onglye.API.apiCallQueue")
    var observation: NSKeyValueObservation?
    private var activeRetriers: [OAuth2Handler] = []
    let defaultViewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
    // MARK: - INIT
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 1000 // seconds
        self.session = URLSession(configuration: configuration)
        //        acceptableStatusCodes.append(401)
    }
    
    // MARK: - Convenience
    @discardableResult
    public func request(useRefreshToken: Bool = true, method: HTTPMethod, url: String, body: Data?, completion: @escaping APICompletion) -> URLSessionTask {
                
        let authHandler = OAuth2Handler(accessToken: self.getAuthToken(),  refreshToken: self.getRefreshToken() ??  "")
        authHandler.useRefreshToken = useRefreshToken
        var headers = self.headers()
        if url.contains(APIActionName.appleGoogleLogin) || url.contains(APIActionName.otp) || url.contains(APIActionName.setUserDeviceRelation){
            headers["device_token"] = UserDefaults.standard.string(forKey: APPData.UserDefaultKeys.DEVICE_TOKEN) ?? ""
        }
        
        if (UserDefaults.standard.object(forKey: "isLogin") != nil) {
            let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
            if isLogin {

            }else{
                if headers["auth_token"] == "" {
                    headers["auth_token"] = APPData.Auth_TOKEN_FIRST_TIME
                }
            }
        }else{
            if headers["auth_token"] == "" {
                headers["auth_token"] = APPData.Auth_TOKEN_FIRST_TIME
            }
        }
        
        let request = self.formattedRequest(url: url, method: method, headers: headers, body: body)
        
        let task = self.session.dataTask(with: request, completionHandler: { (data, response, error) in
            self.debugResponsePrint(url: url, method: method, headers: response as Any, body: data)
            
            
            
            self.apiCallQueue.async {
                
                guard self.validate(response: response, with: error, optionallyRetry: request, authHandler: authHandler, useRefreshToken: useRefreshToken, method: method, url: url, body: body,responseData: data, completion: completion) else {
//
                    self.debugPrint(url: url, method: method, headers: headers, body: body)
                    DispatchQueue.main.async {
                        if UserDefaults.standard.object(forKey: "isLogin") != nil{
                            if (UserDefaults.standard.bool(forKey: "isLogin") == true){
                                
                                let objnavigation = (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)
                                let topVC = objnavigation?.visibleViewController as? UITabBarController
                                let objVC = (topVC?.selectedViewController as? UINavigationController)?.visibleViewController as? BaseViewController
                                objVC?.hideSpinner()
                                objVC?.view.isUserInteractionEnabled = true
                            }else {
                                
                                let objnavigation = (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)
                                let topVC = objnavigation?.visibleViewController as? BaseViewController
                                topVC?.hideSpinner()
                                topVC?.view.isUserInteractionEnabled = true
                            }
                        }else{
                            let objnavigation = (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)
                            let topVC = objnavigation?.visibleViewController as? BaseViewController
                            topVC?.hideSpinner()
                            topVC?.view.isUserInteractionEnabled = true
                        }
                        completion(nil, error)
                    }
                    
                    return }
                
                do
                {
                    let dictionary = try JSONSerialization.jsonObject(with: data!)
                    if(dictionary is [[String:Any]]) {
                        let dict = ["data":dictionary]
                        
                        DispatchQueue.main.async { completion(dict, nil) }
                    }else{
                        if let aDict = dictionary as? [String:Any], aDict["code"] as? Int == 403, let msg = aDict["message"] as? String{
                            DispatchQueue.main.async {

                                if UserDefaults.standard.object(forKey: "isLogin") != nil{
                                    if (UserDefaults.standard.bool(forKey: "isLogin") == true){
                                        
                                        let objnavigation = (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)
                                        let topVC = objnavigation?.visibleViewController as? UITabBarController
                                        if topVC == nil {
                                            let topVC = objnavigation?.visibleViewController as? BaseViewController
                                            topVC?.hideSpinner()
                                            topVC?.view.isUserInteractionEnabled = true
                                            topVC?.showAlertOKHandler(message: msg, completion: nil)
                                        } else {
                                            let objVC = (topVC?.selectedViewController as? UINavigationController)?.visibleViewController as? BaseViewController
                                            objVC?.hideSpinner()
                                            objVC?.view.isUserInteractionEnabled = true
                                            objVC?.showAlertOKHandler(message: msg, completion: nil)
                                        }
                                    }else {
                                        
                                        let objnavigation = (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)
                                        let topVC = objnavigation?.visibleViewController as? BaseViewController
                                        topVC?.hideSpinner()
                                        topVC?.view.isUserInteractionEnabled = true
                                        topVC?.showAlertOKHandler(message: msg, completion: nil)
                                    }
                                }else{
                                    let objnavigation = (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)
                                    let topVC = objnavigation?.visibleViewController as? BaseViewController
                                    topVC?.hideSpinner()
                                    topVC?.view.isUserInteractionEnabled = true
                                    topVC?.showAlertOKHandler(message: msg, completion: nil)
                                }
                            }
                        }
                        else{
                            DispatchQueue.main.async { completion(dictionary as? [String:Any], nil) }
                        }
                    }
                }
                catch {
                    DispatchQueue.main.async { completion(nil, error) }
                }
            }
        })
        task.resume()
        return task
    }
    
    
    // MARK: - Convenience
    @discardableResult
    public func requestWithImage(useRefreshToken: Bool = true, method: HTTPMethod, url: String, body: Data?,imgImage: Data?,attachmentKey : String, completion: @escaping APICompletion,dictData : Dictionary<String,Any>) -> URLSessionTask {
        
        let authHandler = OAuth2Handler(accessToken: self.getAuthToken(),  refreshToken: self.getRefreshToken() ??  "")
        authHandler.useRefreshToken = useRefreshToken
        let headers = self.headersForImage()
        var request = self.formattedRequestWithImageFormData(url: url, method: .post
                                                             , headers: headers, body: body, dictData: dictData, imageData: imgImage, attachmentKey: attachmentKey)
        request.timeoutInterval = 1000
        let task = self.session.dataTask(with: request, completionHandler: { (data, response, error) in
            self.apiCallQueue.async {
                
                guard self.validateImage(response: response, with: error, optionallyRetry: request, authHandler: authHandler, useRefreshToken: useRefreshToken, method: method, url: url, body: body, imageData: imgImage, attachmentKey: attachmentKey, dictData: dictData, completion: completion) else {
                    return
                }
                
                if data == nil{
                    DispatchQueue.main.async { completion(nil, error) }
                }
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data!) as? [String: Any] ?? [:]
                    DispatchQueue.main.async { completion(dictionary, nil) }
                }
                catch {
                    DispatchQueue.main.async { completion(nil, error) }
                }
            }
        })
        task.resume()
        return task
    }
    
    private func validateImage(response: URLResponse?, with error: Error?, optionallyRetry request: URLRequest, authHandler: OAuth2Handler, useRefreshToken: Bool, method: HTTPMethod, url: String, body: Data?,imageData : Data?,attachmentKey : String,dictData : Dictionary<String,Any>, completion: @escaping APICompletion) -> Bool {
        
        let imgData = imageData 
        // swiftlint:disable:next force_cast
        if (error != nil) || (response == nil) || (response != nil && (response is HTTPURLResponse) && !self.acceptableStatusCodes.contains((response as! HTTPURLResponse).statusCode)) {
            
            self.activeRetriers.append(authHandler)
            authHandler.shouldRetry(request: request, response: response, completion: { (shouldRetry, delay) in
                
                if shouldRetry {
                    self.apiCallQueue.asyncAfter(deadline: .now() + delay) {
                        if imageData != nil{
                            self.requestWithImage(method: method, url: url, body: body, imgImage: imageData, attachmentKey: attachmentKey, completion: completion, dictData: dictData)
                        }else{
                            self.request(useRefreshToken: useRefreshToken, method: method, url: url, body: body, completion: completion)
                        }
                    }
                }
                else {
                    DispatchQueue.main.async { completion(nil, error) }
                }
                
                if let index = self.activeRetriers.firstIndex(where: { $0 === authHandler }) {
                    self.activeRetriers.remove(at: index)
                }
            })
            
            return false
        }
        return true
    }
    
    private func formattedRequestWithImageFormData(url: String, method: HTTPMethod, headers: [String: String], body: Data?,dictData : Dictionary<String,Any>,imageData: Data?,attachmentKey : String) -> URLRequest {
        
        let _:NSMutableData=NSMutableData()
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method.rawValue
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let boundry:NSString="---------------------------14737809831466499882746641449"
        let contentType:NSString=NSString(format: "multipart/form-data; boundary=%@", boundry)
        for (key, value) in headers {
            if key == "Content-Type" {
                request .setValue(contentType as String, forHTTPHeaderField: "Content-Type")
            } else{
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        request .setValue(contentType as String, forHTTPHeaderField: "Content-Type")
        if imageData != nil{
            
            let body1:Data = self.createBodyWithParameters(parameters: dictData, filePathKey: attachmentKey, imageDataKey: imageData, boundary: boundry as String, imageData: imageData)
            request.httpBody  = body1
        }else {
            let body1:Data = self.createBodyForEditWithParameters(parameters: dictData, filePathKey: attachmentKey, imageDataKey: imageData, boundary: boundry as String, imageData: imageData)
            request.httpBody  = body1 as Data
        }
        return request
    }
    
    
    func createBodyForEditWithParameters(parameters: [String: Any]?, filePathKey: String?, imageDataKey: Data?, boundary: String,imageData:Data?) -> Data {
        let body = NSMutableData()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        if(imageData != nil){
            let strFile = "profilePic"
            body.appendString("--\(boundary)\r\n")
            let mimetype = "image/jpg"
            body.appendString("Content-Disposition: form-data; name=\"\(strFile)\"; filename=\"\(Date().ticks).jpg\"\r\n")
            
            body.appendString("Content-Type: \(mimetype)\r\n\r\n")
            body.append(imageData! as Data)
        }
        body.appendString("--\(boundary)--\r\n")
        return body as Data
    }
    
    func createBodyWithParameters(parameters: [String: Any]?, filePathKey: String?, imageDataKey: Data?, boundary: String,imageData:Data?) -> Data {
        let body = NSMutableData()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        if(imageData != nil){
            let mimetype = "image/jpg"
            let strFile = filePathKey ?? "profilePic"
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(strFile)\"; filename=\"\(Date().ticks).jpg\"\r\n")
            body.appendString("Content-Type: \(mimetype)\r\n\r\n")
            body.append(imageData! as Data)
        }
        body.appendString("\r\n")
        body.appendString("--\(boundary)--\r\n")
        return body as Data
    }
    
    @discardableResult
    public func unqualifiedRequest(url: String, method: HTTPMethod, headers: [String: String], body: Data?, completion: @escaping APICompletion) -> URLSessionTask {
        
        let request = self.formattedRequest(url: url, method: method, headers: headers, body: body)
        
        let task = self.session.dataTask(with: request, completionHandler: { (data, response, error) in
            self.apiCallQueue.async {
                guard let data = data, error == nil else {
                    //completion(nil, error)
                    self.debugPrint(url: url, method: method, headers: headers, body: body)
                    DispatchQueue.main.async { completion(nil, error) }
                    return
                }
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data)
                    if(dictionary is [String:Any]) {
                        let dict = dictionary as? Dictionary<String,Any> //["data":dictionary]
                        // swiftlint:disable:next force_cast
                        if dict!["code"] as? Int == 403 {
                            let message = dict!["message"] as? String
                            if UserDefaults.standard.object(forKey: "isLogin") != nil{
                                if (UserDefaults.standard.bool(forKey: "isLogin") == true){
                                    DispatchQueue.main.async {
                                        let objnavigation = (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)
                                        let topVC = objnavigation?.visibleViewController as? UITabBarController
                                        if topVC == nil {
                                            let topVC = objnavigation?.visibleViewController as? BaseViewController
                                            topVC?.hideSpinner()
                                            topVC?.view.isUserInteractionEnabled = true
                                            topVC?.showAlertOKHandler(message: message!, completion: nil)
                                        } else {
                                            let objVC = (topVC?.selectedViewController as? UINavigationController)?.visibleViewController as? BaseViewController
                                            objVC?.hideSpinner()
                                            objVC?.view.isUserInteractionEnabled = true
                                            objVC?.showAlertOKHandler(message: message!, completion: nil)
                                        }
                                    }
                                }else {
                                    DispatchQueue.main.async {
                                        let objnavigation = (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)
                                        let topVC = objnavigation?.visibleViewController as? BaseViewController
                                        topVC?.hideSpinner()
                                        topVC?.view.isUserInteractionEnabled = true
                                        topVC?.showAlertOKHandler(message: message!, completion: nil)
                                    }
                                }
                            }else{
                                DispatchQueue.main.async {
                                    let objnavigation = (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)
                                    let topVC = objnavigation?.visibleViewController as? BaseViewController
                                    topVC?.hideSpinner()
                                    topVC?.view.isUserInteractionEnabled = true
                                    topVC?.showAlertOKHandler(message: message!, completion: nil)
                                }
                            }
                        }else{
                            DispatchQueue.main.async { completion((dict), nil) }
                        }
                    }
                }
                catch {
                    //                    self.debugPrint(url: url, method: method, headers: headers, body: body)
                    DispatchQueue.main.async { completion(nil, error) }
                }
            }
        })
        task.resume()
        return task
    }
    
    public func cancelAllRequests() {
        session.getAllTasks { (tasks) in
            tasks.forEach({ $0.cancel() })
        }
    }
    
    // MARK: - Helpers
    func headerForRefreshToken() -> [String:String] {
        return [
            "Content-Type":"application/json",
//            "auth_token": (UserBo.shared != nil) ?  UserBo.shared.auth_token ?? APPData.Auth_TOKEN_FIRST_TIME : APPData.Auth_TOKEN_FIRST_TIME,
            "language": "en",
            "device_id": APPData.DEVICE_UUID,
            "device_type" : "0",
            "ios_app_version":APPData.APP_VERSION,
            "os": "OS-\(APPData.OS_VERSION) manufacture-\(UIDevice.current.userInterfaceIdiom == .phone ? "iPhone" : "iPad") Model-\(UIDevice.current.modelName)",
            "refresh_token" : APPData.REFRESH_TOKEN_FIRST_TIME
        ]
    }
    
    func headers() -> [String: String] {
        return [
            "Content-Type":"application/json",
            "auth_token":getAuthToken(),
            "language": "en",
            "device_id": APPData.DEVICE_UUID,
            "device_type" : "0",
            "ios_app_version":APPData.APP_VERSION,
            "os": "OS-\(APPData.OS_VERSION) manufacture-\(UIDevice.current.userInterfaceIdiom == .phone ? "iPhone" : "iPad") Model-\(UIDevice.current.modelName)"
        ]
    }
    
    func headersForImage() -> [String: String] {
        return [
            "Content-Type":"application/json",
            "auth_token":getAuthToken(),
            "language": "en",
            "device_id": APPData.DEVICE_UUID,
            "device_type" : "0",
            "ios_app_version":APPData.APP_VERSION,
            "os": "OS-\(APPData.OS_VERSION) manufacture-\(UIDevice.current.userInterfaceIdiom == .phone ? "iPhone" : "iPad") Model-\(UIDevice.current.modelName)"
        ]
    }
    
    func getAuthToken() -> String {
        var strAuthToken:String = ""
        
//        strAuthToken = (UserBo.shared != nil) ?  UserBo.shared.auth_token ?? APPData.Auth_TOKEN_FIRST_TIME : APPData.Auth_TOKEN_FIRST_TIME
        return strAuthToken
    }
    
    func getRefreshToken() -> String! {
        var strRefreshToken:String = ""
        strRefreshToken =  APPData.REFRESH_TOKEN_FIRST_TIME
      
        return strRefreshToken
    }
    
    func body(dictParam:[String:Any]) -> Data {
        var data = Data()
        do {
            data = try JSONSerialization.data(withJSONObject: dictParam, options: [])
        }catch{
            
        }
        return data
    }
    
    private func formattedRequest(url: String, method: HTTPMethod, headers: [String: String], body: Data?) -> URLRequest {
        //let encodedUrl = url.addingPercentEncodingForURLQueryValue()
        var request = URLRequest(url: URL(string: url)!)
        if method == .get {
            let urlComp = NSURLComponents(string: url)!

                var items = [URLQueryItem]()
            do {
                // make sure this JSON is in the format we expect
                if let json = try JSONSerialization.jsonObject(with: body!, options: []) as? [String: Any] {
                    
                    for (key,value) in json {
                        items.append(URLQueryItem(name: key, value: value as? String))
                    }

                    items = items.filter{!$0.name.isEmpty}

                    if !items.isEmpty {
                      urlComp.queryItems = items
                    }
                    
                    request = URLRequest(url: urlComp.url!)
                    request.httpMethod = method.rawValue
                    
                    for (key, value) in headers {
                        request.setValue(value, forHTTPHeaderField: key)
                    }
                    
//                    request.httpBody = body
                    self.debugPrint(url: url, method: method, headers: headers, body: body)
                    
                    return request
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            return request
        } else {
            request.httpMethod = method.rawValue
            
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
            
            
            request.httpBody = body
            self.debugPrint(url: url, method: method, headers: headers, body: body)
            
            return request
        }
        
    }
    
    private func debugPrint(url: String, method: HTTPMethod, headers: [String: String], body: Data?) {
        // swiftlint:disable:next force_try
        let data = try! JSONSerialization.data(withJSONObject: headers)
        let jsonHeaders = String(data: data, encoding: .utf8)!
        let bodyJSON = String(data: body ?? Data(), encoding: .utf8)!
        //        let datanew = try! JSONSerialization.jsonObject(with: body!, options: [])
        print("\n\n\n\n\(url)\n\(method.rawValue)\n\nHEADERS\n\(jsonHeaders)\n\nBODY\n\(bodyJSON)\n\n\n\n")
    }
    
    private func debugResponsePrint(url: String, method: HTTPMethod, headers: Any, body: Data?) {
        //        let data = try! JSONSerialization.data(withJSONObject: headers)
        //        let jsonHeaders = String(data: data, encoding: .utf8)!
        let bodyJSON = String(data: body ?? Data(), encoding: .utf8)!
        if bodyJSON != "" {
            do {
                let dictionary = try JSONSerialization.jsonObject(with: body!)
                if(dictionary is [String:Any]) {
                    let dict = dictionary as? Dictionary<String,Any> //["data":dictionary]
                    
                    if dict!["code"] as? Int == 401 {
//                        APPData.appDelegate.isTokenError = true
                    } else {
//                        APPData.appDelegate.isTokenError = false
                    }
                } }
            catch {
            }
        }
        
        
        //print("\n \n response \nHEADERS\n\(headers)\n\nBODY\n\(bodyJSON)\n\n\n\n")
    }
    
    private func validate(response: URLResponse?, with error: Error?, optionallyRetry request: URLRequest, authHandler: OAuth2Handler, useRefreshToken: Bool, method: HTTPMethod, url: String, body: Data?, responseData: Data?, completion: @escaping APICompletion) -> Bool {
        // swiftlint:disable:next force_cast
        if (error != nil) || (response == nil) || (response != nil && (response is HTTPURLResponse) && !self.acceptableStatusCodes.contains((response as! HTTPURLResponse).statusCode)) {
            
            self.activeRetriers.append(authHandler)
            authHandler.shouldRetry(request: request, response: response, completion: { (shouldRetry, delay) in
                
                if shouldRetry {
                    self.apiCallQueue.asyncAfter(deadline: .now() + delay) {
                        self.request(useRefreshToken: useRefreshToken, method: method, url: url, body: body, completion: completion)
                    }
                }
                else {
                    guard responseData != nil  else {return}
                    do {
                        let dictionary = try JSONSerialization.jsonObject(with: responseData!)
                        if(dictionary is [String:Any]) {
                            let dict = dictionary as? Dictionary<String,Any> //["data":dictionary]
                            // swiftlint:disable:next force_cast
                            
                            if dict!["code"] as? Int == 403 {
                                DispatchQueue.main.async {
                                    let message = dict!["message"] as? String
                                    if UserDefaults.standard.object(forKey: "isLogin") != nil{
                                        if (UserDefaults.standard.bool(forKey: "isLogin") == true){
                                            
                                            let objnavigation = (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)
                                            let topVC = objnavigation?.visibleViewController as? UITabBarController
                                            if topVC == nil {
                                                let topVC = objnavigation?.visibleViewController as? BaseViewController
                                                topVC?.hideSpinner()
                                                topVC?.view.isUserInteractionEnabled = true
                                                topVC?.showAlertOKHandler(message: message!, completion: nil)
                                            } else {
                                                let objVC = (topVC?.selectedViewController as? UINavigationController)?.visibleViewController as? BaseViewController
                                                objVC?.hideSpinner()
                                                objVC?.view.isUserInteractionEnabled = true
                                                objVC?.showAlertOKHandler(message: message!, completion: nil)
                                            }
                                            
                                        }else {
                                            
                                            let objnavigation = (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)
                                            let topVC = objnavigation?.visibleViewController as? BaseViewController
                                            topVC?.hideSpinner()
                                            topVC?.view.isUserInteractionEnabled = true
                                            topVC?.showAlertOKHandler(message: message!, completion: nil)
                                        }
                                    }else{
                                        let objnavigation = (UIApplication.shared.keyWindow?.rootViewController as? UINavigationController)
                                        let topVC = objnavigation?.visibleViewController as? BaseViewController
                                        topVC?.hideSpinner()
                                        topVC?.view.isUserInteractionEnabled = true
                                        topVC?.showAlertOKHandler(message: message!, completion: nil)
                                    }
                                }
                            }else{
                                DispatchQueue.main.async { completion((dict), nil) }
                            }
                        } }
                    catch {
                        DispatchQueue.main.async { completion(nil, error) }
                    }
                }
                
                if let index = self.activeRetriers.firstIndex(where: { $0 === authHandler }) {
                    self.activeRetriers.remove(at: index)
                }
            })
            return false
        }
        return true
    }
    
    //MARK:- Images API Call
    public func requestWithImageWithKeys(useRefreshToken: Bool = true, method: HTTPMethod, url: String, body: Data?,imgImage: [[String:Data?]],attachmentKey : String, completion: @escaping APICompletion,dictData : Dictionary<String,Any>) -> URLSessionTask {
        
        
        let authHandler = OAuth2Handler(accessToken:  "",
                                        refreshToken: "")
        authHandler.useRefreshToken = useRefreshToken
        
        let headers = self.headersForImage()
        var request = self.formattedRequestWithImageFormDataWithKeys(url: url, method: method, headers: headers, body: body, dictData: dictData, imageData: imgImage, attachmentKey: attachmentKey)
        print(request.httpBody as Any)
        request.timeoutInterval = 1000
        self.debugPrint(url: url, method: method, headers: headers, body: body)
        
        let task = self.session.dataTask(with: request, completionHandler: { (data, response, error) in
            //print(response)
            self.debugResponsePrint(url: url, method: method, headers: response as Any, body: data)
            self.apiCallQueue.async {
                guard self.validateImageWithKeys(response: response, with: error, optionallyRetry: request, authHandler: authHandler, useRefreshToken: useRefreshToken, method: method, url: url, body: body, imageData: imgImage, attachmentKey: attachmentKey, dictData: dictData, completion: completion) else {
                    
                    return
                }
                do {
                    let backToString = String(data: data!, encoding: String.Encoding.utf8) as String?
                    print("string:",backToString as Any)
                    let dictionary = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                    DispatchQueue.main.async { completion(dictionary, nil) }
                }
                catch {
                    DispatchQueue.main.async { completion(nil, error) }
                }
            }
        })
//        if #available(iOS 11.0, *) {
//            observation = task.progress.observe(\.fractionCompleted) { progress, _ in
//                let dictionary = ["ProgressVal" : progress.fractionCompleted]
//                DispatchQueue.main.async { progresses(dictionary, nil) }
//            }
//        } else {
//            // Fallback on earlier versions
//        }
        task.resume()
        return task
        
    }
    
   private func validateImageWithKeys(response: URLResponse?, with error: Error?, optionallyRetry request: URLRequest, authHandler: OAuth2Handler, useRefreshToken: Bool, method: HTTPMethod, url: String, body: Data?,imageData : [[String : Data?]],attachmentKey : String,dictData : Dictionary<String,Any>, completion: @escaping APICompletion) -> Bool {
        
        if (error != nil) || (response == nil) || (response != nil && (response is HTTPURLResponse) && !self.acceptableStatusCodes.contains((response as! HTTPURLResponse).statusCode)) {
            
            self.activeRetriers.append(authHandler)
            authHandler.shouldRetry(request: request, response: response, completion: { (shouldRetry, delay) in
                
                if shouldRetry {
                    self.apiCallQueue.asyncAfter(deadline: .now() + delay) {
                        if imageData.count > 0{
                            let _ = self.requestWithImageWithKeys(method: method, url: url, body: body, imgImage: imageData, attachmentKey: attachmentKey, completion: completion, dictData: dictData)
                        }else{
                            self.request(useRefreshToken: useRefreshToken, method: method, url: url, body: body, completion: completion)
                        }
                    }
                }
                else {
                    DispatchQueue.main.async { completion(nil, error) }
                }
                
                if let index = self.activeRetriers.firstIndex(where: { $0 === authHandler }) {
                    self.activeRetriers.remove(at: index)
                }
            })
            
            return false
        }
        return true
    }
    
    private func formattedRequestWithImageFormDataWithKeys(url: String, method: HTTPMethod, headers: [String: String], body: Data?,dictData : Dictionary<String,Any>,imageData: [[String:Data?]],attachmentKey : String) -> URLRequest {
        let _: NSMutableData = NSMutableData()
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method.rawValue
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let boundry:NSString="---------------------------14737809831466499882746641449"
        let contentType:NSString=NSString(format: "multipart/form-data; boundary=%@", boundry)
        for (key, value) in headers {
            if key == "Content-Type" {
                request .setValue(contentType as String, forHTTPHeaderField: "Content-Type")
            }else{
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let boundry1:String = "---------------------------14737809831466499882746641449"
        let data = createBodyWithKeys(withBoundary: boundry1, parameters: dictData, paths: imageData)
        //        let backToString = String(decoding: data, as: UTF8.self)
        
        request.httpBody=data
        request.timeoutInterval = 1000
        request.httpBody = data
        
        return request
    }
    
    func createBodyWithKeys(withBoundary boundary: String, parameters: [String: Any]?, paths: [[String:Data?]]) -> Data {
        var httpBody = Data()
        
        // add params (all params are strings)
        
        if let parameters1 = parameters {
            for (parameterKey, parameterValue) in parameters1 {
                httpBody.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                httpBody.append("Content-Disposition: form-data; name=\"\(parameterKey)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
                httpBody.append("\(parameterValue)\r\n".data(using: String.Encoding.utf8)!)
            }
        }
        
        // add File data
        
        var dataNew = Data()
        for (index,datanew) in (paths.enumerated()) {
            
            dataNew.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
            let key = datanew.keys.first ?? ""
            if let _ = datanew[key] as? Data{
                
            }else{
                break
            }
            
            let arr = key.split(separator: "#")
            if arr.count >= 2{
                dataNew.append("Content-Disposition: form-data; name=\"\(String(describing: arr.first ?? ""))\"; filename=\"temp\(index).\(arr.last ?? "")\"\r\n".data(using: String.Encoding.utf8)!)
                dataNew.append("Content-Type: application/octet-stream\r\n\r\n".data(using: String.Encoding.utf8)!)
            }else{
                if key == "video_post" {
                    dataNew.append("Content-Disposition: form-data; name=\"\(String(describing: key))\"; filename=\"temp\(index).mp4\"\r\n".data(using: String.Encoding.utf8)!)
                } else if key == "video_thumb" {
                    dataNew.append("Content-Disposition: form-data; name=\"\(String(describing: key))\"; filename=\"temp\(index).gif\"\r\n".data(using: String.Encoding.utf8)!)
                } else{
                    dataNew.append("Content-Disposition: form-data; name=\"\(String(describing: key))\"; filename=\"temp\(index).jpg\"\r\n".data(using: String.Encoding.utf8)!)
                }
                dataNew.append("Content-Type: application/octet-stream\r\n\r\n".data(using: String.Encoding.utf8)!)
            }
            if let data = datanew[key] as? Data{
                dataNew.append(data)
                dataNew.append("\r\n".data(using: String.Encoding.utf8)!)
            }
        }
        httpBody.append(dataNew)
        httpBody.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        return httpBody
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}






