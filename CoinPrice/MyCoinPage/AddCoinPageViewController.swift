//
//  AddCoinPageViewController.swift
//  CoinPrice
//
//  Created by Jason Wong on 2/3/2022.
//

import UIKit
import DropDown

class AddCoinPageViewController: UIViewController {
    
    var coinLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 12, y: 120, width: 100, height: 50))
        label.text = "Select Coin: "
        label.textColor = .black
        return label
    }()
    
    var selectCoinBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 12, y: 160, width: 200, height: 25))
        btn.setTitle("Click here to select coin", for: .normal)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.cornerRadius = 5
        return btn
    }()
    
    var quantityLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 12, y: 190, width: 100, height: 50))
        label.text = "Quantity: "
        label.textColor = .black
        return label
    }()
    
    var quantityTextField: UITextField = {
        let textField = UITextField(frame: CGRect(x: 12, y: 230, width: 100, height: 30))
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.cornerRadius = 5
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    let dropDown = DropDown()
    let coins: [Coin]
    let viewModel: MyCoinPageViewModel
    var selectedCoin: Coin?
    
    init(coins: [Coin], viewModel: MyCoinPageViewModel) {
        self.coins = coins
        self.viewModel = viewModel
        selectedCoin = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        title = "Add Coin"
        view.backgroundColor = .white
        let rightBtn = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(add))
        rightBtn.tintColor = .red
        navigationItem.setRightBarButton(rightBtn, animated: true)
        
        dropDown.dataSource = coins.map { $0.name }
        dropDown.anchorView = selectCoinBtn
        
        selectCoinBtn.addTarget(self, action: #selector(dropDownShow), for: .touchUpInside)
        
        view.addSubview(coinLabel)
        view.addSubview(selectCoinBtn)
        view.addSubview(quantityLabel)
        view.addSubview(quantityTextField)
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            selectedCoin = coins[index]
            selectCoinBtn.setTitle(item, for: .normal)
            selectCoinBtn.setTitleColor(.black, for: .normal)
        }
    }
    
    @objc func dropDownShow () {
        dropDown.show()
    }
    
    @objc func add () {
        if selectedCoin != nil {
            guard let quantity = Decimal(string: quantityTextField.text!, locale: .current) else {
                return
            }
            viewModel.saveMyCoin(uuid: selectedCoin!.uuid, quantity: quantity)
            navigationController?.popViewController(animated: true)
        }
    }
}
