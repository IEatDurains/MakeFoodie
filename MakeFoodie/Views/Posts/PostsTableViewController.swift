//
//  PostsTableViewController.swift
//  MakeFoodie
//
//  Created by Chen Kang Ning on 5/7/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit

class PostsTableViewController: UITableViewController {
    @IBOutlet var postTableView: UITableView!
    var postList: [Post] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Test data
        postList.append(Post(title: "Chicken rice", price: 10, desc: "RICEE", thumbnail: "Ah-Seng-Braised-Duck-Rice", category: "Chinese", userName: "LetsBake"))
        postList.append(Post(title: "Juice", price: 20, desc: "Not actually juice", thumbnail: "movie_oklahoma", category: "Beverages", userName: "LetsBakeaaaa"))
        postList.append(Post(title: "Juice", price: 100, desc: "Not actually juice but more than juice and better and more improved than juice can ever be", thumbnail: "Ah-Seng-Braised-Duck-Rice", category: "Western", userName: "LetsBakeaaaaaaaaaa"))
    }

    // MARK: - Table view data source

    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }*/

    // Tells the UITableView how many rows there will be.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postList.count
    }

    //  To create / reuse a UITableViewCell and return it to the UITableView to draw on the screen.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Query table view to see if there are any UITableViewCells that can be reused. iOS will create a new one if there aren't any.
        let cell : PostCell = tableView.dequeueReusableCell (withIdentifier: "PostCell", for: indexPath) as! PostCell

        // Use the reused cell/newly created cell and update it
        let p = postList[indexPath.row]
        cell.titleLabel.text = p.title
        cell.titleLabel.sizeToFit()
        cell.postImageView.image = UIImage(named: p.thumbnail)
        cell.usernameLabel.text = p.userName
        cell.usernameLabel.sizeToFit()
        cell.priceLabel.text = "$\(p.price)"
        cell.descLabel.text = p.desc
        
        return cell
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}