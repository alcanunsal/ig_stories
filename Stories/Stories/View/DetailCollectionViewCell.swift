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
    var profile:Profile?
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
            progressBar!.isPaused = false
            self.progressBar!.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                //self.progressBar.alpha = 1.0
                self.stackView.alpha = 1.0
            }, completion: nil)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        progressBar!.isPaused = true
        self.progressBar!.isHidden = true
        UIView.animate(withDuration: 0.5, animations: {
            self.stackView.alpha = 0.0
        }, completion: nil)
    }
  
    @objc func cellTapped(sender: UITapGestureRecognizer) {
        print("cellTapped:", profile)
        if sender.state == .ended {
            progressBar?.isHidden = false
            progressBar?.isPaused = false
            //progressBar.isHidden = false
            //stackView.isHidden = false
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
                    delegate?.goToNextStoryGroup(currentStoryGroup: profile!)
                    storyChangedByTapping = false
                }
            }
        }
    }
    
    func goToNextStory(){
        if profile!.storiesSeenCount < profile!.stories.count {
            setImage(imageView: ppImageView, strURL: profile!.profilePicUrl, isPp: true)
            setImage(imageView: fsStoryImageView, strURL: profile!.stories[profile!.storiesSeenCount].contentUrl)
            timestampLabel.text = profile!.stories[profile!.storiesSeenCount].timestamp
            gradientView.addGradientBackground(firstColor: getRandomColor(), secondColor: (fsStoryImageView.image?.averageColor!) ?? getRandomColor())
        }
        progressBar?.isPaused = false
        progressBar!.skip()
    }
    
    func goToPrevStory() {
        setImage(imageView: ppImageView, strURL: profile!.profilePicUrl, isPp: true)
        setImage(imageView: fsStoryImageView, strURL: profile!.stories[profile!.storiesSeenCount].contentUrl)
        timestampLabel.text = profile!.stories[profile!.storiesSeenCount].timestamp
        gradientView.addGradientBackground(firstColor: getRandomColor(), secondColor: (fsStoryImageView.image?.averageColor!) ?? getRandomColor())
        progressBar!.rewind()
        progressBar!.isPaused = false
    }
    
    override func awakeFromNib() {
        print("awakefromnib")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(sender:)))
        addGestureRecognizer(tapGesture)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(sender:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = false
        longPressGesture.delegate = self
        addGestureRecognizer(longPressGesture)
    }
    

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //configureProgressBar()
        ppImageView.layer.cornerRadius = ppImageView.frame.size.width/2
        ppImageView.clipsToBounds = true
        ppImageView.layer.masksToBounds = true
    }
    
    func configureCell() {
        print("configureCell:", profile!.username, profile!.storiesSeenCount)
        userNameLabel.text = profile!.username
        setImage(imageView: ppImageView, strURL: profile!.profilePicUrl, isPp: true)
        var currentStoryIndex = profile!.stories.count-1
        if profile!.storiesSeenCount < profile!.stories.count-1 {
            currentStoryIndex = profile!.storiesSeenCount
        }
        profile?.storiesSeenCount = currentStoryIndex
        setImage(imageView: fsStoryImageView, strURL: profile!.stories[currentStoryIndex].contentUrl)
        timestampLabel.text = profile!.stories[currentStoryIndex].timestamp
        gradientView.addGradientBackground(firstColor: getRandomColor(), secondColor: (fsStoryImageView.image?.averageColor!) ?? getRandomColor())
        var durations:[Double] = []
        for story in profile!.stories {
            if story.contentType == 0 {
                durations.append(5.0)
            } else {
                // video story here
                durations.append(10.0)
            }
        }
        configureProgressBar(numSegments: profile!.stories.count, durations: durations, currentStory: currentStoryIndex)
    }
    
    @IBAction func didTapCell(_ sender: UITapGestureRecognizer) {
        print("touched")
    }
    
    func setImage(imageView: UIImageView, strURL: String, isPp: Bool = false) {
        if !isPp {
            activityIndicator.startAnimating()
            activityIndicator.isHidden = false
        }
        if let url = URL(string:strURL) {
            imageView.af.setImage(withURL: url ,
                                  placeholderImage: UIImage(named: "gray"),
                                  filter: nil,
                                  imageTransition: .crossDissolve(0.2),
                                  completion: { response in
                                        if !isPp {
                                            DispatchQueue.main.async {
                                                self.activityIndicator.stopAnimating()
                                                self.activityIndicator.isHidden = true
                                            }
                                        }
            })
        } else {
            imageView.image = UIImage(named: "gray")
        }
    }
    
    
    func configureProgressBar(numSegments: Int, durations: [Double], currentStory: Int) {
        print("configureProgressBar:", profile!.username, currentStory)
        self.progressBar = SegmentedProgressBar(numberOfSegments: numSegments, duration: durations[0])
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
        self.progressBar!.startAnimation(withDelay: 0.4)
        if currentStory > 0 {
            var currentIndex = currentStory
            print("configureProgressBar CurrentStory>0:", currentStory)
            if currentStory >= (profile!.stories.count) {
                currentIndex = profile!.stories.count-1
            }
            print("configureProgressBar CurrentStory>0 2:", currentIndex)
            for _ in 1...currentIndex {
                self.progressBar!.skip()
            }
        }
        //self.progressBar!.isPaused = false
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
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        delegate?.dismissStories()
    }
    
    
    func getRandomColor() -> UIColor {
        let randomRed:CGFloat = CGFloat(arc4random_uniform(256))
        let randomGreen:CGFloat = CGFloat(arc4random_uniform(256))
        let randomBlue:CGFloat = CGFloat(arc4random_uniform(256))
        return UIColor(red: randomRed/255, green: randomGreen/255, blue: randomBlue/255, alpha: 1.0)
    }
    
    
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
