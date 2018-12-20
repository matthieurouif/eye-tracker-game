//
//  CameraViewController.swift
//  Eye-Tracker
//
//  Created by Matthieu Rouif on 20/12/2018.
//  Copyright © 2018 Dr1ven. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {

    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private var setupResult: SessionSetupResult = .success

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch self.setupResult {
        case .success:
            // Only set up observers and start running the session if setup succeeded.
            self.resumeSessionSuccessfully()
        case .notAuthorized:
            let message = NSLocalizedString("Eye Tracker doesn’t have permission to use the camera, please change privacy settings", comment: "Alert message when the user has denied access to the camera")
            let alertController = UIAlertController(title: "AVMetadataRecordPlay", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .`default`, handler: { _ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            }))
            self.present(alertController, animated: true, completion: nil)
        case .configurationFailed:
            let message = NSLocalizedString("Unable to capture eyes", comment: "Alert message when something goes wrong during capture session configuration")
            let alertController = UIAlertController(title: "AVMetadataRecordPlay", message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func resumeSessionSuccessfully() {
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
