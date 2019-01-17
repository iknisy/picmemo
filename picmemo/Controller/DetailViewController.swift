//
//  DetailViewController.swift
//  picmemo
//
//  Created by 陳昱宏 on 2019/1/11.
//  Copyright © 2019 Mike. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, CAAnimationDelegate {
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var detailView: UIView!
    
    var memoDetails: [MemoDetail]!
    var index: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        讀取圖檔
        if memoDetails != nil && index != nil {
            detailImageView.image = UIImage(data: memoDetails[index].image!)
            if memoDetails[index].describe != nil {
                detailLabel.text = memoDetails[index].describe
            }else{
                detailLabel.text = ""
            }
        }
//        監控左右滑動作
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(DetailViewController.viewSwipeToLeft(gesture:)))
        swipeLeft.direction = .left
        self.detailView.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(DetailViewController.viewSwipeToRight(_:)))
        swipeRight.direction = .right
        detailView.addGestureRecognizer(swipeRight)
        detailView.isUserInteractionEnabled = true
    }
    
    @objc func viewSwipeToLeft(gesture: UISwipeGestureRecognizer) -> Void{
//        向左滑動，圖片切換到下一張
        if index != nil && index < memoDetails.count-1 {
            index += 1
            detailImageView.leftToRightAnimation()
            detailImageView.image = UIImage(data: memoDetails[index].image!)
            if memoDetails[index].describe != nil {
                detailLabel.text = memoDetails[index].describe
            }else{
                detailLabel.text = ""
            }
        }
    }
    @objc func viewSwipeToRight(_ gesture: UIGestureRecognizer){
//        向右滑動，圖片切換到上一張
        if index != nil && index > 0 {
            index -= 1
            detailImageView.image = UIImage(data: memoDetails[index].image!)
            if memoDetails[index].describe != nil {
                detailLabel.text = memoDetails[index].describe
            }else{
                detailLabel.text = ""
            }
//            圖片切換動畫
            let animation = CATransition()
            animation.type = CATransitionType.push
            animation.subtype = CATransitionSubtype.fromLeft
            animation.duration = 0.5
            animation.delegate = self
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            self.detailView.layer.add(animation, forKey: "rightToLeftTransition")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

extension UIView {
//    向左滑動，圖片切換動畫
    func leftToRightAnimation(duration: TimeInterval = 0.5, completionDelegate: AnyObject? = nil) {
        // Create a CATransition object
        let leftToRightTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided
        if let delegate: AnyObject = completionDelegate {
            leftToRightTransition.delegate = delegate as? CAAnimationDelegate
        }
        
        leftToRightTransition.type = CATransitionType.push
        leftToRightTransition.subtype = CATransitionSubtype.fromRight
        leftToRightTransition.duration = duration
        leftToRightTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        leftToRightTransition.fillMode = CAMediaTimingFillMode.removed
        
        // Add the animation to the View's layer
        self.layer.add(leftToRightTransition, forKey: "leftToRightTransition")
    }
}
