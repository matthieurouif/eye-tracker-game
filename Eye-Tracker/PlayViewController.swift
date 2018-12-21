//
//  ViewController.swift
//  Eye-Tracker
//
//  Created by Matthieu Rouif on 19/12/2018.
//  Copyright © 2018 Dr1ven. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import WebKit

class PlayViewController: CameraViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var eyePositionIndicatorView: UIView!
    @IBOutlet weak var eyePositionIndicatorCenterView: UIView!
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
    
    var faceNode: SCNNode = SCNNode()
    
    var eyeRightNode: SCNNode = {
        let geometry = SCNCone(topRadius: 0.005, bottomRadius: 0, height: 0.2)
        geometry.radialSegmentCount = 3
        geometry.firstMaterial?.diffuse.contents = UIColor.blue
        let node = SCNNode()
        node.geometry = geometry
        node.eulerAngles.x = -.pi / 2
        node.position.z = 0.1
        let parentNode = SCNNode()
        parentNode.addChildNode(node)
        return parentNode
    }()
    
    var lookAtTargetEyeRightNode: SCNNode = SCNNode()

    // actual physical size of iPhoneX screen
    let phoneScreenSize = CGSize(width: 0.0623908297, height: 0.135096943231532)
    
    // actual point size of iPhoneX screen
    let phoneScreenPointSize = CGSize(width: 375, height: 812)
    
    var virtualPhoneNode: SCNNode = SCNNode()
    
    var virtualScreenNode: SCNNode = {
        let screenGeometry = SCNPlane(width: 1, height: 1)
        screenGeometry.firstMaterial?.isDoubleSided = true
        screenGeometry.firstMaterial?.diffuse.contents = UIColor.green
        return SCNNode(geometry: screenGeometry)
    }()
    
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
        
        self.setupARSession()
    }

    func setupUI() {
        //background
        self.view.backgroundColor = Appearance.pinkColor
        self.fireButton.backgroundColor = Appearance.whiteColor
        
        //score label
        self.scoreLabel.font = UIFont(name: "Futura-CondensedExtraBold", size: 160)
        self.scoreLabel.textColor = Appearance.lightPinkColor
        
        //target view
        self.targetView.backgroundColor = Appearance.blueColor
        
        //shoot button
        self.fireButton.setTitle("SHOOT WHERE YOU LOOK", for: .normal)
        self.fireButton.setTitleColor(Appearance.veryLightPinkColor, for: .normal)
    }
    
    func setupARSession() {
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        
        // Setup Scenegraph
        sceneView.scene.rootNode.addChildNode(faceNode)
        sceneView.scene.rootNode.addChildNode(virtualPhoneNode)
        // Set screen as if it was center on the front camera position
        //        virtualScreenNode.position = SCNVector3(0, 0.135096943231532/2.0, 0)
        virtualPhoneNode.addChildNode(virtualScreenNode)
        faceNode.addChildNode(eyeRightNode)
        eyeRightNode.addChildNode(lookAtTargetEyeRightNode)
        
        // Set LookAtTargetEye at 2 meters away from the center of eyeballs to create segment vector
        lookAtTargetEyeRightNode.position.z = 2

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
        
        // Create a session configuration
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func restartGame() {
        self.score = 0
    }
    
    func updateScore() {
    }
    
    func moveTarget() {
        
    }
    
    @IBAction func fireAction() {
        if (eyePositionIndicatorCenterView.frame.intersects(targetView.frame)) {
            print("collision")
        }
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        faceNode.transform = node.transform
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        update(withFaceAnchor: faceAnchor)
    }
    
    // MARK: - update(ARFaceAnchor)
    
    func update(withFaceAnchor anchor: ARFaceAnchor) {
        
        eyeRightNode.simdTransform = anchor.leftEyeTransform
        
        var eyeRLookAt = CGPoint()
        
        DispatchQueue.main.async {
            
            // Perform Hit test using the ray segments that are drawn by the center of the eyeballs to somewhere two meters away at direction of where users look at to the virtual plane that place at the same orientation of the phone screen
            
            let phoneScreenEyeRHitTestResults = self.virtualScreenNode.hitTestWithSegment(from: self.lookAtTargetEyeRightNode.worldPosition, to: self.eyeRightNode.worldPosition, options: nil)
            
            for result in phoneScreenEyeRHitTestResults {
                print(result.localCoordinates.x)
                eyeRLookAt.x = CGFloat(result.localCoordinates.x) / (self.phoneScreenSize.width) * self.phoneScreenPointSize.width
                
                eyeRLookAt.y = -CGFloat(result.localCoordinates.y) / (self.phoneScreenSize.height) * self.phoneScreenPointSize.height
            }
            
            // update indicator position
            self.eyePositionIndicatorView.transform = CGAffineTransform(translationX: eyeRLookAt.x, y: eyeRLookAt.y)
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        virtualPhoneNode.transform = (sceneView.pointOfView?.transform)!
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        faceNode.transform = node.transform
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        update(withFaceAnchor: faceAnchor)
    }

}
