//
//  ViewController.swift
//  Stories
//
//  Created by alc on 9.06.2021.
//

import UIKit

class HomepageViewController: UIViewController {
    
    @IBOutlet var storiesCollectionView: UICollectionView!
    
    private var profilesData: [Profile]?
    
    let pics = ["lana", "wild", "lana", "lana", "wild", "lana", "wild", "lana", "lana", "wild"]
    let users = ["alcanunsal", "hamzaisiktas", "mr.hoser", "ertbulbull", "tunga.gungor", "codeway", "serbest", "dizdarkosu", "muhittin", "thepitirciks"]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        storiesCollectionView.dataSource = self
        storiesCollectionView.delegate = self
        getStoriesData()
        //storiesCollectionView.register(StoryCollectionViewCell.self, forCellWithReuseIdentifier: StoryCollectionViewCell.identifier)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeToStoryDetailSegue" {
            if let vc = segue.destination as? DetailViewController {
                vc.profiles = profilesData!
                if let cell = sender as? DetailCollectionViewCell {
                    print("profileSelected:", profilesData?.firstIndex { $0.username == cell.userNameLabel.text})
                    vc.profileSelected = profilesData?.firstIndex { $0.username == cell.userNameLabel.text}
                }
            }
        }
        if let destination = segue.destination as? DetailViewController {
            if let index = storiesCollectionView.indexPathsForSelectedItems?.first?.row {
                destination.profiles = profilesData!
                destination.profileSelected = index
            } else {
                print("segue problem")
            }
        }
    }
    
    func getStoriesData() {
        let jsonData = JSONReader().readLocalJSONFile(forFile: "StoryData")
        if let data = jsonData {
            if let obj:Profiles = JSONReader().parseJSON(safeData: jsonData!) {
                profilesData = obj.profiles
            } else {
                print("parse error json")
            }
        } else {
            print("jsonerr")
        }
    }

}

extension HomepageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profilesData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = storiesCollectionView.dequeueReusableCell(withReuseIdentifier: MainStoryCollectionViewCell.identifier, for: indexPath) as! MainStoryCollectionViewCell
        cell.configureCell(with: profilesData![indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = storiesCollectionView.cellForItem(at: indexPath) {
            self.performSegue(withIdentifier: "HomeToStoryDetailSegue", sender: cell)
        }
    }
    
    
    
    
}

