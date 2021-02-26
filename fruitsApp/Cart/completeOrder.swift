//
//  completeOrder.swift
//  fruitsApp
//
//  Created by Bassam Ramadan on 9/22/20.
//  Copyright © 2020 Bassam Ramadan. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
class completeOrder: common , CLLocationManagerDelegate{
    
   
    var position = CLLocationCoordinate2D(latitude: 24.662499, longitude: 46.676857)
    
    
    var cartID: Int?
    var promoCode: String?
    var availableId: Int?
    var availableTimes = [availableTimeData]()
    var cost: String?
    
    @IBOutlet var notes: UITextView!
    @IBOutlet var address: UILabel!
    @IBOutlet var totalCost: UILabel!
    
    @IBOutlet var timeCollectionView: UICollectionView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var scrollView: UIScrollView!
    
    var CustomNavigationBar : CustomBar!
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCollectionView()
        setupCustomBar()
        getAvailableTimes()
        totalCost.text = cost ?? "0"
    }
    
    
    private func initCollectionView() {
        let nib = UINib(nibName: "timeCell", bundle: nil)
        timeCollectionView.register(nib, forCellWithReuseIdentifier: "timeCell")
        timeCollectionView.dataSource = self
        timeCollectionView.delegate = self
    }
    func setupCustomBar(){
        CustomNavigationBar = CustomBar.createMyClassView(view: view, bottomAnchor: scrollView.topAnchor,withTitle: "استكمال الشراء")
        CustomNavigationBar.setupBackButton(link: self, target: #selector(POP))
    }
    func donedatePicker() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: datePicker.date)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MapController"{
            if let map = segue.destination as? MapController{
                map.Link = self
            }
        }
    }
    
    
    @IBAction func submit(){
        self.loading()
        let url = AppDelegate.LocalUrl + "checkout"
        let headers = [
            "Content-Type": "application/json" ,
            "Accept" : "application/json",
            "Authorization" : "Bearer " + (CashedData.getUserApiKey() ?? "")
        ]
        let info = [
                "cart_id": cartID ?? 0,
                "payment_way": "cach",
                "day":  donedatePicker(),
                "availability_id": availableId ?? 0,
                "lat": position.latitude ,
                "lon":position.longitude ,
                "address":address.text ?? "",
                "promo_code":promoCode ?? ""
        ] as [String : Any]
        AlamofireRequests.PostMethod(methodType: "POST", url: url, info: info, headers: headers){
            (error, success, jsonData) in
            do {
                let decoder = JSONDecoder()
                if error == nil {
                    if success {
                        
                            let storyboard = UIStoryboard(name: "sendSuccessfully", bundle: nil)
                            let linkingVC = storyboard.instantiateViewController(withIdentifier: "sendSuccessfully")
                            let appDelegate = UIApplication.shared.delegate
                            appDelegate?.window??.rootViewController = linkingVC
                        
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
                self.present(common.makeAlert(), animated: true, completion: nil)
                self.stopAnimating()
            }
        }
    }
    func getAvailableTimes(){
        self.loading()
        let url = AppDelegate.LocalUrl + "available-times"
        let headers = [
            "Content-Type": "application/json" ,
            "Accept" : "application/json"
        ]
        
        AlamofireRequests.getMethod(url: url, headers: headers){
            (error, success, jsonData) in
            do {
                let decoder = JSONDecoder()
                if error == nil {
                    if success {
                        let dataReceived = try decoder.decode(availableTime.self, from: jsonData)
                        self.availableTimes.removeAll()
                        self.availableTimes.append(contentsOf: dataReceived.data ?? [])
                        if self.availableTimes.count > 0{
                            self.availableId = self.availableTimes[0].id
                        }
                        self.timeCollectionView.reloadData()
                        self.stopAnimating()
                    }else{
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
extension completeOrder: UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.text = ""
        return true
    }
}
extension completeOrder: UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableTimes.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 100, height: 80)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timeCell", for: indexPath) as! sizeCell
        cell.startTime.text = availableTimes[indexPath.row].timeFrom
        cell.endtTime.text = availableTimes[indexPath.row].timeTo
        cell.contentView.layer.cornerRadius = 7
        if availableTimes[indexPath.row].id == availableId{
            cell.contentView.backgroundColor = UIColor(named: "yellow")
        }else{
            cell.contentView.backgroundColor = UIColor(named: "gray")
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        availableId = availableTimes[indexPath.row].id
        collectionView.reloadData()
    }
    
}
