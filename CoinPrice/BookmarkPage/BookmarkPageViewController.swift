//
//  MyCoinsViewController.swift
//  CoinPrice
//
//  Created by Jason Wong on 26/2/2022.
//

import UIKit
import RxSwift

class BookmarkPageViewController: UIViewController, UITableViewDelegate {
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(MyTableCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    let viewModel: BookmarkPageViewModel
    
    let bag = DisposeBag()
    
    init(viewModel: BookmarkPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        title = "Bookmark"
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
        
        viewModel.getBookmark()
        bindTableData()
    }
    
    func bindTableData() {
        viewModel.coinViewModels.observe(on: MainScheduler.instance).bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: MyTableCell.self)) {
            row, cellViewModel, cell in
            cell.titleLabel.text = "Name: \(cellViewModel.displayText)\nPrice: \(cellViewModel.priceText)"
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
}
