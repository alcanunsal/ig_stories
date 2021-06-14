//
//  StoryCollectionViewCell.swift
//  Stories
//
//  Created by alc on 9.06.2021.
//

import UIKit

class MainStoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet var profileImageCircleView: UIView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var profileNameLabel: UILabel!
    
    static let identifier = "MainStoryCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureSubviews(){
        self.profileImageCircleView.frame = CGRect(x: 0, y: 0, width: 0.8*self.contentView.frame.size.height, height: 0.8*self.contentView.frame.size.height)
        self.profileImageView.frame.size = CGSize(width: 0.8*self.contentView.frame.size.width, height: 0.8*self.contentView.frame.size.width)
        self.profileImageView.center = CGPoint(x: self.profileImageCircleView.frame.size.width/2, y: self.profileImageCircleView.frame.size.height/2)
        self.profileNameLabel.frame = CGRect(x: self.profileImageCircleView.frame.minX, y: self.profileImageCircleView.frame.maxY+3, width: self.contentView.frame.size.width, height: 0.18*self.contentView.frame.size.height)
        translatesAutoresizingMaskIntoConstraints = true
        profileImageView.layer.borderColor = UIColor.white.cgColor
        
        profileImageCircleView.layer.borderColor = #colorLiteral(red: 0.5810584426, green: 0.1285524964, blue: 0.5745313764, alpha: 1)
        profileImageCircleView.layer.cornerRadius = profileImageCircleView.frame.size.width/2
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.layer.borderWidth = 0.5
        profileImageCircleView.layer.borderWidth = 3
        profileImageView.translatesAutoresizingMaskIntoConstraints = true
        
        profileImageCircleView.clipsToBounds = true
        profileImageCircleView.layer.masksToBounds = true
        profileImageView.layer.masksToBounds = true
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = true
    }
    
    func configureCell(with profile: Profile) {
        setImage(imageView: profileImageView, strURL: profile.profilePicUrl)
        profileNameLabel.text = profile.username
    }
    
    func setImage(imageView: UIImageView, strURL: String) {
        if let url = URL(string:strURL) {
            imageView.af.setImage(withURL: url ,
                                  placeholderImage: UIImage(named: "gray"),
                                  filter: nil,
                                  imageTransition: .crossDissolve(0.2),
                                  completion: nil)
        } else {
            imageView.image = UIImage(named: "gray")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        profileNameLabel.text = ""
    }
    
}
