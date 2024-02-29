//
//  String+Extension.swift
//  
//
//  Created by Tristate on 11/18/19.
//  Copyright © 2019 Tristate. All rights reserved.
//

import UIKit
import Foundation
import PhotosUI

extension URL {

    func saveVideo( success:@escaping (Bool,URL?)->()){


        URLSession.shared.downloadTask(with: URLRequest(url: self)) { (url, response, error) in

            let mgr = FileManager.default

            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]


            let destination = URL(fileURLWithPath: String(format: "%@/%@", documentsPath, "video.mp4"))


            try? mgr.moveItem(atPath: (url?.path)!, toPath: destination.path)

            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destination)
            }) { completed, error in
                if completed {
                    print("Video is saved!")
                    success(true,destination)
                }
                if error != nil{
                    success(false,nil)
                }
            }
        }.resume()
    }
}

extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
extension String {
    
//    var MD5: String? {
//        let length = Int(CC_MD5_DIGEST_LENGTH)
//        guard let data = self.data(using: String.Encoding.utf8) else { return nil }
//        
//        let hash = data.withUnsafeBytes { (bytes: UnsafePointer<Data>) -> [UInt8] in
//            var hash: [UInt8] = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
//            CC_MD5(bytes, CC_LONG(data.count), &hash)
//            return hash
//        }
//        
//        return (0..<length).map { String(format: "%02x", hash[$0]) }.joined()
//    }
    
    var length: Int {
        return self.count
    }
    
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func addingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
    
    func substring(_ from: Int) -> String {
        let index = self.index(self.startIndex, offsetBy: from)
        return String(self[..<index])
    }
    
    // LEFT
    // Returns the specified number of chars from the left of the string
    // let str = "Hello"
    // print(str.left(3))         // Hel
    func left(_ to: Int) -> String {
        return "\(self[..<self.index(startIndex, offsetBy: to)])"
    }
    
    // RIGHT
    // Returns the specified number of chars from the right of the string
    // let str = "Hello"
    // print(str.right(3))         // llo
    func right(_ from: Int) -> String {
        return "\(self[self.index(startIndex, offsetBy: self.length-from)...])"
    }
    
    // MID
    // Returns the specified number of chars from the startpoint of the string
    // let str = "Hello"
    // print(str.left(2,amount: 2))         // ll
    func mid(_ from: Int, amount: Int) -> String {
        let x = "\(self[self.index(startIndex, offsetBy: from)...])"
        return x.left(amount)
    }
}

extension StringProtocol where Index == String.Index {
    func nsRange(from range: Range<Index>) -> NSRange {
        return NSRange(range, in: self)
    }
}

extension String {
    
    func strstr(needle: String, beforeNeedle: Bool = false) -> String? {
        guard let range = self.range(of: needle) else { return nil }
        
        if beforeNeedle {
            return String(self[..<range.lowerBound]) //return self.substring(to: range.lowerBound)
        }
        
        return String(self[range.upperBound...]) //return self.substring(from: range.upperBound)
    }
    
    func isNumber() -> Bool {
        let numberCharacters = CharacterSet.decimalDigits.inverted
        return !self.isEmpty && self.rangeOfCharacter(from: numberCharacters) == nil
    }
    
}

//https://stackoverflow.com/questions/45562662/how-can-i-use-string-slicing-subscripts-in-swift-4

//'substring(to:)' is deprecated: Please use String slicing subscript with a 'partial range upto' operator.
//'substring(from:)' is deprecated: Please use String slicing subscript with a 'partial range from' operator.
//let finalStr = String(testStr[..<index]) // Swift 4 testStr.substring(to: index) //Swift 3
//let finalStr = String(testStr[index...]) // Swift 4 testStr.substring(from: index) //Swift3


//Swift 3
//let finalStr = testStr.substring(from: index(startIndex, offsetBy: 3))

//Swift 4
//let reqIndex = testStr.index(testStr.startIndex, offsetBy: 3)
//let finalStr = String(testStr[..<reqIndex])

extension String {
    
    
    
