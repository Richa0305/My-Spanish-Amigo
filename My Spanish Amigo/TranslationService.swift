//
//  TranslationService.swift
//  My Spanish Amigo
//
//  Created by Srivastava, Richa on 04/06/17.
//  Copyright © 2017 ShivHari Apps. All rights reserved.
//

import UIKit

class TranslationService: NSObject {
    
    
    
    func getTranslatedText(apiKey:String,text:String,from:String,to:String,completionHandler:@escaping (Bool,String) -> ()){
        var translatedText:String = ""
        var token:String = ""
        let request = NSMutableURLRequest(url: URL(string: "https://api.cognitive.microsoft.com/sts/v1.0/issueToken?" )!)
        request.setValue(apiKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.httpMethod = "POST"
        request.httpBody = "{body}".data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            
            if error != nil {
                print("error=\(error)")
                completionHandler(false,"")
                return
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            // Should validate the token...
            if self.validateToken(token: responseString as! String)==false {
                print("error=\(responseString)")
                completionHandler(false,"")
                return
            }
            
            defer {
               print("Token \(responseString)")
                token = responseString as! String
                self.TranslateText(token: token, text: text,from: from,to: to, completionHandler: { (success, response) in
                    
                    completionHandler(true,response)
                    
                })
                //self.TranslateText(token: token, text: "How is life?")
            }
        }
        task.resume()
    
    }
    

    func TranslateText(token:String,text:String,from:String,to:String,completionHandler:@escaping (Bool,String) -> ())
    {
        var translatedText = ""
        let originalString = text
        let escapedString = originalString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)

        
        let url:URL = URL(string: "https://api.microsofttranslator.com/V2/Http.svc/Translate?text=\(escapedString!)&from=\(from)&to=\(to)")!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.setValue("Bearer " + (token as String), forHTTPHeaderField: "Authorization")
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            data, response, error) in
            
            guard let data = data, let _:URLResponse = response, error == nil else {
                print("error \(error)")
                completionHandler(false,"")
                return
            }
            
            let dataString =  String(data: data, encoding: String.Encoding.utf8)
            print(dataString ?? "No val")
            translatedText = dataString!
            completionHandler(true,translatedText)
        }
        
        task.resume()
    
    }
    
    func validateToken(token:String) -> Bool {
        let components = token.components(separatedBy: ".")
        if components.count != 3 {
            return false
        }
        if token.hasPrefix("{") {
            return false
        }
        // More validation required to check expiration time...
        
        // skiping it
        return true
    }
    


}
