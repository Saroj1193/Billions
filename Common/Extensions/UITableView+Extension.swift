//
//  UITableView+Extension.swift
//  
//
//  Created by Tristate on 12/9/19.
//  Copyright © 2019 Tristate. All rights reserved.
//

import UIKit

/// <#Description#>
public extension UITableView {
    
    func registerCell<T: UITableViewCell>(class: T.Type) {
        self.register(UINib(nibName: T.nibName(), bundle: nil), forCellReuseIdentifier: T.reuseIdentifier())
    }
    
    func registerHeaderFooter<T: UITableViewHeaderFooterView>(class: T.Type) {
        self.register(UINib(nibName: T.nibName(), bundle: nil), forHeaderFooterViewReuseIdentifier: T.reuseIdentifier())
    }
}

extension UITableView{
    func scrollToBottom(animated: Bool = true) {
        let section =  numberOfSections
        let index  = numberOfRows(inSection: section-1)
        guard section-1 >= 0 else {
            return
        }
        guard index-1 >= 0 else {
            return
        }
        self.safeScrollToRow(at: IndexPath(row: index-1, section: section-1), at: .bottom, animated: true)
    }
    
    func safeScrollToRow(at indexPath: IndexPath, at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        guard indexPath.section < numberOfSections,indexPath.section >= 0 else { return }
        guard indexPath.row < numberOfRows(inSection: indexPath.section),indexPath.row >= 0 else { return }
        DispatchQueue.main.async {
            self.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
        }
    }
}

extension UITableViewCell {
    
    class func reuseIdentifier() -> String {
        return String(describing: self)
    }
    
    class func nibName() -> String {
        return String(describing: self)
    }
}

extension UITableViewHeaderFooterView {
    
    class func reuseIdentifier() -> String {
        return String(describing: self)
    }
    
    class func nibName() -> String {
        return String(describing: self)
    }
}


extension UITableView {
    func layoutTableHeaderView() {
        
        guard let headerView = self.tableHeaderView else { return }
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let headerWidth = headerView.bounds.size.width;
        let temporaryWidthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "[headerView(width)]", options: NSLayoutConstraint.FormatOptions(rawValue: UInt(0)), metrics: ["width": headerWidth], views: ["headerView": headerView])
        
        headerView.addConstraints(temporaryWidthConstraints)
        
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let headerSize = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let height = headerSize.height
        var frame = headerView.frame
        
        frame.size.height = height
        headerView.frame = frame
        
        self.tableHeaderView = headerView
        
        headerView.removeConstraints(temporaryWidthConstraints)
        headerView.translatesAutoresizingMaskIntoConstraints = true
        
    }
    
    func updateHeaderViewHeight() {
        if let header = self.tableHeaderView {
            let newSize = header.systemLayoutSizeFitting(CGSize(width: self.bounds.width, height: 0))
            header.frame.size.height = newSize.height
        }
    }
    
    func setEmptyView(title: String, message: String, color : UIColor) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = color
        titleLabel.font = GlobalFunction.overrideFontSize(fontName: .SFProText_Regular, fontSize: 16.0)
        messageLabel.textColor = color
        messageLabel.font = GlobalFunction.overrideFontSize(fontName: .SFProText_Regular, fontSize: 20.0)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        // The only tricky part is here:
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .none
    }
}

extension UICollectionView {
    func setEmptyView(title: String, message: String, color : UIColor) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y , width: self.bounds.size.width, height: self.bounds.size.height))
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = color
        titleLabel.font = GlobalFunction.overrideFontSize(fontName: .SFProText_Regular, fontSize: 16.0)
        messageLabel.textColor = color
        messageLabel.font = GlobalFunction.overrideFontSize(fontName: .SFProText_Regular, fontSize: 20.0)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        self.backgroundView = emptyView
    }
}

