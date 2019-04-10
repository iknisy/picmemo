//
//  NewAddNotify.swift
//  picmemo
//
//  Created by 陳昱宏 on 2019/3/4.
//  Copyright © 2019 Mike. All rights reserved.
//

import Photos
import UserNotifications

class NewAddNotify: NSObject {
//    此class實作功能：
//    1.檢查是否有Notification權限2.檢查是否有新圖片3.發出Notification
    var assetsFetchResult: PHFetchResult<PHAsset>?

    override init() {
        super.init()
//        檢查UserDefaults是否存有上次存放的圖片id，若無則讀取現有圖片id，然後存放於assetsDetchResult
        if let assetId = (UserDefaults.standard.array(forKey: "assets")) as? [String] {
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            assetsFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: assetId, options: options)
//            assetsFetchResult?.enumerateObjects({asset,_,_ in
//                print("loadID:\(asset.localIdentifier)")
//            })
        }else{
            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            assetsFetchResult = PHAsset.fetchAssets(with: .image, options: options)
            var assetIds: [String] = []
            assetsFetchResult?.enumerateObjects({asset, _, _ in
                assetIds.append(asset.localIdentifier)
            })
            UserDefaults.standard.set(assetIds, forKey: "assets")
        }
    }
    
//    向使用者請求Notification權限，iOS12則請求靜音通知
    func setAuthorization(){
        var options: UNAuthorizationOptions = [.alert, .sound, .badge]
        if #available(iOS 12, *){
            options = [.alert, .sound, .badge, .provisional]
        }
        UNUserNotificationCenter.current().requestAuthorization(options: options, completionHandler: { (granted, error) in
            if granted {
                print("User Notification was allow")
            }else{
                print("User Notification was denied")
            }
        })
    }
//    檢查權限，若無則呼叫系統Setting
    func checkAuthorization(){
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {(setting) in
            switch setting.authorizationStatus{
            case .notDetermined:
                self.setAuthorization()
            case .denied:
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
            case .authorized:
                print("confirm Authorization allow")
            default:
                if setting.authorizationStatus == .provisional {
                    print("Authorization provisionally allow")
                }
            }
        })
    }
    
//    檢查是否有新圖片，若有則發出Notification，最後回傳true
    func photoChangedNotify() -> Bool{
//        獲得現有圖片庫資訊(localIdentifier)
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        let newAssetsFetchResult = PHAsset.fetchAssets(with: .image, options: options)
        var assetIds: [String] = []
        newAssetsFetchResult.enumerateObjects({(asset, _, _) in
            assetIds.append(asset.localIdentifier)
//            print("saveID:\(asset.localIdentifier)")
        })
//        檢查最新圖片是否與上次所存一致
        if assetIds.firstIndex(of: (assetsFetchResult?.firstObject?.localIdentifier)!)! == 0 {
            return false
        }
//        設定Notification文字訊息
        let content = UNMutableNotificationContent()
        content.title = "Detect a new picture!!"
        content.subtitle = "Do you want to add memo for this picture?"
        content.body = "Touch here to edit memo"
//        設定Notification通知音效
        content.sound = UNNotificationSound.default
//        設定Notification顯示圖片
        let newAsset = newAssetsFetchResult.object(at: 0)
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let tempFileURL = tempDir.appendingPathComponent("newPicture.jpg")
        let imageManager = PHImageManager.default()
        imageManager.requestImage(for: newAsset, targetSize: CGSize(width: 100.0, height: 100.0), contentMode: .aspectFill, options: nil, resultHandler: {(image, info) in
            guard let image = image else {return}
            do{
                try image.jpegData(compressionQuality: 0.8)?.write(to: tempFileURL)
            }catch{
                print(error)
            }
        })
        do{
            let attachment = try UNNotificationAttachment(identifier: "Image", url: tempFileURL, options: nil)
            content.attachments = [attachment]
        }catch{
            print(error)
        }
//        設定Notification附帶資訊，供新增Memo時使用
        content.userInfo = ["localIdentifier": newAsset.localIdentifier]
//        設定Notification發出前的等待時間
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//        設定Notification識別id
        let request = UNNotificationRequest(identifier: "picmemo.newpic", content: content, trigger: trigger)
//        發出Notification
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//        將現有圖片庫覆寫回UserDefaults
        UserDefaults.standard.set(assetIds, forKey: "assets")
        
        return true
    }
    
}


