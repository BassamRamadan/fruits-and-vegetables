//
//  home.swift
//  perfume
//
//  Created by Bassam Ramadan on 9/8/20.
//  Copyright © 2020 Bassam Ramadan. All rights reserved.
//

import UIKit
import PopupDialog

class home: common {
    var categories = [categoryData]()
    var products : products?
    public static var returnFromCart = false
    var categorySelected = 0
    var CustomNavigationBar : CustomBar!
    
    @IBOutlet var categoryCollection: UICollectionView!
    @IBOutlet var productCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCategories()
        setCartCount()
        setupCustomBar()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if home.returnFromCart {
            setCartCount()
            home.returnFromCart = false
        }
    }
    
    func setupCustomBar(){
        CustomNavigationBar = CustomBar.createMyClassView(view: view, bottomAnchor: categoryCollection.topAnchor,withTitle: "")
        CustomNavigationBar.leftbarButton.addTarget(self, action: #selector(OpenCart), for: .touchUpInside)
        CustomNavigationBar.rightbarButton.addTarget(self, action: #selector(OpenSetting), for: .touchUpInside)
    }
    
    public func setCartCount(){
        getCartItems{ data in
            self.CustomNavigationBar.cartItems.text = "\(data?.items?.count ?? 0)"
            self.CustomNavigationBar.cartHasZeroItems()
        }
    }
    
    @IBAction private func scrollingCollectionByButtons(_ sender: UIButton) {
        // Visible Items in collection
        var visibleItems: NSArray = self.categoryCollection.indexPathsForVisibleItems as NSArray
        visibleItems = visibleItems.sorted {
            (obj1, obj2) -> Bool in
            return (obj1 as! IndexPath).compare( (obj2 as! IndexPath)) == .orderedAscending
            } as NSArray
        let currentItem: IndexPath = visibleItems.object(at: sender.tag == 2 ? visibleItems.count-1 : 0) as! IndexPath
        
        var nextItem: IndexPath = IndexPath(item: currentItem.item + (1 * sender.tag == 2 ? 1: -1), section: 0)
        // right scroll
        if sender.tag == 1{
            nextItem.row = max(0,nextItem.row)
            if nextItem.row >= 0 {
                self.categoryCollection.scrollToItem(at: nextItem, at: .right, animated: true)
            }
        }
        // left scroll
        if sender.tag == 2{
            nextItem.row = min(categories.count-1,nextItem.row)
            if nextItem.row < categories.count {
                self.categoryCollection.scrollToItem(at: nextItem, at: .left, animated: true)
            }
        }
    }
    
    @IBAction func addProductToCart(sender: UIButton){
        if CashedData.getUserApiKey() == "" || CashedData.getUserApiKey() == nil{
            openRegisteringPage(pagTitle: "login")
        }else{
            if products?.data?[sender.tag].weightUnits?.count ?? 0 > 0{
                addToCart(productId: products?.data?[sender.tag].id ?? 0, weight_unit_id: products?.data?[sender.tag].weightUnits?[0].id ?? 0, quantity: 1){
                    done in
                    
                    self.setCartCount()
                }
            }else{
               present(common.makeAlert(message: "لم يتم إضافة اوزان للمنتج حاليا"),animated: true,completion: nil)
            }
        }
    }
    func openProductDetails(data: product){
        let loginVC = productDetails(nibName: "productDetails", bundle: nil)
        loginVC.data = data
        loginVC.viewParent = self
        // Create the dialog
        let popup = PopupDialog(viewController: loginVC,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceDown,
                                tapGestureDismissal: false,
                                panGestureDismissal: false)
        present(popup, animated: true, completion: nil)
    }
    
}

// MARK:- Collections View
extension home: UICollectionViewDataSource,UICollectionViewDelegate , UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == categoryCollection{
            return categories.count
        }else{
            collectionView.backgroundView = nil
            if products?.data?.count == 0{
                noDataAvailable(collectionView)
            }
            return products?.data?.count ?? 0
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == categoryCollection{
            return .init(width: 85, height: 100)
        }else{
            return .init(width: (collectionView.frame.width - 30)/2, height: 160)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == categoryCollection{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categories", for: indexPath) as! categoryCell
            cell.name.text = categories[indexPath.row].name ?? ""
            cell.image.sd_setImage(with: URL(string: categories[indexPath.row].imagePath ?? ""))
            if categorySelected == categories[indexPath.row].id ?? 0{
                cell.imageView.border()
                CustomNavigationBar.title.text = categories[indexPath.row].name ?? ""
            }else{
                cell.imageView.removeBorder()
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "products", for: indexPath) as! productCell
            cell.productCart.tag = indexPath.row
            cell.productName.text = products?.data?[indexPath.row].name ?? ""
            if products?.data?[indexPath.row].weightUnits?.count ?? 0 > 0{
                cell.productPrice.text = "\(products?.data?[indexPath.row].weightUnits?[0].weightPrice ?? "0")"
            }
            cell.productImage.sd_setImage(with: URL(string: products?.data?[indexPath.row].imagePath ?? ""))
            
            if (indexPath.row + 1 == products?.data?.count) &&
                (products?.to ?? 0) != (products?.total ?? 0){
                self.getProducts(categoryId: categorySelected, pageNumber: (products?.currentPage ?? 0) + 1, removeIt: false)
            }
            return cell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollection{
            self.getProducts(categoryId: self.categories[indexPath.row].id ?? 0, pageNumber: 1, removeIt: true)
        }else{
            openProductDetails(data: (self.products?.data?[indexPath.row])!)
        }
    }
}

// MARK:- Alamofire
extension home {
    func getCategories(){
        self.loading()
        let url = AppDelegate.LocalUrl + "categories"
        let headers = [
            "Content-Type": "application/json" ,
            "Accept" : "application/json",
        ]
        AlamofireRequests.getMethod(url: url, headers: headers) { (error, success, jsonData) in
            do {
                let decoder = JSONDecoder()
                if error == nil {
                    if success {
                        let dataReceived = try decoder.decode(category.self, from: jsonData)
                        self.categories.removeAll()
                        self.categories.append(contentsOf: dataReceived.data ?? [])
                        self.categoryCollection.reloadData()
                        self.stopAnimating()
                        if self.categories.count > 0{
                            self.getProducts(categoryId: self.categories[0].id ?? 0, pageNumber: 1, removeIt: true)
                            let item = IndexPath(item: 0, section: 0)
                            self.categoryCollection.scrollToItem(at: item, at: .right, animated: true)
                        }
                    }else{
                        self.present(common.makeAlert(), animated: true, completion: nil)
                        self.stopAnimating()
                    }
                    
                }else{
                    let dataRecived = try decoder.decode(ErrorHandle.self, from: jsonData)
                    self.present(common.makeAlert(message: dataRecived.message ?? ""), animated: true, completion: nil)
                    self.stopAnimating()
                }
            }catch {
                self.present(common.makeAlert(), animated: true, completion: nil)
                self.stopAnimating()
            }
        }
    }
    
    func getProducts(categoryId: Int,pageNumber: Int,removeIt: Bool){
        self.loading()
        let url = AppDelegate.LocalUrl + "products?page=\(pageNumber)"
        let headers = [
            "Content-Type": "application/json" ,
            "Accept" : "application/json"
        ]
        let info = [
            "category_id": categoryId
        ]
        AlamofireRequests.PostMethod(methodType: "POST", url: url, info: info, headers: headers){
            (error, success, jsonData) in
            do {
                let decoder = JSONDecoder()
                if error == nil {
                    if success {
                        let dataReceived = try decoder.decode(productsJson.self, from: jsonData)
                        
                        if removeIt{
                            self.products = dataReceived.data
                        }else{
                            self.products?.data?.append(contentsOf: dataReceived.data?.data ?? [])
                            self.products?.currentPage = dataReceived.data?.currentPage ?? 0
                            self.products?.to = dataReceived.data?.to ?? 0
                            
                        }
                        self.categorySelected = categoryId
                        self.categoryCollection.reloadData()
                        self.productCollection.reloadData()
                        self.stopAnimating()
                    }else{
                        self.present(common.makeAlert(), animated: true, completion: nil)
                        self.stopAnimating()
                    }
                    
                }else{
                    let dataRecived = try decoder.decode(ErrorHandle.self, from: jsonData)
                    self.present(common.makeAlert(message: dataRecived.message ?? ""), animated: true, completion: nil)
                    self.stopAnimating()
                }
            }catch {
                self.present(common.makeAlert(), animated: true, completion: nil)
                self.stopAnimating()
            }
        }
    }
}
