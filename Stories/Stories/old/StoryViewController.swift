//
//  StoryViewController.swift
//  Stories
//
//  Created by alc on 9.06.2021.
//

import UIKit

class StoryViewController: UIViewController {
    var username: String!
    var ppName: String!
    let pics = ["lana", "wild", "lana", "lana", "wild", "lana", "wild", "lana", "lana", "wild"]
    let users = ["alcanunsal", "hamzaisiktas", "mr.hoser", "ertbulbull", "tunga.gungor", "codeway", "serbest", "dizdarkosu", "muhittin", "thepitirciks"]
    /*@IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var progressBarContainerView: UIView!
    
    @IBOutlet weak var xbutton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var topStackView: UIStackView!
    
    @IBOutlet weak var storyImageView: UIImageView!
    */
    @IBOutlet weak var storyCollectionView: UICollectionView!
    /*lazy var progressBar: SegmentedProgressBar = {
        let progressBar = SegmentedProgressBar(numberOfSegments: 4, duration: 5)
        progressBarContainerView.addSubview(progressBar)
        return progressBar
    }()*/
    
    var initialTouchPoint = CGPoint(x: 0, y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storyCollectionView.delegate = self
        storyCollectionView.dataSource = self
        //configureProgressBar()
        /*usernameLabel.text = username
        usernameLabel.numberOfLines = 1
        usernameLabel.sizeToFit()
        profileImageView.image = UIImage(named: profileImageName)
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        timeLabel.text = "17h"*/
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        
        
        /*
         progressBar.frame = CGRect(x: self.progressBarContainerView.frame.origin.x, y: self.progressBarContainerView.frame.origin.y, width: self.progressBarContainerView.frame.size.width*0.90, height: 4)
         */
        // Do any additional setup after loading the view.
    }
    @IBAction func xButtonTouched(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)
        switch sender.state {
            case .began:
                initialTouchPoint = touchPoint
            case .changed:
                if touchPoint.y - initialTouchPoint.y > 0 {
                    self.view.frame = CGRect(x: 0, y: max(0, touchPoint.y-initialTouchPoint.y), width: self.view.frame.size.width, height: self.view.frame.size.height)
                }
            case .ended:
                if touchPoint.y - initialTouchPoint.y > 300 {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                    })
                }
            default:
                break
            }
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

extension StoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = storyCollectionView.dequeueReusableCell(withReuseIdentifier: StoryCollectionViewCell.identifier, for: indexPath) as! StoryCollectionViewCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.storyCollectionView.bounds.size  //to ensure that this works as intended set self.collectionView size be the screen size.
    }
    
    
    
    
}

