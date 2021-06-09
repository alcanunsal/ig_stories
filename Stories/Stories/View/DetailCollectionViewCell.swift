//
//  DetailCollectionViewCell.swift
//  Stories
//
//  Created by alc on 9.06.2021.
//

import UIKit

class DetailCollectionViewCell: UICollectionViewCell {
    let identifier = "CubicCell"
    
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var ppImageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var progressContainerView: UIView!
    @IBOutlet weak var fsStoryImageView: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    
    lazy var progressBar: SegmentedProgressBar = {
        let progressBar = SegmentedProgressBar(numberOfSegments: 1, duration: 5)
        progressContainerView.addSubview(progressBar)
        progressContainerView.bringSubviewToFront(progressContainerView)
        return progressBar
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureProgressBar()
        fsStoryImageView.image = UIImage(named: "lana")
        ppImageView.layer.cornerRadius = ppImageView.frame.size.width/2
        ppImageView.clipsToBounds = true
        ppImageView.layer.masksToBounds = true
        gradientView.addGradientBackground(firstColor: getRandomColor(), secondColor: (UIImage(named: "lana")?.averageColor)!)
    }
    
    func configureProgressBar() {
        progressBar.frame = CGRect(origin: progressContainerView.bounds.origin, size: CGSize(width: self.bounds.width-25, height: 3))
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
        progressBar.startAnimation()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        progressBar.rewind()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        print("dismiss view controller now")
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
        
    }
    
    func segmentedProgressBarFinished() {
        
    }
    
    
}
