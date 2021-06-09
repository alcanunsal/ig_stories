//
//  StoryViewController.swift
//  Stories
//
//  Created by alc on 9.06.2021.
//

import UIKit

class StoryViewController: UIViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    var person:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        usernameLabel.text = person
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
