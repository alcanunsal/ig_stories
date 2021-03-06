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
    fileprivate var needsDelayedScrolling = false
    var delegate: DetailViewControllerDelegate?
    
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.needsDelayedScrolling = true
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailCollectionView.dataSource = self
        detailCollectionView.delegate = self
        // Cubic transition among collection view cells
        let layout = AnimatedCollectionViewLayout()
        layout.animator = CubeAttributesAnimator()
        layout.scrollDirection = .horizontal
        detailCollectionView.collectionViewLayout = layout
        detailCollectionView.isUserInteractionEnabled = true
        detailCollectionView.isPrefetchingEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        // animations of cubic transition and progress bar clash in the first shown cell if not delayed
        super.viewDidLayoutSubviews()
        if self.needsDelayedScrolling {
            self.needsDelayedScrolling = false
            detailCollectionView.scrollToItem(at: IndexPath(row: profileSelected!, section: 0), at: .right, animated: false)
            detailCollectionView.setNeedsLayout()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let firstCell = detailCollectionView.fullyVisibleCells[0] as? DetailCollectionViewCell {
            firstCell.isFullyVisible = true
        }
    }
    
    func updateProfilesData(withData data:Profile) {
        profiles![profiles!.firstIndex{$0.username == data.username}!] = data
    }
}

extension DetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profiles!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = detailCollectionView.dequeueReusableCell(withReuseIdentifier: "CubicCell", for: indexPath) as! DetailCollectionViewCell
        cell.setProfile(profile: profiles![indexPath.row])
        cell.configureProgressBar()
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if detailCollectionView.fullyVisibleCells.count > 0 {
            for cell in detailCollectionView.fullyVisibleCells {
                if let c = cell as? DetailCollectionViewCell {
                    c.isFullyVisible = true
                }
            }
        } else {
            print("no visible cells to show")
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.detailCollectionView.isUserInteractionEnabled = true
        if detailCollectionView.fullyVisibleCells.count > 0 {
            for cell in detailCollectionView.fullyVisibleCells {
                if let c = cell as? DetailCollectionViewCell {
                    c.isFullyVisible = true
                }
            }
        } else {
            print("no visible cells to show")
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let visibleIndexPath = detailCollectionView.indexPathsForVisibleItems[0]
        let leftIndexPath = IndexPath(row: visibleIndexPath.row-1, section: visibleIndexPath.section)
        let rightIndexPath = IndexPath(row: visibleIndexPath.row+1, section: visibleIndexPath.section)
        let indexPaths = [leftIndexPath, visibleIndexPath, rightIndexPath]
        for indexPath in indexPaths {
            if indexPath.row >= 0 && indexPath.row < profiles!.count {
                if let cell = detailCollectionView.cellForItem(at: indexPath) as? DetailCollectionViewCell {
                    cell.isFullyVisible = false
                }
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let c = cell as? DetailCollectionViewCell {
            c.progressBar?.delegate = nil
            updateProfilesData(withData: c.getProfile())
        }
    }
}

extension DetailViewController: DetailCellDelegate {
    
    func dismissDetailViewController(currentStoryGroup: Profile) {
        updateProfilesData(withData: currentStoryGroup)
        delegate?.detailViewControllerWillDismiss(data: profiles!)
        self.dismiss(animated: true, completion: nil)
    }

    func goToPreviousStoryGroup(currentStoryGroup:Profile) {
        let currentIndexPath = detailCollectionView.indexPathsForVisibleItems[0]
        updateProfilesData(withData: currentStoryGroup)
        if currentIndexPath.row == 0{
            dismissDetailViewController(currentStoryGroup: currentStoryGroup)
        } else {
            let prevCellIndexPath = IndexPath(row: currentIndexPath.row-1, section: currentIndexPath.section)
            let rect = self.detailCollectionView.layoutAttributesForItem(at: prevCellIndexPath)?.frame
            self.detailCollectionView.isUserInteractionEnabled = false
            self.detailCollectionView.scrollRectToVisible(rect!, animated: true)
        }
    }
    
    func goToNextStoryGroup(currentStoryGroup:Profile) {
        let currentIndexPath = detailCollectionView.indexPathsForVisibleItems[0]
        updateProfilesData(withData: currentStoryGroup)
        if currentIndexPath.row == profiles!.count-1 {
            dismissDetailViewController(currentStoryGroup: currentStoryGroup)
        } else {
            let nextCellIndexPath = IndexPath(row: currentIndexPath.row+1, section: currentIndexPath.section)
            let rect = self.detailCollectionView.layoutAttributesForItem(at: nextCellIndexPath)?.frame
            self.detailCollectionView.isUserInteractionEnabled = false
            self.detailCollectionView.scrollRectToVisible(rect!, animated: true)
        }
    }
    
    func userInteractionInProgress() {
        self.detailCollectionView.isUserInteractionEnabled = false
        self.detailCollectionView.isScrollEnabled = false
        let count = self.view.gestureRecognizers?.count ?? 0
        for i in 0..<count {
            self.view.gestureRecognizers![i].isEnabled = false
        }
    }
    
    func userInteractionEnded() {
        self.detailCollectionView.isScrollEnabled = true
        self.detailCollectionView.isUserInteractionEnabled = true
        let count = self.view.gestureRecognizers?.count ?? 0
        for i in 0..<count {
            self.view.gestureRecognizers![i].isEnabled = true
        }
    }
}

// functions to pause and restore state when application goes to background and comes to foreground
extension DetailViewController {
    @objc private func applicationWillResignActive() {
        for cell in detailCollectionView.visibleCells {
            if let c = cell as? DetailCollectionViewCell {
                c.pauseProgressBar()
            }
        }
    }

    @objc private func applicationDidBecomeActive() {
        for cell in detailCollectionView.visibleCells {
            if let c = cell as? DetailCollectionViewCell {
                c.continueProgressBar()
            }
        }
    }
}

protocol DetailViewControllerDelegate {
    func detailViewControllerWillDismiss(data: [Profile])
}
