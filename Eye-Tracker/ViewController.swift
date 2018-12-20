//
//  ViewController.swift
//  Eye-Tracker
//
//  Created by Matthieu Rouif on 19/12/2018.
//  Copyright © 2018 Dr1ven. All rights reserved.
//

import UIKit

class ViewController: CameraViewController {
    
    
    @IBOutlet weak var fireButton: UIButton!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var targetView: TargetView!
    
    @IBOutlet weak var gameView: UIView!

    var score: Int = 0 {
        didSet {
            self.scoreLabel.text = "\(score)"
        }
    }
    
    var animator: UIDynamicAnimator?
    
    private enum GameStatus {
        case playing
        case paused
        case ready
        case loading
    }
    
    private var gameStatus = GameStatus.loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setupUI()
        
        //configure animator
        animator = UIDynamicAnimator(referenceView: self.gameView)
        
        //collision Behavior
        let collisionBehavior = UICollisionBehavior(items: [targetView])
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        animator?.addBehavior(collisionBehavior)
        
        //gravity Behavior
        let gravityBehavior = UIGravityBehavior(items: [targetView])
        animator?.addBehavior(gravityBehavior)
    }

    func setupUI() {
        //background
        self.view.backgroundColor = Appearance.pinkColor
        self.fireButton.backgroundColor = Appearance.whiteColor
        
        //score label
        self.scoreLabel.font = UIFont(name: "Futura-CondensedExtraBold", size: 160)
        self.scoreLabel.textColor = Appearance.lightPinkColor
        
        //target view
        self.targetView.backgroundColor = Appearance.veryDarkPinkColor
        
        //shoot button
        self.fireButton.setTitle("SHOOT WHERE YOU LOOK", for: .normal)
        self.fireButton.setTitleColor(Appearance.veryLightPinkColor, for: .normal)
    }
    
    override func resumeSessionSuccessfully() {
        switch self.gameStatus {
        case .playing:
            print("already playing")
        case .paused:
            self.gameStatus = .playing
            print("resume timer")
        case .ready:
            self.gameStatus = .playing
            self.score = 0
        case .loading:
            self.gameStatus = .playing
            self.score = 0
            print("start playing")
        }
    }
    
    func restartGame() {
        self.score = 0
    }
    
    func updateScore() {
    }
    
    func moveTarget() {
        
    }
}

