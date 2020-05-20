//
//  TableViewCellWithActivityIndicator.swift
//  WhoIsSlow
//
//  Created by Anton Miroshnyk on 5/20/20.
//  Copyright © 2020 Anton Miroshnyk. All rights reserved.
//

import UIKit

class TableViewCellWithActivityIndicator: UITableViewCell {
    
    let activityIndicator = UIActivityIndicatorView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        activityIndicator.frame = .init(x: 0, y: 0, width: 32, height: 32)
        accessoryView = activityIndicator
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
