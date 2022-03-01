//
// Created by Jason Wong on 12/2/2022.
//

import Foundation
import UIKit
import FontAwesome_swift

class CustomBtn: UIButton {
    var uuid = ""
}

class MyTableCell: UITableViewCell {


    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.8, height: 100)
        titleLabel.numberOfLines = 0
        return titleLabel
    }()


    let bookmarkBtn: CustomBtn = {
        let btn = CustomBtn()
        btn.frame = CGRect(x: UIScreen.main.bounds.width - 50, y: 0, width: 20, height: 100)
        btn.setTitleColor(.black, for: .normal)
        btn.setTitle(String.fontAwesomeIcon(name: .bookmark), for: .normal)
        return btn
    }()

    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(bookmarkBtn)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

    }
}