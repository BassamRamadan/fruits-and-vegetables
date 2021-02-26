//
//  SettingController.swift
//  fruitsApp
//
//  Created by Bassam on 2/8/21.
//  Copyright © 2021 Bassam Ramadan. All rights reserved.
//

import UIKit
import PopupDialog
class SettingController: common{
    // MARK: - Outlets
    @IBOutlet var categoryCollection: UICollectionView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var aboutus: UILabel!
    
    var CustomNavigationBar : CustomBar!
    var categories: [brandItem] = []
    var config : configData?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        appendList()
        setupCustomBar()
        getConfig{ data in
            self.config = data
            self.setupData()
        }
    }
    func setupData() {
        aboutus.text = config?.aboutUs ?? ""
    }
    func setupCustomBar(){
        CustomNavigationBar = CustomBar.createMyClassView(view: view, bottomAnchor: scrollView.topAnchor,withTitle:  "القائمة")
        CustomNavigationBar.hideLeftBar()
    }
    func appendList(){
        
        if CashedData.getUserApiKey() == ""{
            categories.append(brandItem(brandText: "الرئيسية", brandImage: #imageLiteral(resourceName: "ic_home"),storyName: "Main"))
            categories.append(brandItem(brandText: "دخول", brandImage: #imageLiteral(resourceName: "ic_login"),storyName: "login"))
            categories.append(brandItem(brandText: "عميل جديد", brandImage: #imageLiteral(resourceName: "ic_register"),storyName: "sign"))
            
        }else{
            categories.append(brandItem(brandText: "الرئيسية", brandImage: #imageLiteral(resourceName: "ic_home"),storyName: "Main"))
            categories.append(brandItem(brandText: "طلباتي", brandImage: #imageLiteral(resourceName: "ic_order_list"),storyName: "myOrders"))
            categories.append(brandItem(brandText: "تعديل بياناتي", brandImage: UIImage(named: "ic_edit") ?? #imageLiteral(resourceName: "ic_edit"),storyName: "sign"))
            categories.append(brandItem(brandText: "الخروج", brandImage: #imageLiteral(resourceName: "ic_logout"),storyName: "logout"))
        }
        categoryCollection.reloadData()
    }
    // MARK:- Actions
    @IBAction func contactUs(sender: UIButton){
        if sender.tag == 1{
            callWhats(whats: config?.whatsapp ?? "")
        }else{
            CallPhone(phone: config?.phone ?? "")
        }
    }
    @IBAction func openContactUs(){
        let loginVC = fruitsApp.ContactUs(nibName: "ContactUs", bundle: nil)
        // Create the dialog
        let popup = PopupDialog(viewController: loginVC,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceDown,
                                tapGestureDismissal: false,
                                panGestureDismissal: false)
        present(popup, animated: true, completion: nil)
    }
}
extension SettingController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 85, height: 140)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SettingOptions", for: indexPath) as! categoryCell
        cell.name.text = categories[indexPath.row].brandText
        cell.image.image = categories[indexPath.row].brandImage
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        openPages(row: categories[indexPath.row].storyName)
    }
    
    
    func openPages(row: String){
        switch row {
        case "sign","login":
            openRegisteringPage(pagTitle: row)
            break
        case "Main":
            openMain()
            break
        case "logout":
            AdminLogout(currentController: self)
            break
        default:
            callStoryboard(name: row)
        }
    }
    @IBAction func share(){
        let activityController = UIActivityViewController(activityItems: [AppDelegate.stringWithLink], applicationActivities: nil)
        
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            navigationItem.setLeftBarButton(UIBarButtonItem(customView: UIButton()), animated: false)
            let activityVC: UIActivityViewController = UIActivityViewController(activityItems: [AppDelegate.stringWithLink], applicationActivities: nil)
            present(activityVC, animated: true)
            if let popOver = activityVC.popoverPresentationController {
                popOver.barButtonItem = navigationItem.leftBarButtonItem
                //popOver.barButtonItem
            }
            
        } else {
            present(activityController, animated: true)
        }
    }
}
struct brandItem {
    
    var brandText:String
    var brandImage:UIImage
    var storyName: String
}
