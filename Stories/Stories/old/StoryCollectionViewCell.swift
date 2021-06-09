//
//  StoryCollectionViewCell.swift
//  Stories
//
//  Created by alc on 9.06.2021.
//

import UIKit

class StoryCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "StoryCell"
    @IBOutlet weak var storyImageView: UIImageView!
    

    
    /*lazy var progressBar: SegmentedProgressBar = {
        let progressBar = SegmentedProgressBar(numberOfSegments: 4, duration: 5)
        progressBarContainerView.addSubview(progressBar)
        return progressBar
    }()*/
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //ppImageView.image = nil
        configSubviews()
    }
    
    func configSubviews(){
        //storyImageView.image = UIImage(named: "etiler")
        /*usernameLabel.text = "alcanunsal"
        usernameLabel.numberOfLines = 1
        usernameLabel.sizeToFit()
        ppImageView.image = UIImage(named: "lana")
        ppImageView.layer.cornerRadius = ppImageView.frame.size.width/2
        timeLabel.text = "17h"*/
    }
    
    func configureProgressBar() {

        /*progressBar.frame = CGRect(origin: progressBarContainerView.bounds.origin,
                                   size: CGSize(width: self.bounds.width-25, height: 3))
        let constraintTrailing = NSLayoutConstraint(item: progressBarContainerView!,
                                                    attribute: .trailing,
                                                    relatedBy: .equal,
                                                    toItem: progressBar,
                                                    attribute: .trailing,
                                                    multiplier: 1,
                                                    constant: 0)
        let constraintCenterX = NSLayoutConstraint(item: progressBarContainerView!,
                                                   attribute: .centerX,
                                                   relatedBy: .equal,
                                                   toItem: progressBar,
                                                   attribute: .centerX,
                                                   multiplier: 1,
                                                   constant: 0)
        progressBarContainerView.addConstraint(constraintTrailing)
        progressBarContainerView.addConstraint(constraintCenterX)
        /*NSLayoutConstraint.activate([
            progressBar.widthAnchor.constraint(equalTo: progressBarContainerView.widthAnchor, multiplier: 0.95),
            progressBar.heightAnchor.constraint(equalToConstant: 3),
            progressBar.centerXAnchor.constraint(equalTo: progressBarContainerView.centerXAnchor),
            progressBar.centerYAnchor.constraint(equalTo: progressBarContainerView.centerYAnchor)
        ])*/
        progressBar.sizeToFit()
        progressBar.delegate = self*/
    }
}

extension StoryCollectionViewCell: SegmentedProgressBarDelegate {
    func segmentedProgressBarChangedIndex(index: Int) {
        
    }
    
    func segmentedProgressBarFinished() {
        
    }
    
    
}
