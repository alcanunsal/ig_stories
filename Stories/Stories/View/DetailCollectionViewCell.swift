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
        
        longPressGesture.minimumPressDuration = 0.5
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
    
    func configureCell(withProfile prof:Profile) {
        self.userNameLabel.text = self.profile!.username
        self.gradientView.frame.size = self.fsStoryImageView.frame.size
        setImage(imageView: ppImageView, strURL: profile!.profilePicUrl, isPp: true)
        var currentStoryIndex = profile!.stories.count-1
        if profile!.storiesSeenCount < profile!.stories.count-1 {
            currentStoryIndex = profile!.storiesSeenCount
        }
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
                durations.append(10.0)
            }
        }
        self.progressBar = SegmentedProgressBar(numberOfSegments: self.profile!.stories.count, duration: durations[0])
        self.progressBar!.topColor = UIColor.white
        self.progressBar?.bottomColor = UIColor.white.withAlphaComponent(0.6)
        self.progressBar!.delegate = self
        progressContainerView.addSubview(self.progressBar!)
        self.progressBar!.frame = CGRect(origin: progressContainerView.bounds.origin, size: CGSize(width: self.bounds.width-25, height: 3))
        let constraintTrailing = NSLayoutConstraint(item: progressContainerView!,
                                                    attribute: .trailing,
                                                    relatedBy: .equal,
                                                    toItem: progressBar,
                                                    attribute: .trailing,
                                                    multiplier: 1,
                                                    constant: 0)
        let constraintCenterX = NSLayoutConstraint(item: progressContainerView!,
                                                   attribute: .centerX,
                                                   relatedBy: .equal,
                                                   toItem: progressBar,
                                                   attribute: .centerX,
                                                   multiplier: 1,
                                                   constant: 0)
        progressContainerView.addConstraint(constraintTrailing)
        progressContainerView.addConstraint(constraintCenterX)
        self.progressBar!.startAnimation(withDelay: 0.5)
        if profile!.storiesSeenCount > 0 {
            var currentIndex = profile!.storiesSeenCount
            if profile!.storiesSeenCount >= (profile!.stories.count) {
                currentIndex = profile!.stories.count-1
            }
            if currentIndex > 0 {
                for _ in 1...currentIndex {
                    self.progressBar!.skip()
                }
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
            imageView.af.setImage(withURL: url ,
                                  placeholderImage: nil,
                                  filter: nil,
                                  imageTransition: .crossDissolve(0.1),
                                  completion: { response in
                                    switch response.result {
                                    case .success(_):
                                        if !isPp {
                                            DispatchQueue.main.async {
                                                self.activityIndicator.stopAnimating()
                                                self.activityIndicator.isHidden = true
                                                if self.progressBar!.isPaused {
                                                    self.progressBar!.isPaused = false
                                                    self.setNeedsLayout()
                                                    self.setNeedsDisplay()
                                                }
                                            }
                                        }
                                    case .failure(let err):
                                        print(err)
                                    }
            })
            
        } else {
            imageView.image = UIImage(named: "gray")
        }
    }
    
    func goToNextStory(){
        if profile!.storiesSeenCount < profile!.stories.count {
            fsStoryImageView.image = nil
            setImage(imageView: fsStoryImageView, strURL: profile!.stories[profile!.storiesSeenCount].contentUrl)
            timestampLabel.text = profile!.stories[profile!.storiesSeenCount].timestamp
            gradientView.addGradientBackground(firstColor: UIColor.getRandomColor(), secondColor: (fsStoryImageView.image?.averageColor!) ?? UIColor.getRandomColor())
        }
        progressBar!.skip()
        progressBar?.isPaused = true
    }
    
    func goToPrevStory() {
        fsStoryImageView.image = nil
        setImage(imageView: fsStoryImageView, strURL: profile!.stories[profile!.storiesSeenCount].contentUrl)
        timestampLabel.text = profile!.stories[profile!.storiesSeenCount].timestamp
        gradientView.addGradientBackground(firstColor: UIColor.getRandomColor(), secondColor: (fsStoryImageView.image?.averageColor!) ?? UIColor.getRandomColor())
        progressBar!.rewind()
        progressBar!.isPaused = true
    }
    
    
}

// Handles gestures and taps inside the cell
extension DetailCollectionViewCell {
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        if profile!.storiesSeenCount < profile!.stories.count-1 {
            profile?.storiesSeenCount += 1
        }
        delegate?.dismissDetailViewController(currentStoryGroup: self.profile!)
    }
    
    
    @objc func handleDismiss(sender: UISwipeGestureRecognizer) {
        if sender.direction == .down {
            if profile!.storiesSeenCount < profile!.stories.count-1 {
                profile?.storiesSeenCount += 1
            }
            delegate?.dismissDetailViewController(currentStoryGroup: self.profile!)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        progressBar!.isPaused = true
        self.progressBar!.isHidden = true
        UIView.animate(withDuration: 0.5, animations: {
            self.stackView.alpha = 0.0
        }, completion: nil)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.5, animations: {
            self.stackView.alpha = 1.0
        }, completion: nil)
        self.progressBar?.isHidden = false
        self.progressBar?.isPaused = false
    }
    
    @objc func handleHorizontalSwipe(sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            print("right swipe happening", sender.numberOfTouches)
            delegate?.goToPreviousStoryGroup(currentStoryGroup: self.profile!)
        }
        if sender.direction == .left {
            print("left swipe happening", sender.numberOfTouches)
            delegate?.goToNextStoryGroup(currentStoryGroup: self.profile!)
        }
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            progressBar!.isPaused = false
            self.progressBar!.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                self.stackView.alpha = 1.0
            }, completion: nil)
        }
    }
    
    @objc func cellTapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            progressBar?.isHidden = false
            progressBar?.isPaused = false
            UIView.animate(withDuration: 0.5, animations: {
                self.stackView.alpha = 1.0
            }, completion: nil)
            let touchPoint = sender.location(in: self)
            if touchPoint.x < self.bounds.size.width/3 {
                if profile!.storiesSeenCount > 0 {
                    profile!.storiesSeenCount -= 1
                    storyChangedByTapping = true
                    goToPrevStory()
                    storyChangedByTapping = false
                } else {
                    storyChangedByTapping = true
                    delegate?.goToPreviousStoryGroup(currentStoryGroup: profile!)
                    storyChangedByTapping = false
                }
            } else {
                if profile!.storiesSeenCount <= profile!.stories.count-1 {
                    profile!.storiesSeenCount += 1
                    storyChangedByTapping = true
                    goToNextStory()
                    storyChangedByTapping = false
                } else {
                    storyChangedByTapping = true
                    progressBar?.isPaused = true
                    delegate?.goToNextStoryGroup(currentStoryGroup: profile!)
                    storyChangedByTapping = false
                }
            }
        }
    }
}

extension DetailCollectionViewCell: SegmentedProgressBarDelegate {
    func segmentedProgressBarChangedIndex(index: Int) {
        if !storyChangedByTapping {
            if profile!.storiesSeenCount < profile!.stories.count-1 {
                profile?.storiesSeenCount += 1
            }
            fsStoryImageView.image = nil
            setImage(imageView: fsStoryImageView, strURL: profile!.stories[index].contentUrl)
            timestampLabel.text = profile!.stories[index].timestamp
            gradientView.addGradientBackground(firstColor: UIColor.getRandomColor(), secondColor: (fsStoryImageView.image?.averageColor!) ?? UIColor.getRandomColor())
        }
    }
    
    func segmentedProgressBarFinished() {
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
