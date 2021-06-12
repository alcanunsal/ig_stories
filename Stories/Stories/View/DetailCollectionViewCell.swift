//
//  DetailCollectionViewCell.swift
//  Stories
//
//  Created by alc on 9.06.2021.
//

import UIKit
import Alamofire
import AlamofireImage

class DetailCollectionViewCell: UICollectionViewCell {
    let identifier = "CubicCell"
    private var profile:Profile?
    var delegate:DetailCellDelegate?
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var ppImageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var progressContainerView: UIView!
    @IBOutlet weak var fsStoryImageView: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var storyChangedByTapping = false
    
    var progressBar: SegmentedProgressBar?
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            print("userInteractionInProgress longtap ended")
            progressBar!.isPaused = false
            self.progressBar!.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                //self.progressBar.alpha = 1.0
                self.stackView.alpha = 1.0
            }, completion: nil)
            //delegate!.userInteractionEnded()
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //delegate?.userInteractionInProgress()
        print("touchesBegan")
        progressBar!.isPaused = true
        self.progressBar!.isHidden = true
        UIView.animate(withDuration: 0.5, animations: {
            self.stackView.alpha = 0.0
        }, completion: nil)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //delegate?.userInteractionEnded()
        self.stackView.alpha = 1.0
        print("touches ended")
        self.progressBar?.isHidden = false
        self.progressBar?.isPaused = false
    }
  
    @objc func cellTapped(sender: UITapGestureRecognizer) {
        print("progressbar--:", profile?.username ?? "")
        print("uitapgesturerecognizer state ", sender.state.rawValue)
        if sender.state == .ended {
            progressBar?.isHidden = false
            progressBar?.isPaused = false
            UIView.animate(withDuration: 0.5, animations: {
                //self.progressBar.alpha = 1.0
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
                    //profile?.storiesSeenCount+=1
                    storyChangedByTapping = true
                    progressBar?.isPaused = true
                    print("tapgesture stopped")
                    delegate?.goToNextStoryGroup(currentStoryGroup: profile!)
                    storyChangedByTapping = false
                }
            }
            //delegate!.userInteractionEnded()
        }
    }
    
    func goToNextStory(){
        if profile!.storiesSeenCount < profile!.stories.count {
            setImage(imageView: ppImageView, strURL: profile!.profilePicUrl, isPp: true)
            setImage(imageView: fsStoryImageView, strURL: profile!.stories[profile!.storiesSeenCount].contentUrl)
            timestampLabel.text = profile!.stories[profile!.storiesSeenCount].timestamp
            gradientView.addGradientBackground(firstColor: getRandomColor(), secondColor: (fsStoryImageView.image?.averageColor!) ?? getRandomColor())
        }
        //progressBar?.isPaused = false
        progressBar!.skip()
        progressBar?.isPaused = true
    }
    
    func goToPrevStory() {
        setImage(imageView: ppImageView, strURL: profile!.profilePicUrl, isPp: true)
        setImage(imageView: fsStoryImageView, strURL: profile!.stories[profile!.storiesSeenCount].contentUrl)
        timestampLabel.text = profile!.stories[profile!.storiesSeenCount].timestamp
        gradientView.addGradientBackground(firstColor: getRandomColor(), secondColor: (fsStoryImageView.image?.averageColor!) ?? getRandomColor())
        progressBar!.rewind()
        progressBar!.isPaused = true
    }
    
    override func awakeFromNib() {
        print("awakefromnib")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(sender:)))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = false
        longPressGesture.delegate = self
        addGestureRecognizer(longPressGesture)
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleDismiss))
        swipeGesture.direction = .down
        swipeGesture.delegate = self
        addGestureRecognizer(swipeGesture)
        tapGesture.require(toFail: swipeGesture)
        tapGesture.require(toFail: longPressGesture)
        //longPressGesture.require(toFail: swipeGesture)
        //swipeGesture.require(toFail: tapGesture)
        swipeGesture.require(toFail: longPressGesture)
    }
    
    @objc func handleDismiss(sender: UISwipeGestureRecognizer) {
        if sender.direction == .down {
            if profile!.storiesSeenCount < profile!.stories.count-1 {
                profile?.storiesSeenCount += 1
            }
            delegate?.dismissDetailViewController(currentStoryGroup: self.profile!)
        }
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        print("layputsubviews")
        super.layoutSubviews()
        ppImageView.layer.cornerRadius = ppImageView.frame.size.width/2
        ppImageView.clipsToBounds = true
        ppImageView.layer.masksToBounds = true
        stackView.alpha = 1.0
        activityIndicator.isHidden = true
        if let _ = self.progressBar {
            if progressBar!.isPaused {
                progressBar?.alpha = 1.0
                //progressBar?.isPaused = false
                progressBar?.isHidden = false
            }
        }
        
    }
    
    func setProfile(profile:Profile) {
        self.profile = profile
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
        gradientView.addGradientBackground(firstColor: getRandomColor(), secondColor: (fsStoryImageView.image?.averageColor!) ?? getRandomColor())
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
            for _ in 1...currentIndex {
                self.progressBar!.skip()
            }
        }
        print("here-1")
        self.progressBar!.isPaused = true
    }
    
    func setImage(imageView: UIImageView, strURL: String, isPp: Bool = false) {
        if !isPp {
            print("here0: ", self.progressBar?.isPaused)
            if !self.progressBar!.isPaused {
                self.progressBar!.isPaused = true
            }
            //activityIndicator.startAnimating()
            //activityIndicator.isHidden = false
        }
        //fsStoryImageView.contentMode = .scaleToFill
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
                                                //self.activityIndicator.stopAnimating()
                                                //self.activityIndicator.isHidden = true
                                                //self.fsStoryImageView.contentMode = .scaleAspectFit
                                                print("here: is paused:", self.progressBar?.isPaused)
                                                if self.progressBar!.isPaused {
                                                    print("here2")
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
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        progressBar?.isPaused = true
        //timestampLabel.text = ""
        //userNameLabel.text = ""
        //ppImageView.image = nil
        //fsStoryImageView.image = nil
        ppImageView.af.cancelImageRequest()
        progressBar?.removeFromSuperview()
        progressBar = nil
        fsStoryImageView.af.cancelImageRequest()
        print("prepareforreuse")
    }
    
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        if profile!.storiesSeenCount < profile!.stories.count-1 {
            profile?.storiesSeenCount += 1
        }
        delegate?.dismissDetailViewController(currentStoryGroup: self.profile!)
    }
    
    
    func getRandomColor() -> UIColor {
        let randomRed:CGFloat = CGFloat(arc4random_uniform(256))
        let randomGreen:CGFloat = CGFloat(arc4random_uniform(256))
        let randomBlue:CGFloat = CGFloat(arc4random_uniform(256))
        return UIColor(red: randomRed/255, green: randomGreen/255, blue: randomBlue/255, alpha: 1.0)
    }
    
    
}

extension DetailCollectionViewCell: UIGestureRecognizerDelegate {
   /*func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if otherGestureRecognizer is UISwipeGestureRecognizer {
            return true
        }
        return false

        /*if (gestureRecognizer == mainScene.panRecognizer || gestureRecognizer == mainScene.pinchRecognizer) && otherGestureRecognizer == mainScene.tapRecognizer {
            return true
        }*/
    }*/
    
    /*func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer {
            return true
        }
        return false
    }*/

}

extension DetailCollectionViewCell: SegmentedProgressBarDelegate {
    func segmentedProgressBarChangedIndex(index: Int) {
        if !storyChangedByTapping {
            if profile!.storiesSeenCount < profile!.stories.count-1 {
                profile?.storiesSeenCount += 1
            }
            setImage(imageView: fsStoryImageView, strURL: profile!.stories[index].contentUrl)
            timestampLabel.text = profile!.stories[index].timestamp
            gradientView.addGradientBackground(firstColor: getRandomColor(), secondColor: (fsStoryImageView.image?.averageColor!) ?? getRandomColor())
        }
    }
    
    func segmentedProgressBarFinished() {
        //prepareForReuse()
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
