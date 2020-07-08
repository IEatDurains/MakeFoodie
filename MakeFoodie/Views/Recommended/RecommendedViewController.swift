//
//  RecommendedViewController.swift
//  MakeFoodie
//
//  Created by NIgel Cheong on 10/6/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit

class RecommendedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        
        let p = itemList[indexPath.row]
        cell.titleLabel.text = p.title
        cell.itemImageView.image = UIImage(named: p.imageName)
        cell.usernameLabel.text = p.userName
        cell.priceLabel.text = "$ \(p.price)"
        cell.descriptionLabel.text = p.desc
        
        return cell
    }
    
    
    var itemList : [Item] = []
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        itemList.append(Item(
        title: "Very good duck rice", price: 5, desc: "Best duck and rice u will ever taste", imageName: "Ah-Seng-Braised-Duck-Rice", userName: "Ah Seng"))
        
        DataManager.insertData()
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
