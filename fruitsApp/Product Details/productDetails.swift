//
//  productDetails.swift
//  perfume
//
//  Created by Bassam Ramadan on 9/9/20.
//  Copyright © 2020 Bassam Ramadan. All rights reserved.
//

import UIKit
import DropDown
class productDetails: common{
    
    //MARK:- Outlets
    @IBOutlet var name:UILabel!
    @IBOutlet var price:UILabel!
    @IBOutlet var image: UIImageView!
    @IBOutlet var discription: UITextView!
    @IBOutlet var count: UILabel!
    @IBOutlet var dropButton: UIButton!
    @IBOutlet var sizeCollectionView: UICollectionView!
    //MARK:- Variables
    var dropDown = DropDown()
    var totalCount: Double? = 0.0
    var startFrom: Double? = 0.0
    var priceFrom: Double? = 0.0
    var data: product? = nil
    var viewParent : home?
    var productAdded = false
    var weight_unit_id = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        initCollectionView()
        discription.delegate = self
        setupData()
    }
    private func initCollectionView() {
        let nib = UINib(nibName: "sizeCell", bundle: nil)
        sizeCollectionView.register(nib, forCellWithReuseIdentifier: "sizeCell")
        sizeCollectionView.dataSource = self
        sizeCollectionView.delegate = self
    }
    //MARK:- functions
    fileprivate func setupStartPrice(index: Int) {
        weight_unit_id = data?.weightUnits?[index].id ?? 0
        price.text = data?.weightUnits?[index].weightPrice ??  "0"
        priceFrom = Double(price.text ?? "0")
        startFrom = Double(data?.weightUnits?[index].startFrom ?? "0")
        count.text = "\(startFrom ?? 0.0)"
        totalCount = startFrom
        self.sizeCollectionView.reloadData()
    }
    
    fileprivate func setupData(){
        if data != nil {
            name.text = data?.name ?? ""
            image.sd_setImage(with: URL(string: data?.imagePath ?? ""))
            discription.text = data?.datumDescription ?? ""
            if data?.weightUnits?.count ?? 0 > 0{
                setupStartPrice(index: (data?.weightUnits?.count ?? 0)-1)
            }
        }
    }
    
    fileprivate func setupDropDown(_ sender: UIButton) {
        dropDown.anchorView = (sender as AnchorView)
        dropDown.dataSource = parsingData(self.data?.weightUnits ?? [])
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        if dropDown.dataSource.count > 0{
            dropDown.selectRow(at: 0)
            dropButton.setTitle(dropDown.selectedItem, for: .normal)
        }
    }
    func parsingData(_ data : [WeightUnit])->[String]{
        var ResData = [String]()
        for x in data {
            ResData.append("\(x.weightUnit ?? "")")
        }
        return ResData
    }
    
    //MARK:- Actions
    @IBAction func dropDown(_ sender: UIButton) {
        dropDown.selectionAction = {
            [unowned self](index : Int , item : String) in
                sender.setTitle(item, for: .normal)
                self.setupStartPrice(index: index)
           }
        dropDown.show()
    }
    @IBAction func close(){
        if productAdded{
            viewParent?.setCartCount()
        }
       super.dismiss(animated: true)
    }
    @IBAction func plus(){
        if let p = startFrom{
            totalCount = (totalCount ?? 0.0) + p
            count.text = "\(totalCount ?? 0.0)"
            if var totalPrice = Double(price.text ?? "0"){
                totalPrice += priceFrom ?? 0.0
                price.text = "\(totalPrice)"
            }
        }
    }
    @IBAction func minus(){
        if totalCount != startFrom{
            if let p = startFrom{
                totalCount = (totalCount ?? 0.0) - p
                count.text = "\(totalCount ?? 0.0)"
                if var totalPrice = Double(price.text ?? "0"){
                    totalPrice -= priceFrom ?? 0.0
                    price.text = "\(totalPrice)"
                }
            }
        }
    }
    @IBAction func addProductToCart(){
        if CashedData.getUserApiKey() == "" || CashedData.getUserApiKey() == nil{
            openRegisteringPage(pagTitle: "login")
        }else{
            addToCart(productId: data?.id ?? 0, weight_unit_id: weight_unit_id, quantity: Int((totalCount ?? 0)/(startFrom ?? 0.0))){
                done in
                self.productAdded = true
            }
        }
    }
}
extension productDetails: UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
}
extension productDetails: UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data?.weightUnits?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: CGRect.zero)
        label.text = (self.data?.weightUnits?[indexPath.row].weightUnit ?? "")
        label.sizeToFit()
        return CGSize(width: label.frame.width + 60, height: 40)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sizeCell", for: indexPath) as! sizeCell
        cell.sizeName.text = self.data?.weightUnits?[indexPath.row].weightUnit ?? ""
        cell.contentView.layer.cornerRadius = 7
        cell.contentView.backgroundColor = UIColor(named: "gray")
        if self.data?.weightUnits?[indexPath.row].id == weight_unit_id{
            cell.contentView.backgroundColor = UIColor(named: "yellow")
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        weight_unit_id = self.data?.weightUnits?[indexPath.row].id ?? 0
        self.setupStartPrice(index: indexPath.row)
        self.sizeCollectionView.reloadData()
    }
}
