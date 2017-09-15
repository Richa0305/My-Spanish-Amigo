//
//  MainQuizViewController.swift
//  My Spanish Amigo
//
//  Created by Srivastava, Richa on 30/05/17.
//  Copyright © 2017 ShivHari Apps. All rights reserved.
//

import UIKit
import CoreData

class MainQuizViewController: UIViewController {
    
    @IBOutlet weak var yourScore: UILabel!
    var quizTitle:String!
    @IBOutlet weak var quizLabel:UILabel!
    var score: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.shouldRotate = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "MarkerFelt-Wide", size: 20)!,NSForegroundColorAttributeName: UIColor.white]
        quizLabel.text = "\(quizTitle!) Quiz"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateMinValue()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playSegue" {
            let destVC = segue.destination as! PlayQuizViewController
            destVC.titleMenu = quizTitle
        }
    }
    @IBAction func cancelAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func updateMinValue() {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let entity =
            NSEntityDescription.entity(forEntityName: "Score",
                                       in: managedContext)!
        
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Score")
        
        
        do {
            score = try managedContext.fetch(fetchRequest)
            if score.count != 0 {
                let totalScore = score[0].value(forKey: "score") as! Int
                yourScore.text = String(totalScore)
            }
            
        } catch let error as NSError {
            //print("Could not fetch. \(error), \(error.userInfo)")
        }
        if score.count == 0 {
            let person = NSManagedObject(entity: entity,
                                         insertInto: managedContext)
            
            
            person.setValue(100, forKeyPath: "score")
            
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                // print("Could not save. \(error), \(error.userInfo)")
            }

        }
        
        
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
