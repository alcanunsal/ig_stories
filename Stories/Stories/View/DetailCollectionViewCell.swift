//
//  DetailCollectionViewCell.swift
//  Stories
//
//  Created by alc on 9.06.2021.
//

import UIKit
import Alamofire
import AlamofireImage

class DetailCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    let identifier = "CubicCell"
    
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var ppImageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var progressContainerView: UIView!
    @IBOutlet weak var fsStoryImageView: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    
    private var profile:Profile?
    var delegate:DetailCellDelegate?
    private var storyChangedByTapping = false
    
    var progressBar: SegmentedProgressBar?
    lazy var activityIndicator: UIActivityIndicatorView! = {
        var activityInd = UIActivityIndicatorView(frame: self.gradientView.frame)
        activityInd.color = UIColor.white
        activityInd.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        self.addSubview(activityInd)
        self.bringSubviewToFront(activityInd)
        return activityInd
    } ()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(sender:)))
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleDismiss))
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleHorizontalSwipe))
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleHorizontalSwipe))
        
        tapGesture.delegate = self
        
        addGestureRecognizer(tapGesture)
        
        longPressGesture.minimumPressDuration = 0.7
        longPressGesture.delegate = self
        addGestureRecognizer(longPressGesture)
        
        swipeDownGesture.direction = .down
        swipeDownGesture.delegate = self
        addGestureRecognizer(swipeDownGesture)
        
        swipeLeftGesture.direction = .left
        swipeLeftGesture.delegate = self
        addGestureRecognizer(swipeLeftGesture)
        
        swipeRightGesture.direction = .right
        swipeRightGesture.delegate = self
        addGestureRecognizer(swipeRightGesture)
        
        tapGesture.require(toFail: swipeDownGesture)
        tapGesture.require(toFail: longPressGesture)
        swipeDownGesture.require(toFail: longPressGesture)
        swipeLeftGesture.require(toFail: longPressGesture)
        swipeRightGesture.require(toFail: longPressGesture)
    }
    
    func setProfile(profile:Profile) {
        self.profile = profile
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        ppImageView.layer.cornerRadius = ppImageView.frame.size.width/2
        ppImageView.clipsToBounds = true
        ppImageView.layer.masksToBounds = true
        stackView.alpha = 1.0
        if let _ = self.progressBar {
            if progressBar!.isPaused {
                progressBar?.alpha = 1.0
                progressBar?.isHidden = false
                if fsStoryImageView.image != nil {
                    progressBar?.isPaused = false
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        progressBar?.isPaused = true
        timestampLabel.text = ""
        userNameLabel.text = ""
        ppImageView.image = nil
        fsStoryImageView.image = nil
        ppImageView.af.cancelImageRequest()
        progressBar?.removeFromSuperview()
        progressBar = nil
        fsStoryImageView.af.cancelImageRequest()
    }
    
    func getCurrentStoryIndex() -> Int {
        var currentStoryIndex = profile!.stories.count-1
        if profile!.storiesSeenCount < profile!.stories.count-1 {
            currentStoryIndex = profile!.storiesSeenCount
        }
        return currentStoryIndex
    }
    
    func configureCell(withProfile prof:Profile) {
        self.userNameLabel.text = self.profile!.username
        self.gradientView.frame.size = self.fsStoryImageView.frame.size
        setImage(imageView: ppImageView, strURL: profile!.profilePicUrl, isPp: true)
        let currentStoryIndex = getCurrentStoryIndex()
        profile?.storiesSeenCount = currentStoryIndex
        setImage(imageView: fsStoryImageView, strURL: profile!.stories[currentStoryIndex].contentUrl)
        timestampLabel.text = profile!.stories[currentStoryIndex].timestamp
        gradientView.addGradientBackground(firstColor: UIColor.getRandomColor(), secondColor: (fsStoryImageView.image?.averageColor!) ?? UIColor.getRandomColor())
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func configureProgressBar() {
        if self.progressBar != nil {
            return
        }
        var durations:[Double] = []
        for story in profile!.stories {
            if story.contentType == 0 {
                durations.append(5.0)
            } else {
                // video story here
            }
        }
        self.progressBar = SegmentedProgressBar(numberOfSegments: self.profile!.stories.count, duration: durations[0])
        self.progressBar!.topColor = UIColor.white
        self.progressBar?.bottomColor = UIColor.white.withAlphaComponent(0.6)
        self.progressBar!.delegate = self
        progressContainerView.addSubview(self.progressBar!)
        self.progressBar!.frame = CGRect(origin: progressContainerView.bounds.origin, size: CGSize(width: self.bounds.width-25, height: 3))
        let constraintTrailing = NSLayoutConstraint(item: progressContainerView!, attribute: .trailing,relatedBy: .equal, toItem: progressBar, attribute: .trailing, multiplier: 1, constant: 0)
        let constraintCenterX = NSLayoutConstraint(item: progressContainerView!, attribute: .centerX, relatedBy: .equal, toItem: progressBar, attribute: .centerX, multiplier: 1, constant: 0)
        progressContainerView.addConstraint(constraintTrailing)
        progressContainerView.addConstraint(constraintCenterX)
        self.progressBar!.startAnimation(withDelay: 0.5)
        if profile!.storiesSeenCount > 0 {
            let currentIndex = getCurrentStoryIndex()
            if currentIndex > 0 {
                storyChangedByTapping = true
                for _ in 1...currentIndex {
                    self.progressBar!.skip()
                }
                storyChangedByTapping = false
            }
        }
        self.progressBar!.isPaused = true
    }
    
    func setImage(imageView: UIImageView, strURL: String, isPp: Bool = false) {
        if !isPp {
            if !self.progressBar!.isPaused {
                self.progressBar!.isPaused = true
            }
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
        if let url = URL(string:strURL) {
            imageView.af.setImage(withURL: url, placeholderImage: nil, filter: nil, imageTransition: .crossDissolve(0.2), completion: { response in
                                    switch response.result {
                                    case .success(_):
                                        if !isPp {
                                            DispatchQueue.main.async {
                                                self.activityIndicator.stopAnimating()
                                                self.activityIndicator.isHidden = true
                                                if self.progressBar!.isPaused {
                                                    self.progressBar!.isPaused = false
                                                    //self.setNeedsLayout()
                                                    //self.setNeedsDisplay()
                                                }
                                            }
                                        }
                                    case .failure(let err):
                                        print(err)
                                    }
            })
        } else {
            imageView.image = UIImage(named: "xmark")
        }
    }
    
    func changeStoryContent() {
        fsStoryImageView.image = nil
        setImage(imageView: fsStoryImageView, strURL: profile!.stories[profile!.storiesSeenCount].contentUrl)
        timestampLabel.text = profile!.stories[profile!.storiesSeenCount].timestamp
        gradientView.addGradientBackground(firstColor: UIColor.getRandomColor(), secondColor: (fsStoryImageView.image?.averageColor!) ?? UIColor.getRandomColor())
    }
    
    func goToNextStory(){
        if profile!.storiesSeenCount < profile!.stories.count {
            changeStoryContent()
        }
        progressBar!.skip()
        progressBar?.isPaused = true
    }
    
    func goToPrevStory() {
        changeStoryContent()
        progressBar!.rewind()
        progressBar!.isPaused = true
    }
    
    
}

// Handles gestures and taps inside the cell
extension DetailCollectionViewCell {
    
    func dismissVC() {
        if profile!.storiesSeenCount < profile!.stories.count-1 {
            profile?.storiesSeenCount += 1
        }
        delegate?.dismissDetailViewController(currentStoryGroup: self.profile!)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismissVC()
    }
    
    @objc func handleDismiss(sender: UISwipeGestureRecognizer) {
        if sender.direction == .down {
            dismissVC()
        }
    }
    
    @objc func handleHorizontalSwipe(sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            progressBar?.delegate = nil
            delegate?.goToPreviousStoryGroup(currentStoryGroup: self.profile!)
        }
        if sender.direction == .left {
            progressBar?.delegate = nil
            delegate?.goToNextStoryGroup(currentStoryGroup: self.profile!)
        }
    }
    
    /// Changes header (top stack view and progress bar) visibility and starts/stops progress bar according to parameters
    func changeHeaderVisibility(makeVisible:Bool, animated:Bool) {
        if makeVisible {
            // header (username, timestamp, profile pic etc) will be made visible
            self.stackView.alpha = 1.0
            self.progressBar?.alpha = 1.0
            self.progressBar?.isPaused = false
        } else {
            // header (username, timestamp, profile pic etc) will be hidden
            progressBar!.isPaused = true
            if animated {
                UIView.animate(withDuration: 0.5, animations: {
                    self.stackView.alpha = 0.0
                    self.progressBar?.alpha = 0.0
                }, completion: nil)
            } else {
                self.stackView.alpha = 0.0
                self.progressBar?.alpha = 0.0
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        changeHeaderVisibility(makeVisible: false, animated: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        changeHeaderVisibility(makeVisible: true, animated: false)
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            changeHeaderVisibility(makeVisible: true, animated: false)
        }
    }
    
    @objc func cellTapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            storyChangedByTapping = true
            changeHeaderVisibility(makeVisible: true, animated: false)
            let touchPoint = sender.location(in: self)
            if touchPoint.x < self.bounds.size.width/3 {
                if profile!.storiesSeenCount > 0 {
                    profile!.storiesSeenCount -= 1
                    goToPrevStory()
                } else {
                    progressBar?.delegate = nil
                    progressBar?.isPaused = true
                    delegate?.goToPreviousStoryGroup(currentStoryGroup: profile!)
                }
            } else {
                if profile!.storiesSeenCount <= profile!.stories.count-1 {
                    profile!.storiesSeenCount += 1
                    goToNextStory()
                } else {
                    progressBar?.isPaused = true
                    progressBar?.delegate = nil
                    delegate?.goToNextStoryGroup(currentStoryGroup: profile!)
                }
            }
            storyChangedByTapping = false
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer && otherGestureRecognizer is UILongPressGestureRecognizer {
            return false
        }
        return true
    }
}

extension DetailCollectionViewCell: SegmentedProgressBarDelegate {
    func segmentedProgressBarChangedIndex(index: Int) {
        if !storyChangedByTapping {
            if profile!.storiesSeenCount < profile!.stories.count-1 {
                profile?.storiesSeenCount += 1
            }
            changeStoryContent()
        }
    }
    
    func segmentedProgressBarFinished() {
        progressBar?.delegate = nil
        delegate?.goToNextStoryGroup(currentStoryGroup: profile!)
    }
}


protocol DetailCellDelegate {
    func goToPreviousStoryGroup(currentStoryGroup:Profile)
    func goToNextStoryGroup(currentStoryGroup:Profile)
    func dismissDetailViewController(currentStoryGroup:Profile)
    func userInteractionInProgress()
    func userInteractionEnded()
}
