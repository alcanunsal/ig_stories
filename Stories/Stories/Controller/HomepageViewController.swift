//
//  ViewController.swift
//  Stories
//
//  Created by alc on 9.06.2021.
//

import UIKit

class HomepageViewController: UIViewController {
    
    @IBOutlet var storiesCollectionView: UICollectionView!
    let pics = ["lana", "wild", "lana", "lana", "wild", "lana", "wild", "lana", "lana", "wild"]
    let users = ["alcanunsal", "hamzaisiktas", "mr.hoser", "ertbulbull", "tunga.gungor", "codeway", "serbest", "dizdarkosu", "muhittin", "thepitirciks"]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        storiesCollectionView.dataSource = self
        storiesCollectionView.delegate = self
        //storiesCollectionView.register(StoryCollectionViewCell.self, forCellWithReuseIdentifier: StoryCollectionViewCell.identifier)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? StoryViewController {
            if let index = storiesCollectionView.indexPathsForSelectedItems?.first?.row {
                destination.person = users[index]
            } else {
                print("segue problem")
            }
        }
    }

}

extension HomepageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        /*guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainStoryCell", for: indexPath) as? StoryCollectionViewCell else {
                fatalError("Unable to dequeue StoryCollectionViewCell.")
            }*/
        let cell = storiesCollectionView.dequeueReusableCell(withReuseIdentifier: StoryCollectionViewCell.identifier, for: indexPath) as! StoryCollectionViewCell
        cell.profileImageView.image = UIImage(named: pics[indexPath.row])
        cell.profileNameLabel.text = users[indexPath.row]
        cell.profileImageView.translatesAutoresizingMaskIntoConstraints = true
        return cell
    }
    
    
    
    
}

