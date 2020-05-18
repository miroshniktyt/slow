//
//  MultiplayerGameViewController.swift
//  WhoIsSlow
//
//  Created by Anton Miroshnyk on 5/13/20.
//  Copyright © 2020 Anton Miroshnyk. All rights reserved.
//

import UIKit
import Foundation

class OneToOneGameViewController: UIViewController {
    
    init(mcManager: MCManager, isHost: Bool) {
        self.isHost = isHost
        self.mcManager = mcManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let mcManager: MCManager
    let isHost: Bool
    
    private let roundsNumber = 10
    
    private var count = 0 {
        didSet {
            aim.text = "\(count)"
        }
    }
    
    private var startDate: Date = Date()
    
    private let aimSize: CGFloat = 64

    private let startCounterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 64)
        label.textAlignment = .center
        label.textColor = .link
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var aim: Aim = {
        let view = Aim(size: aimSize)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(aimTapped))
        view.addGestureRecognizer(gesture)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        title = isHost ? "Host" : "Non-host"
        
        mcManager.gameDelegate = self
        startGame()
    }
    
//    deinit {
//        mcManager.session.disconnect()
//    }
    
    @objc func aimTapped() {
        aim.removeFromSuperviewAnimated(isSuccessful: true)
        
        count -= 1
        guard count != 0 else {
            mcManager.sendFinishData()
            finishGame(isWinner: true)
            return
        }
        
        if isHost {
            replaceAim()
        } else {
            mcManager.sendDidTapData()
        }
    }
    
    func replaceAim() {
        let randomLocation: Location = .random
        mcManager.sendNewLocation(location: randomLocation)
        placeAimOnNewLocation(forLocation: randomLocation)
    }
    
    func placeAimOnNewLocation(forLocation location: Location) {
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame
        let randomAreaOrgin = safeAreaFrame.origin.applying(.init(translationX: aimSize / 2, y: aimSize / 2))
        let x = location.x * (safeAreaFrame.size.width - aimSize) + randomAreaOrgin.x
        let y = location.y * (safeAreaFrame.size.height - aimSize) + randomAreaOrgin.y
        aim.center = .init(x: x, y: y)
        view.addSubview(aim)
    }
    
    func startGame() {
        startDate = Date()
        count = roundsNumber
        view.addSubview(startCounterLabel)
        startCounterLabel.fillSuperview()
        startCounterLabel.text = "3"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { self.startCounterLabel.text = "2" }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.startCounterLabel.text = "1" }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.startCounterLabel.removeFromSuperview()
            if self.isHost { self.replaceAim() }
        }
    }
}

extension OneToOneGameViewController: MCManagerGameDelegate {
    
    func finishGame(isWinner: Bool) {
        
        let title = isWinner ? "Well done!" : "No today :("
        let message = isWinner ? "Your are the winner!" : "You are the loser"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func hostDidReplaceAim(toLocation location: Location) {
        if let _ = aim.superview {
            aim.removeFromSuperviewAnimated(isSuccessful: false)
        }
        placeAimOnNewLocation(forLocation: location)
    }
    
    func otherPlayerDidTapAim() {
        aim.removeFromSuperviewAnimated(isSuccessful: false)
        if isHost {
            replaceAim()
        }
    }
}

struct Location: Codable {
    
//    let dateCreated: Date = Date()
    
    let x: CGFloat
    
    let y: CGFloat
    
    static var random: Location {
        return .init(x: .random(in: 0...1), y: .random(in: 0...1))
    }
}
