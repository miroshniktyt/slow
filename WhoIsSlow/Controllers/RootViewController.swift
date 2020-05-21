//
//  ViewController.swift
//  WhoIsSlow
//
//  Created by Anton Miroshnyk on 5/11/20.
//  Copyright © 2020 Anton Miroshnyk. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
        
    required init?(coder aDecoder: NSCoder) {
        let vc = RootTableViewController(style: .grouped)
        super.init(rootViewController: vc)
    }
    
}

class RootTableViewController: UITableViewController {
    
    private let mcManager = MCManager()
    
    override init(style: UITableView.Style) {
        super.init(style: style)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        tableView.register(TableViewCellWithActivityIndicator.self, forCellReuseIdentifier: NSStringFromClass(TableViewCellWithActivityIndicator.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mcManager.discoveryDelegate = self
        mcManager.isSearchEnabled = true
    }
    
    @objc private func switchSearch(_ sender: UISwitch) {
        mcManager.isSearchEnabled = sender.isOn
        
        if mcManager.isSearchEnabled {
            tableView.insertSections(.init(integer: 2), with: .none)
        } else  {
            tableView.deleteSections(.init(integer: 2), with: .none)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return mcManager.isSearchEnabled ? 3 : 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return mcManager.foundPeers.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
            cell.textLabel?.text = "Play Solo"
            cell.textLabel?.textColor = .link
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
            cell.textLabel?.text = "Search nearby"
            let switcher = UISwitch()
            switcher.isOn = mcManager.isSearchEnabled
            switcher.addTarget(self, action: #selector(switchSearch(_:)), for: .valueChanged)
            cell.accessoryView = switcher
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TableViewCellWithActivityIndicator.self), for: indexPath)
            cell.textLabel?.text = mcManager.foundPeers[indexPath.row].displayName
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 2:
            return mcManager.foundPeers.isEmpty ? "There is nobody nearby" : "Invite other player to compete."
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 2:
            let view = UITableViewHeaderFooterView()
            view.textLabel?.text = "OTHER PLAYERS"
            let activityIndicator = UIActivityIndicatorView()
            if let textLabel = view.textLabel {
                textLabel.addSubview(activityIndicator)
                activityIndicator.translatesAutoresizingMaskIntoConstraints = false
                activityIndicator.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor).isActive = true
                activityIndicator.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: 8).isActive = true
            }
            if mcManager.foundPeers.isEmpty {
                activityIndicator.startAnimating()
            }
            return view
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            navigationController?.pushViewController(SoloGameViewController(), animated: true)
        case 2:
            mcManager.sendInvitation(toPeer: indexPath.row)
            mcManager.isHost = true
            
            let cell = tableView.cellForRow(at: indexPath)
            if let activitiIndicator = cell?.accessoryView as? UIActivityIndicatorView {
                activitiIndicator.startAnimating()
            }
        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
}


extension RootTableViewController: MCManagerDiscoveryDelegate {
    
    func didNotConnectToPeer(peerName: String) {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        let alert = UIAlertController(title: "", message: "Couldn't connect to \(peerName).", preferredStyle: .alert)
        let declineAction = UIAlertAction(title: "Ok", style: .cancel) { (alertAction) -> Void in
            self.mcManager.invitationHandler?(false, nil)
        }
        alert.addAction(declineAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func didReceiveInvitationFromPeer(peerName: String) {
        let alert = UIAlertController(title: "", message: "\(peerName) wants to play with you.", preferredStyle: .alert)
        let acceptAction: UIAlertAction = UIAlertAction(title: "Accept", style: .default) { (alertAction) -> Void in
            self.mcManager.invitationHandler?(true, self.mcManager.session)
            self.mcManager.isHost = false
        }
        let declineAction = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) -> Void in
            self.mcManager.invitationHandler?(false, nil)
        }
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func foundPeersChanged() {
        tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
    }
    
    func connectedWithPeer(isHost: Bool) {
        let vc = OneToOneGameViewController(mcManager: self.mcManager, isHost: isHost)
        navigationController?.pushViewController(vc, animated: true)
    }
}
