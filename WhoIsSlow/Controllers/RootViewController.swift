//
//  ViewController.swift
//  WhoIsSlow
//
//  Created by Anton Miroshnyk on 5/11/20.
//  Copyright © 2020 Anton Miroshnyk. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
            
    private let mcManager = MCManager()
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: UITableView.Style.grouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "id")
        table.dataSource = self
        table.delegate = self
        return table
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mcManager.discoveryDelegate = self
        
        view.addSubview(tableView)
        tableView.fillSuperview()
        
//        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(barButtonTapped))
    }
    
//    @objc private func barButtonTapped() {
//        print(mcManager.session.connectedPeers)
//    }
}

extension RootViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 2:
            return "Invite other player to compete."
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return mcManager.isSearchOn ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return mcManager.foundPeers.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath)
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "Play Solo"
            cell.textLabel?.textColor = .link
        case 1:
            cell.textLabel?.text = "Search nearby"
            let switcher = UISwitch()
            switcher.isOn = mcManager.isSearchOn
            switcher.addTarget(self, action: #selector(switchSearch(_:)), for: .valueChanged)
            cell.accessoryView = switcher
        case 2:
            cell.textLabel?.text = mcManager.foundPeers[indexPath.row].displayName
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            navigationController?.pushViewController(SoloGameViewController(), animated: true)
        case 2:
            mcManager.sendInvitation(toPeer: indexPath.row)
            mcManager.isHost = true
        default:
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @objc private func switchSearch(_ sender: UISwitch) {
        let isOn = sender.isOn
        if isOn {
            mcManager.isSearchOn = isOn
            tableView.insertSections(.init(integer: 2), with: .top)
        } else {
            tableView.deleteSections(.init(integer: 2), with: .top)
            mcManager.isSearchOn = isOn
        }
    }
}

extension RootViewController: MCManagerDiscoveryDelegate {
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
