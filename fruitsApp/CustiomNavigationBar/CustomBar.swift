//
//  CustomBar.swift
//  fruitsApp
//
//  Created by Bassam on 2/7/21.
//  Copyright © 2021 Bassam Ramadan. All rights reserved.
//

import UIKit

class CustomBar: UIView {
    @IBOutlet  var title: UILabel!
    @IBOutlet  var cartItems: UILabel!
    @IBOutlet  var leftbarButton: UIButton!
    @IBOutlet  var rightbarButton: UIButton!
    
    class func createMyClassView(view: UIView,bottomAnchor: NSLayoutYAxisAnchor,withTitle: String) -> CustomBar {
        let myClassNib = UINib(nibName: "CustomNavigationBar", bundle: nil)
        let v = myClassNib.instantiate(withOwner: nil, options: nil)[0] as! CustomBar
        view.addSubview(v)
        v.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: bottomAnchor, trailing: view.trailingAnchor)
        v.title.text = withTitle
        return v
    }
    func setupBackButton(link: UIViewController,target: Selector){
        hideLeftBar()
        rightbarButton.setImage(UIImage(named: "ic_back_arrow0"), for: .normal)
        rightbarButton.addTarget(link, action: target, for: .touchUpInside)
    }
    func hideLeftBar(){
        leftbarButton.isHidden = true
        cartItems.isHidden = true
    }
    func hideRightBar(){
        rightbarButton.isHidden = true
    }
    func hideCartItem(){
        cartItems.isHidden = !cartItems.isHidden
    }
    func cartHasZeroItems(){
        cartItems.isHidden = (cartItems.text == "0")
    }
    
    //MARK:- Actions
    
   
}