    var characters : String{
        return components(separatedBy: CharacterSet.letters.inverted)
            .joined()
    }
    
    func nsRange(from range: Range<Index>) -> NSRange {
        return NSRange(range, in: self)
    }
    
    
    /// <#Description#>
    ///
    /// - Parameter aClass: <#aClass description#>
    /// - Returns: <#return value description#>
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - height: <#height description#>
    ///   - font: <#font description#>
    /// - Returns: <#return value description#>
    func widthWithConstrainedHeight(_ height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)
        
        return boundingBox.width
    }
    
    /// <#Description#>
    ///
    /// - Parameter findStr: <#findStr description#>
    /// - Returns: <#return value description#>
    func rangesOfString(findStr: String) -> [Range<String.Index>] {
        var arr = [Range<String.Index>]()
        var startInd = self.startIndex
        // check first that the first character of search string exists
        if self.characters.contains(findStr.first!) {
            // if so set this as the place to start searching
            startInd = self.index(of:findStr.first!)!
        } else {
            // if not return empty array
            return arr
        }
        var i = self.distance(from:startIndex, to: startInd)
        while i<=self.count-findStr.count {
            if self[self.index(startIndex,
                               offsetBy:i)..<self.index(startIndex,
                                                        offsetBy: i+findStr.count)] == findStr {
                arr.append(self.index(startIndex,
                                      offsetBy:i)..<self.index(startIndex,
                                                               offsetBy:i+findStr.count))
                i += findStr.count
            } else {
                i += 1
            }
        }
        return arr
    }
    
    /// Validates a string to see if it's a valid password
    /// Passwords contains at least one lower case letter, one upper case letter, one number and one special character
    ///
    /// - Returns: if the pasword is valid or not
    func validateAsPassword() -> Bool {
        var lowerCaseLetter: Bool = false
        var upperCaseLetters: Bool = false
        var decimalDigit: Bool = false
        var specialCharacters: Bool = false
        
        for i in 0 ... (self.length) - 1 {
            let c = NSString(string: self).character(at: i)
            NSLog("\(c)")
            
            if !lowerCaseLetter {
                lowerCaseLetter = NSCharacterSet.lowercaseLetters.contains(UnicodeScalar(c)!)
            }
            
            if !upperCaseLetters {
                upperCaseLetters = NSCharacterSet.uppercaseLetters.contains(UnicodeScalar(c)!)
            }
            
            if !decimalDigit {
                decimalDigit = NSCharacterSet.decimalDigits.contains(UnicodeScalar(c)!)
            }
            
            if !specialCharacters {
                specialCharacters = !NSCharacterSet.alphanumerics.contains(UnicodeScalar(c)!)
            }
        }
        
        if lowerCaseLetter && upperCaseLetters && decimalDigit && specialCharacters{
            return true
        }
        return false
    }
    
    // https://www.cocoanetics.com/2014/06/e-mail-validation/
    func isValidEmail() -> Bool {
        
        if self.isEmpty {
            return false
        }
        
        let entireRange = NSMakeRange(0, self.count)
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: self, range: entireRange)
        
        // should only a single match
        if matches.count != 1 {
            return false
        }
        
        let result = matches[0]
        
        // result should be a link
        if result.resultType != NSTextCheckingResult.CheckingType.link {
            return false
        }
        
        // result should be a recognized mail address
        guard let url = result.url, url.scheme == "mailto" else {
            return false
        }
        
        // match must be entire string
        if !NSEqualRanges(result.range, entireRange) {
            return false
        }
        
        // but should not have the mail URL scheme
        if self.hasPrefix("mailto:") {
            return false
        }
        
        // no complaints, string is valid email address
        return true
    }
    
    
    func validateAge() -> Bool {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateDOB = df.date(from: self) ?? Date()
        let year = Calendar.current.dateComponents([.day,.month, .year], from: dateDOB, to: Date()).year ?? 0
        let month = Calendar.current.dateComponents([.day,.month, .year], from: dateDOB, to: Date()).month ?? 0
        let day = Calendar.current.dateComponents([.day,.month, .year], from: dateDOB, to: Date()).day ?? 0
        if year > 17 || (year == 17 && (month > 0 || day > 0)){
            return true
        } else {
            return false
        }
    }
  
    
}



