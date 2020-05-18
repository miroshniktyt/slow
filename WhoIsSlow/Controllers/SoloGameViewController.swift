//
//  SoloGameViewController.swift
//  WhoIsSlow
//
//  Created by Anton Miroshnyk on 5/11/20.
//  Copyright © 2020 Anton Miroshnyk. All rights reserved.
//

import UIKit

class SoloGameViewController: UIViewController {
    
    private let roundsNumber = 25
    
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
        
        startGame()
    }
    
    @objc func aimTapped() {
        aim.removeFromSuperviewAnimated()
        
        count -= 1
        if count == 0 {
            stopGame()
        } else {
            replaceAim()
        }
    }
    
    func replaceAim() {
        let randomX = CGFloat.random(in: 0...1)
        let randomY = CGFloat.random(in: 0...1)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame
        let randomAreaOrgin = safeAreaFrame.origin.applying(.init(translationX: aimSize / 2, y: aimSize / 2))
        let x = randomX * (safeAreaFrame.size.width - aimSize) + randomAreaOrgin.x
        let y = randomY * (safeAreaFrame.size.height - aimSize) + randomAreaOrgin.y
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
            self.replaceAim()
            self.view.addSubview(self.aim)
        }
    }
    
    func stopGame() {
        aim.removeFromSuperviewAnimated()
        let duration = DateInterval(start: startDate, end: Date()).duration
        let speed = (duration / Double(roundsNumber)).rounded(toPlaces: 3)
        let alert = UIAlertController(title: "Well done!", message: "Your speed is \(speed) taps per seconds", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            self.startGame()
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
