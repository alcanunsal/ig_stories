//
//  DetailViewController.swift
//  Stories
//
//  Created by alc on 9.06.2021.
//

import UIKit
import AnimatedCollectionViewLayout

class DetailViewController: UIViewController {

    @IBOutlet weak var detailCollectionView: UICollectionView!
    let users = ["alcanunsal", "hamzaisiktas", "mr.hoser", "ertbulbull", "tunga.gungor", "codeway", "serbest", "dizdarkosu", "muhittin", "thepitirciks"]
    var initialTouchPoint = CGPoint(x: 0, y: 0)
    override func viewDidLoad() {
        super.viewDidLoad()
        detailCollectionView.dataSource = self
        detailCollectionView.delegate = self
        let layout = AnimatedCollectionViewLayout()
        layout.animator = CubeAttributesAnimator()
        layout.scrollDirection = .horizontal
        detailCollectionView.collectionViewLayout = layout
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        /*let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)*/
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func didTapView(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .began:
            print("touch began")
        case .ended:
            let touchPoint = sender.location(in: self.view)
            if touchPoint.x < self.view.bounds.size.width/3 {
                print("go to previous story")
            } else if touchPoint.x > 2*self.view.bounds.size.width/3 {
                print("go to next story")
            }
        case .possible, .changed, .cancelled, .failed:
            print("touch other cases")
        @unknown default:
            print("touch default case")
        }
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
    
    /*@objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                print("Swiped right, go to next story group")
            case UISwipeGestureRecognizer.Direction.down:
                print("Swiped down")
            case UISwipeGestureRecognizer.Direction.left:
                print("Swiped left, go to previous story group")
            case UISwipeGestureRecognizer.Direction.up:
                print("Swiped up")
            default:
                break
            }
        }
    }*/

}

extension DetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "CubicCell", for: indexPath) as! DetailCollectionViewCell
        cell.backgroundColor = .clear
        return cell
    }
    
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: detailCollectionView.bounds.size.width, height: detailCollectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
}
