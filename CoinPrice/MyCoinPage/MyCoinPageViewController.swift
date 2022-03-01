//
//  MyCoinPageViewController.swift
//  CoinPrice
//
//  Created by Jason Wong on 1/3/2022.
//

import UIKit
import RxSwift
import RxCocoa

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
