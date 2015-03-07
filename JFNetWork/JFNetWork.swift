//
//  JFNetWork.swift
//  新浪微博
//
//  Created by mac on 15/3/6.
//  Copyright (c) 2015年 mac. All rights reserved.
//

import UIKit

///  定义一个方法枚举
public enum HTTPMethod : String {
    case GET = "GET"
    case POST = "POST"
}

public class JFNetWork: NSObject {
    
    //定义一个错误
  let errorDomain = "com.XXX.error"
    
// 定义一个闭包，完成网路请求后的回调
    public typealias Complection = (result:AnyObject?,error:NSError?)->()
   
///  网络访问的主函数
   public func requestData(method:HTTPMethod,_ urlstr :String,_ parmars : [String :String]?, complection:Complection ){
        
        //获得网络请求有
        if let request = request(method, urlstr, parmars){
           //加载网络请求
            session!.dataTaskWithRequest(request, completionHandler: { (data, _, error) -> Void in
                //如果有错误
                if error != nil{
                    complection(result: nil,error: error)
                    return
                }
                //加载成功,反序列化
                let data: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil)
                
                if data == nil{
                    let eror = NSError(domain:self.errorDomain, code: -2, userInfo: ["error":"反序列化失败"])
                    complection(result: nil, error: eror)
                }
                //在主线程返回下载结果
                complection(result: data, error: nil)
                
            }).resume()
            return
        }
        let error = NSError(domain: self.errorDomain, code: -3, userInfo: ["error":"没有从网络上下载到数据"])
        
        complection(result: nil, error: error)
        
        
    }
    
   
    
    
    
    
    ///  返回网络请求
    ///
    ///  :param: method  请求方法
    ///  :param: urlstr  请求路径
    ///  :param: parmars 请求参数
    
   public func request(method:HTTPMethod,_ urlstr :String,_ parmars : [String :String]?) -> NSURLRequest?{
        //判断请求路径是否为空
        if urlstr.isEmpty{
            return nil;
        }
        //讲传进来得路径变成可变的，因为要凭借路径
        var url = urlstr
        //请求
        var req: NSMutableURLRequest?
        
        //返回一个将参数拼接好的字符串
        let query = appendUrlParmar(parmars)
        
        //判断事用什么方法发送的请求
        if method == HTTPMethod.GET{
         
            //如果有参数
            if query != nil{
                //将参数拼接好
                url += "?" + query!
            }
            req = NSMutableURLRequest(URL: NSURL(string: url)!)
        }else{
            //这是POST方法
            req = NSMutableURLRequest(URL: NSURL(string: url)!)
            //设置请求方法
            req?.HTTPMethod = method.rawValue
            //请求提
            req?.HTTPBody = query?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)

        }
        
        return req
    }
    
    
    
    ///  返回一个拼接好得参数
    ///
    ///  :param: parmar 参数
    ///
    ///  :returns: 将参数拼接好，直接拼到路径上面
    func appendUrlParmar(parmar :[String :String]?) ->String?{
        //定义一个存放要拼接的字符串的数组
        var array = [String]()
        if parmar != nil  {
            //便利惨数数组，将他们拼接起来
            for (k,v) in parmar!{
                let str = k + "=" + v.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                //将他们加到临时数组中
                array.append(str)
                
            }
            //将数组中得内容用&分割开，并以字符串形式输出
            return join("&", array)
        }else{
            return nil
        }
        
        
    }
    
    //懒加载一个session
     lazy var session :NSURLSession? = {
        return NSURLSession.sharedSession()
    }()
}
