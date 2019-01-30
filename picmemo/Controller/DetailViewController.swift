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
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet var colorTextButton: [UIButton]!
    @IBAction func colorText(_ sender: UIButton){
        switch sender.currentTitle {
        case "RED":
            detailTextView.textColor = UIColor.red
        case "GREEN":
            detailTextView.textColor = UIColor.green
        case "BLUE":
            detailTextView.textColor = UIColor.blue
        case "BLACK":
            detailTextView.textColor = UIColor.black
        case "WHITE":
            detailTextView.textColor = UIColor.white
        default:
            break
        }
    }
    @IBOutlet weak var editButton: UIButton!
    @IBAction func editDescript(){
        if editFlag{
            editFlag = false
//            隱藏上色按鈕
            for colorButton in colorTextButton {
                colorButton.isHidden = true
            }
//            切換成Lable
            detailLabel.isHidden = false
            detailLabel.text = detailTextView.text
            detailLabel.textColor = detailTextView.textColor
            detailTextView.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width + 100, y: 0)
//            儲存圖示切換成編輯
            editButton.setImage(UIImage(named: "pen"), for: .normal)
//            恢復手勢動作
            for tempGesture in detailView.gestureRecognizers! {
                tempGesture.isEnabled = true
            }
//            儲存註解
            memoDetails[index].describe = detailTextView.text
            var textColor: UIColor
            if detailTextView.textColor != nil {
                textColor = detailTextView.textColor!
            }else{
                textColor = UIColor.white
            }
            do{
                memoDetails[index].textColor = try NSKeyedArchiver.archivedData(withRootObject: textColor, requiringSecureCoding: false)
            }catch{
                print(error)
            }
            
        }else{
            editFlag = true
//            顯示上色按鈕
            for colorButton in colorTextButton {
                colorButton.isHidden = false
            }
//            切換成TextView
            detailLabel.isHidden = true
            detailTextView.transform = .identity
//            編輯圖示切換成儲存
            editButton.setImage(UIImage(named: "save"), for: .normal)
//            暫停手勢動作
            for tempGesture in detailView.gestureRecognizers! {
                tempGesture.isEnabled = false
            }
        }
    }
    
    var memoDetails: [MemoDetail]!
    var index: Int!
    var editFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        隱藏編輯上色按鈕
        for colorbutton in colorTextButton {
            colorbutton.isHidden = true
        }
//        讀取CoreData
        if memoDetails != nil && index != nil {
            detailImageView.image = UIImage(data: memoDetails[index].image!)
            detailLabel.text = memoDetails[index].describe
            detailTextView.text = memoDetails[index].describe
            do{
                detailTextView.textColor = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(memoDetails[index].textColor!) as? UIColor
                detailLabel.textColor = detailTextView.textColor
            }catch{
                print(error)
            }
        }
//        隱藏TextView
        detailTextView.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width + 100, y: 0)
//        監控左右滑動作
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(DetailViewController.viewSwipeToLeft(gesture:)))
        swipeLeft.direction = .left
        self.detailView.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(DetailViewController.viewSwipeToRight(_:)))
        swipeRight.direction = .right
        detailView.addGestureRecognizer(swipeRight)
//        監控單擊動作
        let singleTouch = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.lableHiddenSwitch(_:)))
        singleTouch.numberOfTapsRequired = 1
        singleTouch.numberOfTouchesRequired = 1
        detailView.addGestureRecognizer(singleTouch)
        
        detailView.isUserInteractionEnabled = true
    }
    
    @objc func viewSwipeToLeft(gesture: UISwipeGestureRecognizer) -> Void{
//        向左滑動，圖片切換到下一張
        if index != nil && index < memoDetails.count-1 {
            index += 1
            detailImageView.leftToRightAnimation()
            detailImageView.image = UIImage(data: memoDetails[index].image!)
            detailTextView.text = memoDetails[index].describe
            detailLabel.text = detailTextView.text
            do{
                detailTextView.textColor = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(memoDetails[index].textColor!) as? UIColor
                detailLabel.textColor = detailTextView.textColor
            }catch{
                print(error)
            }
        }
    }
    @objc func viewSwipeToRight(_ gesture: UIGestureRecognizer){
//        向右滑動，圖片切換到上一張
        if index != nil && index > 0 {
            index -= 1
            detailImageView.image = UIImage(data: memoDetails[index].image!)
            detailTextView.text = memoDetails[index].describe
            detailLabel.text = detailTextView.text
            do{
                detailTextView.textColor = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(memoDetails[index].textColor!) as? UIColor
                detailLabel.textColor = detailTextView.textColor
            }catch{
                print(error)
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
    @objc func lableHiddenSwitch(_ gesture: UIGestureRecognizer){
//        單擊螢幕切換隱藏或顯示註解
        detailLabel.isHidden = !detailLabel.isHidden
        editButton.isHidden = detailLabel.isHidden
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
