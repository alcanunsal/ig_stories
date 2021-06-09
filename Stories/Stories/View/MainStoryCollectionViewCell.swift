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
        //profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.white.cgColor
        
        profileImageCircleView.layer.borderColor = #colorLiteral(red: 0.5810584426, green: 0.1285524964, blue: 0.5745313764, alpha: 1)
        profileImageCircleView.layer.cornerRadius = profileImageCircleView.frame.size.width/2
        //profileImageCircleView.layer.borderWidth = 2
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.layer.borderWidth = 1
        profileImageCircleView.layer.borderWidth = 3
        profileImageView.translatesAutoresizingMaskIntoConstraints = true
        
        
        profileImageCircleView.clipsToBounds = true
        profileImageCircleView.layer.masksToBounds = true
        //profileImageCircleView.layer.borderColor = UIColor.purple.cgColor
        profileImageView.layer.masksToBounds = true
        profileImageView.clipsToBounds = true
        //profileImageCircleView.layer.borderColor = UIColor.green.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        configureSubviews()
    }
    
}
