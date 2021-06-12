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
    var delegate: DetailViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        print("progressbar--viewwillappear")
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
       // view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //self.needsDelayedScrolling = true
        print("progressbar--viewwilllayoutsubviews")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("progressbar--viewdidlayoutsubviews")
        if self.needsDelayedScrolling {
            self.needsDelayedScrolling = false
            detailCollectionView.scrollToItem(at: IndexPath(row: profileSelected!, section: 0), at: .right, animated: false)
            detailCollectionView.setNeedsLayout()
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
    
   
    
   /* @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.view?.window)
        if sender.state == .recognized {
            initialTouchPoint = touchPoint
            if let cellShown = detailCollectionView.visibleCells[0] as? DetailCollectionViewCell {
                let grs = cellShown.gestureRecognizers?.count ?? 0
                for i in 0..<grs {
                    print("gesture recogniz3er")
                    cellShown.gestureRecognizers![i].isEnabled = false
                }
            }
        }
        switch sender.state {
            case .changed:
                if touchPoint.y - initialTouchPoint.y > 0 {
                    self.view.frame = CGRect(x: 0, y: max(0, touchPoint.y-initialTouchPoint.y), width: self.view.frame.size.width, height: self.view.frame.size.height)
                }
            case .ended:
                if touchPoint.y - initialTouchPoint.y > 100 {
                    if let cellShown = detailCollectionView.visibleCells[0] as? DetailCollectionViewCell {
                        profiles![detailCollectionView.indexPathsForVisibleItems[0].row] = cellShown.profile!
                    }
                    
                    delegate?.detailViewControllerWillDismiss(data: profiles!)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                    })
                }
                if let cellShown = detailCollectionView.visibleCells[0] as? DetailCollectionViewCell {
                    let grs = cellShown.gestureRecognizers?.count ?? 0
                    for i in 0..<grs {
                        print("gesture recogniz3er")
                        cellShown.gestureRecognizers![i].isEnabled = true
                    }
                }
            default:
                break
            }
    }*/
    
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
        print("cellforitemat:", cell.profile!.username, cell.profile!.storiesSeenCount)
        cell.configureCell()
        cell.delegate = self
        return cell
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("progressbar--scrollviewfinishedanimating")
        let currentIndexPath = detailCollectionView.indexPathsForVisibleItems[0]
        if let cell = detailCollectionView.cellForItem(at: currentIndexPath) as? DetailCollectionViewCell {
            //cell.progressBar!.startAnimation()
            self.detailCollectionView.isUserInteractionEnabled = true
            cell.configureProgressBar(numSegments: cell.profile!.stories.count, durations: [5])
            print("progressbar--scrollviewfinishedanimating2")
        }
    }
    
    
    
    
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: detailCollectionView.bounds.size.width, height: detailCollectionView.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension DetailViewController: DetailCellDelegate {
    
    func dismissDetailViewController(currentStoryGroup: Profile) {
        profiles![profiles!.firstIndex{$0.username == currentStoryGroup.username}!] = currentStoryGroup
        delegate?.detailViewControllerWillDismiss(data: profiles!)
        self.dismiss(animated: true, completion: nil)
    }

    func goToPreviousStoryGroup(currentStoryGroup:Profile) {
        print("gotoPrevStoryGroup")
        let currentIndexPath = detailCollectionView.indexPathsForVisibleItems[0]
        print("currentindex:",profiles![currentIndexPath.row].username, profiles![currentIndexPath.row].storiesSeenCount)
        //profiles![currentIndexPath.row] = currentStoryGroup
        profiles![profiles!.firstIndex{$0.username == currentStoryGroup.username}!] = currentStoryGroup
        if currentIndexPath.row == 0{
            self.dismiss(animated: true, completion: nil)
        } else {
            let prevCellIndexPath = IndexPath(row: currentIndexPath.row-1, section: currentIndexPath.section)
            let rect = self.detailCollectionView.layoutAttributesForItem(at: prevCellIndexPath)?.frame
            detailCollectionView.layoutIfNeeded()
            self.detailCollectionView.isUserInteractionEnabled = false
            self.detailCollectionView.scrollRectToVisible(rect!, animated: true)
            detailCollectionView.setNeedsLayout()
        }
    }
    
    func goToNextStoryGroup(currentStoryGroup:Profile) {
        print("gotoNextStoryGroup")
        let currentIndexPath = detailCollectionView.indexPathsForVisibleItems[0]
        print("currentindex:",profiles![currentIndexPath.row].username, profiles![currentIndexPath.row].storiesSeenCount)
        profiles![profiles!.firstIndex{$0.username == currentStoryGroup.username}!] = currentStoryGroup
        //profiles![currentIndexPath.row] = currentStoryGroup
        if currentIndexPath.row == profiles!.count-1 {
            self.dismiss(animated: true, completion: nil)
        } else {
            let nextCellIndexPath = IndexPath(row: currentIndexPath.row+1, section: currentIndexPath.section)
            let rect = self.detailCollectionView.layoutAttributesForItem(at: nextCellIndexPath)?.frame
            detailCollectionView.layoutIfNeeded()
            self.detailCollectionView.isUserInteractionEnabled = false
            self.detailCollectionView.scrollRectToVisible(rect!, animated: true)
            detailCollectionView.setNeedsLayout()
            
            //detailCollectionView.scrollToItem(at: nextCellIndexPath, at: .right, animated: true)
            //detailCollectionView.layoutIfNeeded()
        }
        //detailCollectionView.reloadItems(at: [nextCellIndexPath])
        
    }
    
    func userInteractionInProgress() {
        print("in userInteractionInProgress")
        self.detailCollectionView.isUserInteractionEnabled = false
        self.detailCollectionView.isScrollEnabled = false
        let count = self.view.gestureRecognizers?.count ?? 0
        for i in 0..<count {
            print("in userInteractionInProgress", i)
            self.view.gestureRecognizers![i].isEnabled = false
        }
    }
    
    func userInteractionEnded() {
        self.detailCollectionView.isScrollEnabled = false
        self.detailCollectionView.isUserInteractionEnabled = true
        let count = self.view.gestureRecognizers?.count ?? 0
        for i in 0..<count {
            self.view.gestureRecognizers![i].isEnabled = true
        }
    }
    
    
}

protocol DetailViewControllerDelegate {
    func detailViewControllerWillDismiss(data: [Profile])
}
