//
//  MyCoinPageViewController.swift
//  CoinPrice
//
//  Created by Jason Wong on 1/3/2022.
//

import UIKit
import DropDown
import RxSwift
import RxCocoa

struct MyCoinViewModel {
    private let coin: Coin
    let quantityString: String
    
    var displayText: String {
        coin.name
    }
    
    private var price: Decimal {
        Decimal(string: coin.price, locale: .current)!
    }
    
    private var quantity: Decimal {
        Decimal(string: quantityString, locale: .current)!
    }
    
    var worth: String {
        "\(price * quantity) USD"
    }
    
    var priceText: String {
        "$\(coin.price) USD"
    }
    
    var uuid: String {
        coin.uuid
    }
    
    init(coin: Coin, quantityString: String) {
        self.coin = coin
        self.quantityString = quantityString
    }
}

final class MyCoinPageViewModel {
    
    let coinViewModels = BehaviorSubject<[MyCoinViewModel]>(value: [])
    
    let coinService: CoinServiceProtocol
    
    init(coinService: CoinServiceProtocol) {
        self.coinService = coinService
    }
    
    func getCoins() -> [Coin] {
        var result = [Coin]()
        do {
            let snapShotCoins = try coinService.coinStream.value()
            for coin in snapShotCoins {
                result.append(coin)
            }
        } catch {
            print(error)
        }
        return result
    }
    
    func saveMyCoin(uuid: String, quantity: Decimal) {
        var dict = [
            uuid: "\(quantity)"
        ]
        
        let userDefaults = UserDefaults.standard
        if userDefaults.object(forKey: "MyCoins") == nil {
            userDefaults.setValue(dict, forKey: "MyCoins")
        } else {
            dict = userDefaults.object(forKey: "MyCoins") as! [String : String]
            dict[uuid] = "\(quantity)"
            userDefaults.setValue(dict, forKey: "MyCoins")
        }
    }
    
    func getMyCoin(completion: () -> Void) {
        let userDefaults = UserDefaults.standard
        if userDefaults.object(forKey: "MyCoins") != nil {
            let dict = userDefaults.object(forKey: "MyCoins") as! [String : String]
            var cvm = [MyCoinViewModel]()
            do {
                let snapShotCoins = try coinService.coinStream.value()
                for (key,value) in dict {
                    for coin in snapShotCoins {
                        if key == coin.uuid {
                            cvm.append(MyCoinViewModel(coin: coin, quantityString: value))
                        }
                    }
                }
            } catch {
                print(error)
            }
            coinViewModels.onNext(cvm)
        }
    }
}

class MyCoinPageViewController: UIViewController, UITableViewDelegate {
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(MyTableCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    let viewModel: MyCoinPageViewModel
    
    private let refreshControl = UIRefreshControl()

    let bag = DisposeBag()
    
    init(viewModel: MyCoinPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        title = "My Coin"
        view.backgroundColor = .white
        let rightBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCoin))
        rightBtn.tintColor = .black
        navigationItem.setRightBarButton(rightBtn, animated: true)
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshCoinData(_:)), for: .valueChanged)

        viewModel.getMyCoin(completion: {})
        bindTableData()
    }
    
    @objc private func refreshCoinData(_ sender: Any) {
        viewModel.getMyCoin(completion: {
            self.refreshControl.endRefreshing()
        })
    }
    
    func bindTableData() {
        viewModel.coinViewModels.observe(on: MainScheduler.instance).bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: MyTableCell.self)) {
            row, cellViewModel, cell in
            cell.titleLabel.text = "Name: \(cellViewModel.displayText)\nPrice: \(cellViewModel.priceText)\nQuantity:\(cellViewModel.quantityString)\nWorth: $\(cellViewModel.worth)"
            cell.selectionStyle = .none
            cell.bookmarkBtn.isHidden = true
        }
        .disposed(by: bag)
        
        //        tableView.rx.modelSelected(CoinViewModel.self).bind { coinViewModel in
        //            print("You clicked on \(coinViewModel.displayText)")
        //        }
        //        .disposed(by: bag)
        
        tableView.rx.setDelegate(self).disposed(by: bag)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    @objc func addCoin() {
        navigationController?.pushViewController(AddCoinPageViewController(coins: viewModel.getCoins(), viewModel: viewModel), animated: true)
    }
}

class AddCoinPageViewController: UIViewController {
    
    var coinLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 12, y: 60, width: 100, height: 50))
        label.text = "Select Coin: "
        label.textColor = .black
        return label
    }()
    
    var selectCoinBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 12, y: 100, width: 200, height: 25))
        btn.setTitle("Click here to select coin", for: .normal)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.cornerRadius = 5
        return btn
    }()
    
    var quantityLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 12, y: 130, width: 100, height: 50))
        label.text = "Quantity: "
        label.textColor = .black
        return label
    }()
    
    var quantityTextField: UITextField = {
        let textField = UITextField(frame: CGRect(x: 12, y: 170, width: 100, height: 30))
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