/// <#Description#>
extension NSString {
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - height: <#height description#>
    ///   - font: <#font description#>
    /// - Returns: <#return value description#>
    func getLabelWidthFrom(height: CGFloat, font: UIFont) -> CGFloat {
        let size = CGSize(width: 99999, height: height)
        let rect = self.boundingRect(with: size,
                                     options: .usesLineFragmentOrigin,
                                     attributes: [NSAttributedString.Key.font: font],
                                     context: nil)
        return rect.size.width
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - width: <#width description#>
    ///   - font: <#font description#>
    /// - Returns: <#return value description#>
    func getLabelHeightFrom(width: CGFloat, font: UIFont) -> CGFloat {
        let size = CGSize(width: width, height: 99999)
        let rect = self.boundingRect(with: size,
                                     options: .usesLineFragmentOrigin,
                                     attributes: [NSAttributedString.Key.font: font],
                                     context: nil)
        return rect.size.height
    }
}

extension String {
    func documentsDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory: String = paths[0]
        return documentsDirectory
    }
    
    func cacheDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let documentsDirectory: String = paths[0]
        return documentsDirectory
    }
    
    func privateDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        var documentsDirectory: String = paths[0]
        documentsDirectory = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("Private Documents").absoluteString
        var error: Error?
        try? FileManager.default.createDirectory(atPath: documentsDirectory, withIntermediateDirectories: true, attributes: nil)
        return documentsDirectory
    }
    
    func pathInDocumentDirectory() -> String {
        let documentsDirectory: String = documentsDirectoryPath()
        let path: String = URL(fileURLWithPath: documentsDirectory).appendingPathComponent(self).absoluteString
        return path
    }
    
    func pathInCacheDirectory() -> String {
        let documentsDirectory: String = cacheDirectoryPath()
        let path: String = URL(fileURLWithPath: documentsDirectory).appendingPathComponent(self).absoluteString
        return path
    }
    
    func pathInPrivateDirectory() -> String {
        let documentsDirectory: String = privateDirectoryPath()
        let path: String = URL(fileURLWithPath: documentsDirectory).appendingPathComponent(self).absoluteString
        return path
    }
    
    func path(inDirectory dir: String, cachedData yesOrNo: Bool) -> String {
        var documentsDirectory: String? = nil
        if yesOrNo {
            documentsDirectory = cacheDirectoryPath()
        }
        else {
            documentsDirectory = documentsDirectoryPath()
        }
        let dirPath: String? = documentsDirectory! + (dir)
        let path: String? = dirPath! + (self)
        let manager = FileManager.default
        try? manager.createDirectory(atPath: dirPath!, withIntermediateDirectories: true, attributes: nil)
        return path ?? ""
    }
    
    func path(inDirectory dir: String) -> String {
        return path(inDirectory: dir, cachedData: true)
    }
    
    func removeWhiteSpace() -> String {
        return trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func stringByNormalizingCharacter(in characterSet: CharacterSet, with replacement: String) -> String {
        var result = ""
        let scanner = Scanner(string: self)
        while !scanner.isAtEnd {
            if scanner.scanCharacters(from: characterSet, into: nil) {
                result += replacement
            }
            let stringPart: String? = nil
            if scanner.scanUpToCharacters(from: characterSet, into: stringPart as? AutoreleasingUnsafeMutablePointer<NSString?>) {
                result += stringPart!
            }
        }
        //    return [[result copy] autorelease];
        return result.copy() as! String
    }
    
    func bindSQLCharacters() -> String {
        var bindString: String = self
        bindString = bindString.replacingOccurrences(of: "'", with: "''")
        return bindString
    }
    
    func trimSpaces() -> String {
        return trimmingCharacters(in: CharacterSet(charactersIn: "\t\n "))
    }
    
    func stringByTrimmingLeadingCharacters(in characterSet: CharacterSet) -> String {
        let rangeOfFirstWantedCharacter: NSRange = (self as NSString).rangeOfCharacter(from: characterSet.inverted)
        if rangeOfFirstWantedCharacter.location == NSNotFound {
            return ""
        }
        return (self as? NSString)?.substring(from: rangeOfFirstWantedCharacter.location) ?? ""
    }
    
    func stringByTrimmingLeadingWhitespaceAndNewlineCharacters() -> String {
        return stringByTrimmingLeadingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func stringByTrimmingTrailingCharacters(in characterSet: CharacterSet) -> String {
        let rangeOfLastWantedCharacter: NSRange = (self as NSString).rangeOfCharacter(from: characterSet.inverted, options: .backwards)
        if rangeOfLastWantedCharacter.location == NSNotFound {
            return ""
        }
        return (self as? NSString)?.substring(to: rangeOfLastWantedCharacter.location + 1) ?? ""
    }
    
    static func validateEmail(_ candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: candidate)
    }
    
    // Range must be in {a,b}. Where a is mimimum length and b is max length
    static func validate(forNumericAndCharacets candidate: String, withLengthRange strRange: String) -> Bool {
        var valid = false
        let alphaNums = CharacterSet.alphanumerics
        let inStringSet = CharacterSet(charactersIn: candidate)
        let isAlphaNumeric: Bool = alphaNums.isSuperset(of: inStringSet)
        if isAlphaNumeric {
            let emailRegex = "[\(candidate)]\(strRange)"
            let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            valid = emailTest.evaluate(with: candidate)
        }
        return valid
    }
    
    static func validatePhone(_ candidate: String) -> Bool {
        let phoneRegex = "^([+]{1})([0-9]{2,6})([-]{1})([0-9]{10})$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: candidate)
    }
    
    static func readCacheFile(_ fileName: String) -> String {
        return try! String(contentsOfFile: fileName.path(inDirectory: "/Response", cachedData: true), encoding: String.Encoding.utf8)
    }
    
    func save(asCacheFile fileName: String) {
        try? self.write(toFile: fileName.path(inDirectory: "/Response", cachedData: true), atomically: true, encoding: String.Encoding.utf8)
    }
    
    func capitalizeFirst() -> String {
        let firstIndex = self.index(startIndex, offsetBy: 1)
        return self.substring(to: firstIndex).capitalized + self.substring(from: firstIndex).lowercased()
    }
    
    func truncate(length: Int, trailing: String = "…") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        } else {
            return self
        }
    }
    
    ///Removes all HTML Tags from the string
    var removeHTMLTags: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    func heightOfText(_ width: CGFloat, font: UIFont) -> CGFloat {
        
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.height
    }
    
    func widthOfText(_ height: CGFloat, font: UIFont) -> CGFloat {
        
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.width
    }
    
    func localizedString() ->String {
        let value = UserDefaults.standard.value(forKey: "AppLanguageText") 
        let lang = value
        
        let path = Bundle.main.path(forResource: lang as! String, ofType: "lproj")
        printDebug(path)
        let bundle = Bundle(path: path!)
        printDebug(bundle)
        
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}


extension URL{
    ///Returns percent encoded url
    var percentEncoded:URL?{
        
        let urlString = self.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let urlStr = urlString, let url = URL(string:urlStr) {
            return url
        }
        return nil
    }
}

/// Print Debug
func printDebug<T>(_ obj : T) {
    #if DEBUG
        print(obj)
    #endif
}


extension String {
    func convertHeadertDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var datecheck = Date()
        
        if let date = dateFormatter.date(from: self){
            datecheck = date
        }
        if Calendar.current.isDateInToday(datecheck) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(datecheck) {
            return "Yesterday"
        } else if Calendar.current.isDateInThisWeek(datecheck) {
            dateFormatter.dateFormat = "EEEE"
        } else {
            dateFormatter.dateFormat = "dd MMM, yyyy"
        }
        return dateFormatter.string(from: datecheck)
    }
}
