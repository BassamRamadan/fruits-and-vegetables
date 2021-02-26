//
//  forgetPass.swift
//  perfume
//
//  Created by Bassam Ramadan on 5/16/20.
//  Copyright © 2020 Bassam Ramadan. All rights reserved.
//

import UIKit
class forgetPass: common{
    // MARK:- Outlets
  
    @IBOutlet var email : UITextField!
    @IBOutlet var scrollView: UIScrollView!
    var CustomNavigationBar : CustomBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        email.text = CashedData.getUserEmail() ?? ""
        setupCustomBar()
    }
    func setupCustomBar(){
        CustomNavigationBar = CustomBar.createMyClassView(view: view, bottomAnchor: scrollView.topAnchor,withTitle: "استرجاع كلمة المرور")
        CustomNavigationBar.setupBackButton(link: self, target: #selector(Dismiss))
    }
    
    // MARK:- Actions
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true)
    }
    
     // MARK:- Api
    @IBAction func forgetPass(sender : Any){
        self.loading()
        let url = AppDelegate.LocalUrl + "forgetPasswordRequest"
        let  info = [
            "email" : email.text ?? ""
        ]
        let headers = [
            "Accept" : "application/json",
            "Content-Type" : "application/json"
        ]
        AlamofireRequests.PostMethod(methodType: "POST", url: url, info: info, headers: headers){
            (error, success , jsonData) in
            do {
                let decoder = JSONDecoder()
                if error == nil{
                    if success{
                        CashedData.saveUserEmail(name: self.email.text ?? "")
                        self.openRegisteringPage(pagTitle: "resetPass")
                        self.stopAnimating()
                    }else{
                        let dataRecived = try decoder.decode(ErrorHandle.self, from: jsonData)
                        self.present(common.makeAlert(message: dataRecived.message ?? ""), animated: true, completion: nil)
                        self.stopAnimating()
                    }
                }else{
                    let dataRecived = try decoder.decode(ErrorHandle.self, from: jsonData)
                    self.present(common.makeAlert(message: dataRecived.message ?? ""), animated: true, completion: nil)
                    self.stopAnimating()
                }
            }catch {
                self.present(common.makeAlert(message: "غير موجود"), animated: true, completion: nil)
                self.stopAnimating()
            }
        }
    }
}
extension forgetPass: UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.border()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.removeTextFieldBorder()
    }
}
