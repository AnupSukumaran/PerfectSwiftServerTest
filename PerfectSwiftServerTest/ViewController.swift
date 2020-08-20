//
//  ViewController.swift
//  PerfectSwiftServerTest
//
//  Created by Sukumar Anup Sukumaran on 20/08/20.
//  Copyright © 2020 Tech_Tonic. All rights reserved.
//

import UIKit
import Alamofire
import APILib

class ViewController: UIViewController {
    
    @IBOutlet weak var operandTwoField: UITextField!
    @IBOutlet weak var operandOneField: UITextField!
    @IBOutlet weak var sumField: UITextField!
    
    private let endPoint = "http://localhost:8181/add"
    private let urlSession = URLSession.shared
    
    typealias BaseAPI = (scheme: String, host: String, path: String)
    typealias Header = (headerVal: String, headerKey: String)
    var apiComponent: BaseAPI = (scheme: .scheme, host: .host, path: .path)
    public let contentType: Header = (headerVal: .kContentType, headerKey: .vAppJson)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func add(_ sender: UIButton) {
        
        guard let numberOneText = operandOneField.text, let numberTwoText = operandTwoField.text else {return}
        
        if let numberOne = Int(numberOneText), let numberTwo = Int(numberTwoText) {
            addNumber(numberOne: numberOne, numberTwo: numberTwo)
        }
        
    }
    
    private func addNumber(numberOne: Int, numberTwo: Int) {
        let parameters = ["operandOne": numberOne, "operandTwo": numberTwo]
        
        
        APILib.portNum = 8181
        let newReq = APILib.makeRequest(method: .post, params: parameters, withHeaders: [contentType], apiComponents: apiComponent)
        
        print("newReq-URL = \(newReq.url?.absoluteString)")
        
        guard let urlToExecute = URL(string: endPoint) else {return}
        
        var webRequest = URLRequest(url: urlToExecute)
        webRequest.httpMethod = "POST"
        //webRequest.addValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        webRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let urlParams = parameters.compactMap { (key, value) in
            
            "\(key)=\(value)"
        }.joined(separator: "&")
        
        webRequest.httpBody = urlParams.data(using: .utf8, allowLossyConversion: true)
        
        //callRequest(req: webRequest)
        
       // dataSetter(webRequest)
        dataSetter(newReq)
    }
    
    func callRequest(req: URLRequest) {
        let dataTask = urlSession.dataTask(with: req) { (data, response, error) in
            print("response received from server")
            guard let data = data, let res = response, error == nil else {
                print("error = \(error!.localizedDescription)")
                return
                
            }
            print("res = \(res)")
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                print("jsonResponse = \(jsonResponse)")
                
                guard let sum = jsonResponse?["sum"] as? Int else {return}
                
                DispatchQueue.main.async { [unowned self] in
                    self.sumField.text = String(sum)
                }
                       
            } catch let error {
                print("Error = \(error.localizedDescription)")
            }
           
        }
        dataTask.resume()

    }
    

    func dataSetter( _ req: URLRequest) {
       
       AF.request(req).validate().responseJSON { (response) in
           
           guard let statusCode = response.response?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("error = \(response.error!.localizedDescription)")
              return
           }
           
           guard let data = response.data else { return }
           
           do {
            
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                print("jsonResponse = \(jsonResponse)")
                
                guard let sum = jsonResponse?["sum"] as? Int else {return}
                self.sumField.text = String(sum)
           } catch (let error) {
               print("Error = \(error.localizedDescription)")
           }
           
       }
    }
}

