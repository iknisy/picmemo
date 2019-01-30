//
//  GridCollectionViewController.swift
//  picmemo
//
//  Created by 陳昱宏 on 2018/12/19.
//  Copyright © 2018 Mike. All rights reserved.
//

import UIKit
import CoreData

class GridCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var delButton: UIButton!
    @IBAction func deleteButton(){
//        執行delete功能
        if delActFlag {
//            刪除選擇的項目
            if selectedImages.count > 0 {
                for delObject in selectedImages {
                    if let appDelegate = (UIApplication.shared.delegate as? AppDelegate){
                        let context = appDelegate.persistentContainer.viewContext
                        context.delete(delObject)
                        appDelegate.saveContext()
                        print("CoreData save")
                    }
                }
            }
//            取消所有選擇
            for index in (collectionView?.indexPathsForSelectedItems)! {
                collectionView.deselectItem(at: index, animated: false)
            }
//            清除待刪除的list
            selectedImages.removeAll(keepingCapacity: true)
//            關閉delete多選模式
            delActFlag = false
            collectionView.allowsMultipleSelection = false
            delButton.tintColor = UIColor.black
        }else{
//        啟動delete多選模式
            delActFlag = true
            collectionView.allowsMultipleSelection = true
            delButton.tintColor = UIColor.red
        }
    }
    @IBAction func newMemo(){
        if let controller = storyboard?.instantiateViewController(withIdentifier: "NewMemoNavigationController"){
            present(controller, animated: true, completion: nil)
        }
    }
    
    var memoDetails: [MemoDetail] = []
    var fetchResultController: NSFetchedResultsController<MemoDetail>!
    var delActFlag = false
    var selectedImages: [MemoDetail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
//        讀取CareData內容
        let fetchRequest : NSFetchRequest<MemoDetail> = MemoDetail.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate){
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            do{
                try fetchResultController.performFetch()
                if let fetch = fetchResultController.fetchedObjects {
                    memoDetails = fetch
                }
            }catch{
                print(error)
            }
        }
    }
    
    //    MARK: - NSFetchedResultsControllerDelegate for UICollectionView
    private var blockoprators: [BlockOperation] = []
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockoprators.removeAll(keepingCapacity: true)
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let bo: BlockOperation
        print("CoreData woking")
        switch type {
        case .insert:
            print("CoreData insert")
            guard let newIndex = newIndexPath else {return}
            bo = BlockOperation{
                self.collectionView.insertItems(at: [newIndex])
            }
        case .delete:
            print("CoreData delete")
            guard let index = indexPath else {return}
            bo = BlockOperation{
                self.collectionView.deleteItems(at: [index])
            }
        case .move:
            print("CoreData move")
            guard let index = indexPath, let newIndex = newIndexPath else {return}
            bo = BlockOperation{
                self.collectionView.moveItem(at: index, to: newIndex)
            }
        case .update:
            print("CoreData update")
            guard let index = indexPath else {return}
            bo = BlockOperation{
                self.collectionView.reloadItems(at: [index])
//                儲存變更
                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate){
                    appDelegate.saveContext()
                    print("CoreData save")
                }
            }
//        default:
//            break
        }
        blockoprators.append(bo)
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
//            執行CoreData動作
            self.blockoprators.forEach{ $0.start() }
//            重新讀取修改後的CoreData項目
            if let fetchedObjects = controller.fetchedObjects {
                memoDetails = fetchedObjects as! [MemoDetail]
            }
        }, completion: { finished in
            self.blockoprators.removeAll()
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return memoDetails.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as! GridCollectionViewCell
        // Configure the cell
        if let memoImage = memoDetails[indexPath.row].image {
            cell.gridImageView.image = UIImage(data: memoImage)
        }
        cell.backgroundView = UIImageView(image: UIImage(named: "photo-frame"))
        cell.selectedBackgroundView = UIImageView(image: UIImage(named: "photo-frame-selected"))
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let indexPaths = collectionView.indexPathsForSelectedItems!
            let destinationViewController = segue.destination as! DetailViewController
            destinationViewController.memoDetails = memoDetails
            destinationViewController.index = indexPaths[0].row
            collectionView.deselectItem(at: indexPaths[0], animated: false)
        }
    }
    
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        多選模式開啟後，將選擇的項目加入list
        if delActFlag {
            let selectedImage = memoDetails[indexPath.row]
            selectedImages.append(selectedImage)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        多選模式開啟後，將取消選擇的項目移出list
        if delActFlag {
            let deselectedImage = memoDetails[indexPath.row]
            if let index = selectedImages.lastIndex(of: deselectedImage){
                selectedImages.remove(at: index)
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//        多選模式開啟後，取消單擊Cell的segue動作
        if delActFlag{
            return false
        }
        return true
    }
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
