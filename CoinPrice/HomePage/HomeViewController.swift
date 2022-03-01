//
//  HomeViewController.swift
//  Wheelsales
//
//  Created by Jason Wong on 11/2/2022.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController, UITableViewDelegate {
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(MyTableCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let loadingLabel: UILabel = {
        let loadingLabel = UILabel()
        loadingLabel.text = "Loading..."
        loadingLabel.backgroundColor = .black.withAlphaComponent(0.2)
        return loadingLabel
    }()
    
    private let refreshControl = UIRefreshControl()
    
    private var viewModel: CoinListViewModelProtocol
    
    private var bag = DisposeBag()
    
    init(viewModel: CoinListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func showSortActionSheet() {
        let alert = UIAlertController(title: "Sort", message: "Sort by one of the Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Alphabetical ↑", style: .default, handler: { _ in
            self.viewModel.sortAZ()
        }))
        
        alert.addAction(UIAlertAction(title: "Alphabetical ↓", style: .default, handler: { _ in
            self.viewModel.sortZA()
        }))
        
        alert.addAction(UIAlertAction(title: "Price (high to low)", style: .default, handler: { _ in
            self.viewModel.sortHigh2Low()
        }))
        
        alert.addAction(UIAlertAction(title: "Price (low to high)", style: .default, handler: { _ in
            self.viewModel.sortLow2High()
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Coin Price"
        
        toolbarItems = [
            UIBarButtonItem(title: "Sort By", style: .plain, target: self, action: #selector(showSortActionSheet)),
        ]
        navigationController?.setToolbarHidden(false, animated: true)
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
        
        view.addSubview(loadingLabel)
        loadingLabel.center = view.convert(view.center, from: view.superview)
        loadingLabel.frame.size.height = 100
        loadingLabel.frame.size.width = 100
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshCoinData(_:)), for: .valueChanged)
        
        bindTableData()
        bindLoading()
        viewModel.fetchCoin()
    }
    
    @objc private func refreshCoinData(_ sender: Any) {
        viewModel.fetchCoin()
    }
    
    func bindLoading() {
        guard let tabItems = tabBarController!.tabBar.items else {return}
        
        for tabItem in tabItems {
            viewModel.hideLoading.observe(on: MainScheduler.instance).bind(to: tabItem.rx.isEnabled).disposed(by: bag)
        }
        
        viewModel.hideLoading.observe(on: MainScheduler.instance).bind(to: loadingLabel.rx.isHidden).disposed(by: bag)
        viewModel.hideLoading.subscribe(onNext: {
            hide in
            if (hide) {
                DispatchQueue.main.async {
                    // This block is not owned by the class no no need to use weak self
                    self.refreshControl.endRefreshing()
                }
            }
        })
            .disposed(by: bag)
    }
    
    @objc private func bookmark(_ sender: Any) {
        if (sender is CustomBtn) {
            let cusBtn = sender as! CustomBtn
            viewModel.addRemoveBookmark(uuid: cusBtn.uuid)
        }
    }
    
    func bindTableData() {
        viewModel.coinViewModels.observe(on: MainScheduler.instance).bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: MyTableCell.self)) {
            row, cellViewModel, cell in
            cell.titleLabel.text = "Name: \(cellViewModel.displayText)\nPrice: \(cellViewModel.priceText)"
            cell.selectionStyle = .none
            if (cellViewModel.isBookmarked) {
                cell.bookmarkBtn.titleLabel?.font = UIFont.fontAwesome(ofSize: 20, style: .solid)
            } else {
                cell.bookmarkBtn.titleLabel?.font = UIFont.fontAwesome(ofSize: 20, style: .regular)
            }
            cell.bookmarkBtn.uuid = cellViewModel.uuid
            cell.bookmarkBtn.addTarget(self, action: #selector(self.bookmark), for: .touchUpInside)
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
}
