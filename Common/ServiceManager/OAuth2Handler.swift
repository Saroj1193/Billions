//
//  OAuth2Handler.swift
//
//  Created by Tristate Technology on 15/05/19.
//  Copyright © 2019 Tristate Technology. All rights reserved.
//

import UIKit

public class OAuth2Handler {
    
    /* h*/
    private typealias RefreshCompletion = (_ succeeded: Bool, _ accessToken: String?, _ refreshToken: String?) -> Void
    
    private let lock = NSLock()
    
    private var accessToken: String
    private var refreshToken: String
    
    private var isRefreshing = false
    
    public var useRefreshToken: Bool = true
    public var retryBlocks: [APIRetryBlock] = []
    
    
    // MARK: - Initialization
    public init(accessToken: String, refreshToken: String) {
        
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    /* h*/
    
    // MARK: - APIRetrier Methods
    public func shouldRetry(request: URLRequest, response: URLResponse?, completion: @escaping APIRetryBlock) {
        lock.lock()
        defer { lock.unlock() }
        
        if let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 401 {
            retryBlocks.append(completion)
            
            if !isRefreshing {
                self.refreshTokens(completion: { [weak self] succeeded, accessToken, refreshToken in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.lock.lock()
                    defer { strongSelf.lock.unlock() }
                    
                    if let accessToken = accessToken, let refreshToken = refreshToken {
                        strongSelf.accessToken = accessToken
                        strongSelf.refreshToken = refreshToken
                    }
                    
                    strongSelf.retryBlocks.forEach { $0(succeeded, 0.0) }
                    strongSelf.retryBlocks.removeAll()
                })
            }
        } else {
            completion(false, 0.0)
        }
    }
    
    
    // MARK: - Private - Refresh Tokens
    private func refreshTokens(completion: @escaping RefreshCompletion) {
        guard !isRefreshing else { return }
        isRefreshing = true
        
        let dictParam : [String:Any] = [String:Any]()
        
        let urlString = APIActionName.SERVICE_URL + APIActionName.refresh_Token
        let headers = API.shared.headerForRefreshToken()
        let data = API.shared.body(dictParam: dictParam)
        API.shared.unqualifiedRequest(url: urlString, method: .post, headers: headers, body: data, completion: { [weak self] (response, error) in
            
            guard let strongSelf = self, let res = response  else { return }
            debugPrint(res)
            
            if(res["code"] as? Int == 1)
            {
                // swiftlint:disable:next force_cast
                let dictData = res["data"] as? Dictionary<String,Any> ?? [:]
                // swiftlint:disable:next force_cast
                let strAuthToken = dictData["new_token"] as! String
                // swiftlint:disable:next force_cast
//                UserBo.shared.refresh_token = APPData.REFRESH_TOKEN_FIRST_TIME
//                UserBo.shared.auth_token = strAuthToken
//                userInfoManager.setUserInfo(userInfoModel: UserBo.shared)
                completion(true,strAuthToken,nil)
            }else{
                completion(false,nil,nil)
            }
            strongSelf.isRefreshing = false
        })
    }
}


