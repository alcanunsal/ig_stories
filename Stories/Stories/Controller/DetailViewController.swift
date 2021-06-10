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
    var profiles: [Profile]?
    var profileSelected: Int?
    var initialTouchPoint = CGPoint(x: 0, y: 0)
    fileprivate var needsDelayedScrolling = false
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.needsDelayedScrolling = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailCollectionView.dataSource = self
        detailCollectionView.delegate = self
        let layout = AnimatedCollectionViewLayout()
        layout.animator = CubeAttributesAnimator()
        layout.scrollDirection = .horizontal
        detailCollectionView.collectionViewLayout = layout
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.needsDelayedScrolling {
            self.needsDelayedScrolling = false
            detailCollectionView.scrollToItem(at: IndexPath(row: profileSelected!, section: 0), at: .right, animated: false)
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
    
    @IBAction func didTapView(_ sender: UITapGestureRecognizer) {
        print("caught in cv")
        /*if sender.state == .began {
            let cell = detailCollectionView.cellForItem(at: detailCollectionView.indexPathsForVisibleItems[0]) as! DetailCollectionViewCell
            cell.progressBar.isPaused = true
            cell.progressBar.isHidden = true
        }
        if sender.state == .ended {
            let indexPath = detailCollectionView.indexPathsForVisibleItems[0]
            let touchPoint = sender.location(in: self.view)
            if touchPoint.x < self.view.bounds.size.width/3 {
                if indexPath.row != 0 {
                    let nextCellIndexPath = IndexPath(row: indexPath.row+1, section: indexPath.section)
                    detailCollectionView.scrollToItem(at: nextCellIndexPath, at: .right, animated: true)
                } else {
                    print("dismiss view 2")
                }
                let previousCellIndexPath = IndexPath(row: indexPath.row-1, section: indexPath.section)
                detailCollectionView.scrollToItem(at: previousCellIndexPath, at: .left, animated: true)
            } else {
                if indexPath.row != profiles!.count-1 {
                    let nextCellIndexPath = IndexPath(row: indexPath.row+1, section: indexPath.section)
                    detailCollectionView.scrollToItem(at: nextCellIndexPath, at: .right, animated: true)
                } else {
                    print("dismiss view 3")
                }
            }
        }*/
    }

}

extension DetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profiles!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "CubicCell", for: indexPath) as! DetailCollectionViewCell
        //cell.backgroundColor = .clear
        cell.profile = profiles![indexPath.row]
        print("cellforitemat:", cell.profile?.username, indexPath)
        cell.configureCell()
        cell.delegate = self
        return cell
    }
    
    
    
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: detailCollectionView.bounds.size.width, height: detailCollectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension DetailViewController: DetailCellDelegate {
    func dismissStories() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func goToPreviousStoryGroup() {
        let currentIndexPath = detailCollectionView.indexPathsForVisibleItems[0]
        if currentIndexPath.row == 0{
            self.dismiss(animated: true, completion: nil)
        } else {
            let prevCellIndexPath = IndexPath(row: currentIndexPath.row-1, section: currentIndexPath.section)
            detailCollectionView.layoutIfNeeded()
            DispatchQueue.main.async {
                self.detailCollectionView.scrollToItem(at: prevCellIndexPath, at: .left, animated: true)
            }
        }
    }
    
    func goToNextStoryGroup() {
        let currentIndexPath = detailCollectionView.indexPathsForVisibleItems[0]
        if currentIndexPath.row == profiles!.count-1 {
            self.dismiss(animated: true, completion: nil)
        } else {
            let nextCellIndexPath = IndexPath(row: currentIndexPath.row+1, section: currentIndexPath.section)
            let rect = self.detailCollectionView.layoutAttributesForItem(at: nextCellIndexPath)?.frame
            detailCollectionView.layoutIfNeeded()
            self.detailCollectionView.scrollRectToVisible(rect!, animated: true)
            //detailCollectionView.scrollToItem(at: nextCellIndexPath, at: .right, animated: true)
            //detailCollectionView.layoutIfNeeded()
        }
        //detailCollectionView.reloadItems(at: [nextCellIndexPath])
        
    }
    
    
}

protocol DetailCellDelegate {
    func goToPreviousStoryGroup()
    func goToNextStoryGroup()
    func dismissStories()
}
