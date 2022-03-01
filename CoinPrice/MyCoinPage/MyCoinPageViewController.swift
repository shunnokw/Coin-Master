//
//  MyCoinPageViewController.swift
//  CoinPrice
//
//  Created by Jason Wong on 1/3/2022.
//

import UIKit
import DropDown

class MyCoinPageViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        title = "My Coin"
        view.backgroundColor = .white
        let rightBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCoin))
        rightBtn.tintColor = .black
        navigationItem.setRightBarButton(rightBtn, animated: true)
    }
    
    @objc func addCoin() {
        navigationController?.pushViewController(AddCoinPageViewController(), animated: true)
    }
}

class AddCoinPageViewController: UIViewController {
    
    var coinLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 50, width: 100, height: 50))
        label.text = "Select Coin: "
        label.textColor = .black
        return label
    }()
    
    var selectCoinBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 100, width: 100, height: 50))
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = 15
        return btn
    }()
    
    var quantityLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 150, width: 100, height: 50))
        label.text = "Quantity: "
        label.textColor = .black
        return label
    }()
    
    var quantityTextField: UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 200, width: 100, height: 30))
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        return textField
    }()
    
    let dropDown = DropDown()
    
    override func viewDidLoad() {
        title = "Add Coin"
        view.backgroundColor = .white
        
        dropDown.dataSource = ["Car", "Motorcycle", "Truck"]
        dropDown.anchorView = selectCoinBtn
        
        selectCoinBtn.addTarget(self, action: #selector(dropDownShow), for: .touchUpInside)
        
        view.addSubview(coinLabel)
        view.addSubview(selectCoinBtn)
        view.addSubview(quantityLabel)
        view.addSubview(quantityTextField)
    }
    
    @objc func dropDownShow () {
        dropDown.show()
    }
}
