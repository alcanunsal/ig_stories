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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storiesCollectionView.dataSource = self
        storiesCollectionView.delegate = self
        getStoriesData()
    }
    
    /// This function reads data from "story.json" and assigns it to self.profilesData
    private func getStoriesData() {
        let jsonData = JSONReader().readLocalJSONFile(forFile: "StoryData")
        if let data = jsonData {
            if let profs:Profiles = JSONReader().parseJSON(safeData: data) {
                profilesData = profs.profiles
            } else {
                print("error: JSON file contents and codable object format not matching")
            }
        } else {
            print("error: JSONReader could not read the json file")
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailViewController {
            if let index = storiesCollectionView.indexPathsForSelectedItems?.first?.row {
                destination.profiles = profilesData!
                destination.profileSelected = index
                destination.delegate = self
            } else {
                print("error: no cells chosen for segue")
            }
        } else {
            print("error: destination view controller for segue unknown")
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.storiesCollectionView.frame.size.width/4, height: 1.2*self.storiesCollectionView.frame.size.width/4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}

extension HomepageViewController: DetailViewControllerDelegate {
    func detailViewControllerWillDismiss(data: [Profile]) {
        self.profilesData = data
        storiesCollectionView.reloadData()
    }
}
