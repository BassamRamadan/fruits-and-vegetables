//
//  contactUs.swift
//  mazayaApp
//
//  Created by Bassam Ramadan on 11/29/20.
//  Copyright © 2020 Bassam Ramadan. All rights reserved.
//

import UIKit

class ContactUs: common{
    @IBOutlet var userName: UITextField!
    @IBOutlet var userPhone: UITextField!
    @IBOutlet var userBody: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        userName.delegate = self
        userPhone.delegate = self
        userBody.delegate = self
        userName.text = CashedData.getUserName() ?? ""
        userPhone.text = CashedData.getUserPhone() ?? ""
        setModules(userName)
        setModules(userPhone)
        setModules(userBody)
    }
    fileprivate func setModules(_ textField : UIView){
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1.0
    }
    @IBAction func close(){
       super.dismiss(animated: true)
    }
    @IBAction func AlamofireUpload(sender: UIButton){
        self.loading()
        let url = AppDelegate.LocalUrl + "contact-us"
        let headers = ["Content-Type": "application/json" ,
                       "Accept" : "application/json",
                       "Authorization": "Bearer \(CashedData.getUserApiKey() ?? "")"
        ]
        let parameters = [
            "name": userName.text!,
            "phone": userPhone.text!,
            "message": userBody.text!
        ]
        AlamofireRequests.PostMethod(methodType: "POST", url: url, info: parameters, headers: headers) {
            (error, success , jsonData) in
            do {
                let decoder = JSONDecoder()
                if error == nil{
                    if success{
                        self.userBody.text = ""
                        let alert = common.makeAlert( message: "تم الارسال بنجاح")
                        self.present(alert, animated: true, completion: nil)
                    }
                    else{
                        let dataRecived = try decoder.decode(ErrorHandle.self, from: jsonData)
                        let alert = common.makeAlert(message: dataRecived.message ?? "")
                        self.present(alert, animated: true, completion: nil)
                    }
                    self.stopAnimating()
                }else{
                    let dataRecived = try decoder.decode(ErrorHandle.self, from: jsonData)
                    self.present(common.makeAlert(message: dataRecived.message ?? ""), animated: true, completion: nil)
                    self.stopAnimating()
                }
            } catch {
                let alert = common.makeAlert()
                self.present(alert, animated: true, completion: nil)
                self.stopAnimating()
            }
        }
    }
    
}
extension ContactUs : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.border()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.removeTextFieldBorder()
    }
}
extension ContactUs: UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.border()
        if textView.text == "الرسالة"{
            textView.text = ""
        }
        return true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.removeTextFieldBorder()
    }
}
