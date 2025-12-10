import Photos
import FBSDKCoreKit
import FBSDKShareKit
import Social
import MobileCoreServices



public class ShareUtil{

    public let SUCCESS: String = "SUCCESS"
    public let SUCCESS_WITH_POST_ID: String = "SUCCESS_WITH_POST_ID"
    public let SUCCESS_NO_POST_ID: String = "SUCCESS_NO_POST_ID"
    public let CANCELLED: String = "CANCELLED"
    public let ERROR_APP_NOT_AVAILABLE: String = "ERROR_APP_NOT_AVAILABLE"
    public let ERROR_FEATURE_NOT_AVAILABLE_FOR_THIS_VERSON: String = "ERROR_FEATURE_NOT_AVAILABLE_FOR_THIS_VERSON"
    public let ERROR: String = "ERROR"
    public let NOT_IMPLEMENTED: String = "NOT_IMPLEMENTED"

    let argAttributionURL: String  = "attributionURL";
    let argImagePaths: String  = "imagePaths";
    let argImagePath: String  = "imagePath";
    let argbackgroundImage: String  = "backgroundImage";
    let argMessage: String  = "message";
    let argTitle: String  = "title";
    let argstickerImage: String  = "stickerImage";
    let argAppId: String  = "appId";
    let argBackgroundTopColor: String  = "backgroundTopColor";
    let argBackgroundBottomColor: String  = "backgroundBottomColor";
    let argImages: String  = "images";
    let argVideoFile: String  = "videoFile";


    
    public func getInstalledApps(result: @escaping FlutterResult){
        let apps = [["instagram","instagram"],["facebook-stories","facebook_stories"],["whatsapp","whatsapp"],["tg","telegram"],["fb-messenger","messenger"],["tiktok","snssdk1233"],["instagram-stories","instagram_stories"],["twitter","twitter"],["sms","message"]]
        var output:[String: Bool] = [:]
        for app in apps {
            if(UIApplication.shared.canOpenURL(URL(string:(app[0])+"://")!)){
                if(app[0] == "facebook-stories"){
                    output["facebook"] = true

                }
                output[app[1]] = true
            }else{
                output[app[1]] = false
            }
        }
        result(output)
    }

    public func canOpenUrl(appName:String) -> Bool{
         return UIApplication.shared.canOpenURL(URL(string:appName+"://")!)
    }



    public func shareToInstagramFeed(args : [String: Any?],result: @escaping FlutterResult) {
        let filePath = args[argImagePath] as? String
        if(!isImage(filePath: filePath!)) {
            return shareVideoToInstagramFeed(args: args, result:result)
        } else{
            return shareImageToInstagramFeed(args: args, result:result)
        }
    }

    func isImage(filePath:String)->Bool{
        let ext = NSURL(fileURLWithPath: filePath).pathExtension
        let uti = UTTypeCreatePreferredIdentifierForTag(
            kUTTagClassFilenameExtension,
            ext! as CFString,
            nil)
        if UTTypeConformsTo((uti?.takeRetainedValue())!, kUTTypeImage) {
            return true
        }
        return false
    }


    func shareVideoToInstagramFeed(args : [String: Any?],result: @escaping FlutterResult) {
        let videoFile = args[argImagePath] as? String
        let backgroundVideoUrl = URL(fileURLWithPath: videoFile!)
        let videoData = try? Data(contentsOf: backgroundVideoUrl) as NSData

        getLibraryPermissionIfNecessary { granted in

            guard granted else {
                result(self.ERROR)
                return
            }
        }

        PHPhotoLibrary.shared().performChanges({

            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
            let filePath = "\(documentsPath)/\(Date().description).mp4"

            videoData!.write(toFile: filePath, atomically: true)
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
        },
        completionHandler: { success, error in

            if success {

                let fetchOptions = PHFetchOptions()

                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

                let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)

                if let lastAsset = fetchResult.firstObject {

                    let localIdentifier = lastAsset.localIdentifier
                    let urlFeed = "instagram://library?LocalIdentifier=" + localIdentifier

                    guard
                        let url = URL(string: urlFeed)
                    else {

                        result(self.ERROR_APP_NOT_AVAILABLE)
                        return
                    }
                    DispatchQueue.main.async {

                        if UIApplication.shared.canOpenURL(url) {

                            if #available(iOS 10.0, *) {

                                UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                                    result(self.SUCCESS)
                                })
                            }
                            else {

                                UIApplication.shared.openURL(url)
                                result(self.SUCCESS)
                            }
                        }
                        else {

                            result(self.ERROR)
                        }
                    }
                }
            }
            else if let error = error {

                print(error.localizedDescription)
            }
            else {

                result(self.ERROR)
            }
        })
    }

    func shareImageToInstagramFeed(args : [String: Any?],result: @escaping FlutterResult) {
            let videoFile = args[argImagePath] as? String
            let backgroundVideoUrl = URL(fileURLWithPath: videoFile!)
            let videoData = try? Data(contentsOf: backgroundVideoUrl) as NSData

            getLibraryPermissionIfNecessary { granted in

                guard granted else {
                    result(self.ERROR)
                    return
                }
            }


            PHPhotoLibrary.shared().performChanges({

                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath:String
                     filePath = "\(documentsPath)/\(Date().description).jpeg"


                videoData!.write(toFile: filePath, atomically: true)
                    PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL(fileURLWithPath: filePath))

            },
            completionHandler: { success, error in

                if success {

                    let fetchOptions = PHFetchOptions()

                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    let type:PHAssetMediaType;
                        type = PHAssetMediaType.image


                    let fetchResult = PHAsset.fetchAssets(with: type, options: fetchOptions)

                    if let lastAsset = fetchResult.firstObject {

                        let localIdentifier = lastAsset.localIdentifier
                        let urlFeed = "instagram://library?LocalIdentifier=" + localIdentifier

                        guard
                            let url = URL(string: urlFeed)
                        else {

                            result(self.ERROR_APP_NOT_AVAILABLE)
                            return
                        }
                        DispatchQueue.main.async {

                            if UIApplication.shared.canOpenURL(url) {

                                if #available(iOS 10.0, *) {

                                    UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                                        result(self.SUCCESS)
                                    })
                                }
                                else {

                                    UIApplication.shared.openURL(url)
                                    result(self.SUCCESS)
                                }
                            }
                            else {

                                result(self.ERROR)
                            }
                        }
                    }
                }
                else if let error = error {

                    print(error.localizedDescription)
                }
                else {

                    result(self.ERROR)
                }
            })
        }

    func getLibraryPermissionIfNecessary(completionHandler: @escaping  (Bool) -> Void) {

        guard PHPhotoLibrary.authorizationStatus() != .authorized else {
            completionHandler(true)
            return
        }

        PHPhotoLibrary.requestAuthorization { status in
            completionHandler(status == .authorized)
        }
    }

    // Instagram share with pending result (result handled by lifecycle observer)
    public func shareToInstagramFeedWithPendingResult(args : [String: Any?]) {
        let filePath = args[argImagePath] as? String
        if(!isImage(filePath: filePath!)) {
            return shareVideoToInstagramFeedWithPendingResult(args: args)
        } else{
            return shareImageToInstagramFeedWithPendingResult(args: args)
        }
    }

    func shareVideoToInstagramFeedWithPendingResult(args : [String: Any?]) {
        let videoFile = args[argImagePath] as? String
        let backgroundVideoUrl = URL(fileURLWithPath: videoFile!)
        let videoData = try? Data(contentsOf: backgroundVideoUrl) as NSData

        getLibraryPermissionIfNecessary { granted in
            guard granted else {
                print("❌ Photo library permission denied")
                return
            }
        }

        PHPhotoLibrary.shared().performChanges({
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
            let filePath = "\(documentsPath)/\(Date().description).mp4"
            videoData!.write(toFile: filePath, atomically: true)
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
        },
        completionHandler: { success, error in
            if success {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)

                if let lastAsset = fetchResult.firstObject {
                    let localIdentifier = lastAsset.localIdentifier
                    let urlFeed = "instagram://library?LocalIdentifier=" + localIdentifier

                    guard let url = URL(string: urlFeed) else {
                        print("❌ Invalid Instagram URL")
                        return
                    }
                    DispatchQueue.main.async {
                        if UIApplication.shared.canOpenURL(url) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                print("📤 Instagram opened with video, waiting for app to become active...")
                            } else {
                                UIApplication.shared.openURL(url)
                                print("📤 Instagram opened with video, waiting for app to become active...")
                            }
                        } else {
                            print("❌ Cannot open Instagram URL")
                        }
                    }
                }
            } else if let error = error {
                print("❌ Error: \(error.localizedDescription)")
            }
        })
    }

    func shareImageToInstagramFeedWithPendingResult(args : [String: Any?]) {
        let videoFile = args[argImagePath] as? String
        let backgroundVideoUrl = URL(fileURLWithPath: videoFile!)
        let videoData = try? Data(contentsOf: backgroundVideoUrl) as NSData

        getLibraryPermissionIfNecessary { granted in
            guard granted else {
                print("❌ Photo library permission denied")
                return
            }
        }

        PHPhotoLibrary.shared().performChanges({
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
            let filePath = "\(documentsPath)/\(Date().description).jpeg"
            videoData!.write(toFile: filePath, atomically: true)
            PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL(fileURLWithPath: filePath))
        },
        completionHandler: { success, error in
            if success {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

                if let lastAsset = fetchResult.firstObject {
                    let localIdentifier = lastAsset.localIdentifier
                    let urlFeed = "instagram://library?LocalIdentifier=" + localIdentifier

                    guard let url = URL(string: urlFeed) else {
                        print("❌ Invalid Instagram URL")
                        return
                    }
                    DispatchQueue.main.async {
                        if UIApplication.shared.canOpenURL(url) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                print("📤 Instagram opened with image, waiting for app to become active...")
                            } else {
                                UIApplication.shared.openURL(url)
                                print("📤 Instagram opened with image, waiting for app to become active...")
                            }
                        } else {
                            print("❌ Cannot open Instagram URL")
                        }
                    }
                }
            } else if let error = error {
                print("❌ Error: \(error.localizedDescription)")
            }
        })
    }

    // Instagram share with UIDocumentInteractionController for proper CANCELLED detection
    public func shareToInstagramFeedWithDelegate(args : [String: Any?], delegate: SharingDelegate) {
        let filePath = args[argImagePath] as? String

        guard let path = filePath else {
            print("❌ No file path provided for Instagram share")
            return
        }

        // Check if Instagram is available
        guard let instagramURL = URL(string: "instagram://app"),
              UIApplication.shared.canOpenURL(instagramURL) else {
            print("❌ Instagram not available")
            return
        }

        let url = URL(fileURLWithPath: path)

        // Check if it's a video or image
        if !isImage(filePath: path) {
            // Video sharing with UIDocumentInteractionController
            shareVideoToInstagramWithDelegate(videoPath: path, delegate: delegate)
            return
        }

        guard let image = UIImage(contentsOfFile: url.path) else {
            print("❌ Could not load image for Instagram share")
            return
        }

        // Save image to temp file with .ig extension for Instagram
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            let tempFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("instagram_share.igo")
            do {
                try imageData.write(to: tempFile, options: .atomic)
                let documentInteractionController = UIDocumentInteractionController(url: tempFile)
                documentInteractionController.uti = "com.instagram.exclusivegram"
                documentInteractionController.delegate = delegate as? UIDocumentInteractionControllerDelegate
                documentInteractionController.presentOpenInMenu(from: CGRect.zero, in: UIApplication.topViewController()!.view, animated: true)
                print("📤 Instagram image share opened via UIDocumentInteractionController, waiting for delegate callbacks...")
                // Result handled by delegate methods: didEndSendingToApplication + documentInteractionControllerDidDismissOpenInMenu
            } catch {
                print("❌ Error writing temp file for Instagram: \(error)")
            }
        }
    }

    // Instagram video share with UIDocumentInteractionController for proper CANCELLED detection
    private func shareVideoToInstagramWithDelegate(videoPath: String, delegate: SharingDelegate) {
        let videoURL = URL(fileURLWithPath: videoPath)

        // Copy video to temp location with proper extension
        let tempFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("instagram_share.mov")
        do {
            // Remove existing temp file if any
            if FileManager.default.fileExists(atPath: tempFile.path) {
                try FileManager.default.removeItem(at: tempFile)
            }
            try FileManager.default.copyItem(at: videoURL, to: tempFile)

            let documentInteractionController = UIDocumentInteractionController(url: tempFile)
            documentInteractionController.uti = "com.instagram.exclusivegram"
            documentInteractionController.delegate = delegate as? UIDocumentInteractionControllerDelegate
            documentInteractionController.presentOpenInMenu(from: CGRect.zero, in: UIApplication.topViewController()!.view, animated: true)
            print("📤 Instagram video share opened via UIDocumentInteractionController, waiting for delegate callbacks...")
            // Result handled by delegate methods: didEndSendingToApplication + documentInteractionControllerDidDismissOpenInMenu
        } catch {
            print("❌ Error copying video file for Instagram: \(error)")
        }
    }

    public func shareToSystem(args : [String: Any?],result: @escaping FlutterResult) {
        let text = args[argMessage] as? String
        let filePaths = args[argImagePaths] as? [String]
        var data : [Any] = [text!];
        if filePaths != nil{
            for filePath in filePaths!{
                data.append(URL(fileURLWithPath: filePath))
            }
        }
        let activityViewController = UIActivityViewController(activityItems: data, applicationActivities: nil)
        UIApplication.topViewController()?.present(activityViewController, animated: true, completion: nil)
        result(SUCCESS)
    }
    
    
    func copyToClipboard(args : [String: Any?],result: @escaping FlutterResult){
        let message = args[self.argMessage] as? String
        UIPasteboard.general.string = message!
        result(SUCCESS)
    }
    
    
    
    func shareToWhatsApp(args : [String: Any?],result: @escaping FlutterResult)  {
        let message = args[self.argMessage] as? String
        let whatsURL = "whatsapp://send?text="+message!

        var characterSet = CharacterSet.urlQueryAllowed
        characterSet.insert(charactersIn: "?&")
        let whatsAppURL  = NSURL(string: whatsURL.addingPercentEncoding(withAllowedCharacters: characterSet)!)
        if UIApplication.shared.canOpenURL(whatsAppURL! as URL)
        {
            UIApplication.shared.open(whatsAppURL! as URL)
            result(SUCCESS);
        }
        else
        {
            result(ERROR_APP_NOT_AVAILABLE);
        }
    }

    // WhatsApp share with pending result (result handled by lifecycle observer)
    func shareToWhatsAppWithPendingResult(args : [String: Any?])  {
        let message = args[self.argMessage] as? String
        let whatsURL = "whatsapp://send?text="+message!

        var characterSet = CharacterSet.urlQueryAllowed
        characterSet.insert(charactersIn: "?&")
        let whatsAppURL  = NSURL(string: whatsURL.addingPercentEncoding(withAllowedCharacters: characterSet)!)
        if UIApplication.shared.canOpenURL(whatsAppURL! as URL)
        {
            UIApplication.shared.open(whatsAppURL! as URL)
            // Don't call result here - lifecycle observer will handle it
            print("📤 WhatsApp opened, waiting for app to become active...")
        }
        else
        {
            // App not available - need to clear pending result
            // This will be handled by the caller checking canOpenURL first
            print("❌ WhatsApp not available")
        }
    }

    // WhatsApp text share with UIActivityViewController for proper CANCELLED detection
    func shareToWhatsAppWithCompletion(args : [String: Any?], result: @escaping FlutterResult) {
        let message = args[self.argMessage] as? String

        guard let text = message else {
            print("❌ No message provided for WhatsApp share")
            result(ERROR)
            return
        }

        // Check if WhatsApp is available
        guard let whatsappURL = URL(string: "whatsapp://app"),
              UIApplication.shared.canOpenURL(whatsappURL) else {
            print("❌ WhatsApp not available")
            result(ERROR_APP_NOT_AVAILABLE)
            return
        }

        // Use UIActivityViewController with completion handler
        let activityItems: [Any] = [text]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

        // Exclude other apps to encourage WhatsApp selection
        activityVC.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .print,
            .saveToCameraRoll
        ]

        // Set completion handler for proper result detection
        activityVC.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            print("========================================")
            print("WhatsApp Text Share - Activity completed")
            print("activityType: \(activityType?.rawValue ?? "nil")")
            print("completed: \(completed)")
            print("========================================")

            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                result(self.ERROR)
                return
            }

            if completed {
                print("✅ SUCCESS_NO_POST_ID: User completed share")
                result(self.SUCCESS_NO_POST_ID)
            } else {
                print("❌ CANCELLED: User cancelled share")
                result(self.CANCELLED)
            }
        }

        // Present the activity view controller
        if let viewController = UIApplication.topViewController() {
            // For iPad, set the popover presentation
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = viewController.view
                popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            viewController.present(activityVC, animated: true, completion: nil)
            print("📤 WhatsApp share sheet presented, waiting for completion...")
        } else {
            print("❌ Could not get top view controller")
            result(ERROR)
        }
    }

    func shareToFacebookPost(args : [String: Any?],result: @escaping FlutterResult, delegate: SharingDelegate) {
        let message = args[self.argMessage] as? String
        let imagePaths = args[self.argImagePaths] as? [String]

        // Check if we have photos or text/link only
        if imagePaths == nil || imagePaths!.isEmpty {
            // TEXT/LINK ONLY: Use ShareLinkContent
            let content = ShareLinkContent()

            // Extract URL from message
            if let messageText = message {
                let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                let range = NSRange(location: 0, length: messageText.utf16.count)
                let matches = detector?.matches(in: messageText, options: [], range: range)

                if let match = matches?.first, let url = match.url {
                    content.contentURL = url
                } else {
                    // No URL found, ShareLinkContent requires URL
                    result(ERROR)
                    return
                }
            } else {
                result(ERROR)
                return
            }

            let dialog = ShareDialog(
                viewController: UIApplication.shared.windows.first!.rootViewController,
                content: content,
                delegate: delegate
            )

            do {
                try dialog.validate()
            } catch {
                result(ERROR)
                return
            }
            dialog.show()
            // Don't return result here - let the SharingDelegate callbacks handle it
        } else {
            // PHOTOS: Use SharePhotoContent (original code)
            let content = SharePhotoContent()
            var photos : [SharePhoto] = []
            for image in imagePaths! {
                let photo = SharePhoto(image: UIImage.init(contentsOfFile: image)!, isUserGenerated: true)
                photos.append(photo)
            }
            content.photos = photos
            content.hashtag = Hashtag(message!)
            let dialog = ShareDialog(
                viewController: UIApplication.shared.windows.first!.rootViewController,
                content: content,
                delegate: delegate
            )
            do {
                try dialog.validate()
            } catch {
               result(ERROR)
               return
            }
            dialog.show()
            // Don't return result here - let the SharingDelegate callbacks handle it
        }

    }
    
    
    func shareToTelegram(args : [String: Any?],result: @escaping FlutterResult) {
        let message = args[self.argMessage] as? String
        
        guard let telegramURL = URL(string: "https://telegram.me") else {
            result(ERROR_APP_NOT_AVAILABLE)
            return
        }
        
        guard let mess = message else {
            result(ERROR)
            return
        }
        
        if (UIApplication.shared.canOpenURL(telegramURL)) {
            let urlString = "tg://msg?text=\(mess)"
            let tgUrl = URL.init(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
            
            if UIApplication.shared.canOpenURL(tgUrl!) {
                UIApplication.shared.open(tgUrl!)
                result(SUCCESS)
            } else {
                result(ERROR_APP_NOT_AVAILABLE)
            }
        } else {
            result(ERROR_APP_NOT_AVAILABLE)
        }
    }
    


    public func shareToInstagramDirect(args : [String: Any?],result: @escaping FlutterResult){
        if #available(iOS 10, *){
            let message = args[self.argMessage] as? String
            let urlString = "instagram://sharesheet?text=\(message!)"
            if(!canOpenUrl(appName: "instagram")){
                result(ERROR_APP_NOT_AVAILABLE)
                return
            }
            if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                result(SUCCESS)
            }else{
                result(ERROR)
            }
        }else{
            result(ERROR_FEATURE_NOT_AVAILABLE_FOR_THIS_VERSON)
        }
    }
    
    
    
    
    public func shareToMessenger(args : [String: Any?],result: @escaping FlutterResult){
        if #available(iOS 10, *){
            let message = args[self.argMessage] as? String
            let urlString = "fb-messenger://share/?link=\(message!)"
            if(!canOpenUrl(appName: "fb-messenger")){
                result(ERROR_APP_NOT_AVAILABLE)
                return
            }
            if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                result(SUCCESS)
            }else{
                result(ERROR)
            }
        }else{
            result(ERROR_FEATURE_NOT_AVAILABLE_FOR_THIS_VERSON)
        }
    }
    
    public func shareToSms(args : [String: Any?],result: @escaping FlutterResult){
        let message = args[self.argMessage] as? String
        if #available(iOS 10, *){
            let urlString = "sms:?&body=\(message!)"
            if(!canOpenUrl(appName: "sms")){
                result(ERROR_APP_NOT_AVAILABLE)
                return
            }
            let tgUrl = URL.init(string: urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
            UIApplication.shared.open(tgUrl!, options: [:], completionHandler: nil)
        }
        result(SUCCESS)
    }
    
    public func shareToFacebookStory(args : [String: Any?],result: @escaping FlutterResult) {
        let appId = args[self.argAppId] as? String
        let imagePath = args[self.argbackgroundImage] as? String
        let argVideoFile = args[self.argVideoFile] as? String
        let imagePathSticker = args[self.argstickerImage] as? String
        let backgroundTopColor = args[self.argBackgroundTopColor] as? String
        let backgroundBottomColor =  args[self.argBackgroundBottomColor] as? String
        let attributionURL =  args[self.argAttributionURL] as? String

    
        guard let facebookURL = URL(string: "facebook-stories://share") else {
            result(ERROR_APP_NOT_AVAILABLE)
            return
        }
        
        
        if (UIApplication.shared.canOpenURL(facebookURL)) {
            var pasteboardItems = [
                "com.facebook.sharedSticker.attributionURL": [attributionURL ?? ""],
                "com.facebook.sharedSticker.backgroundTopColor": backgroundTopColor ?? "",
                "com.facebook.sharedSticker.backgroundBottomColor": backgroundBottomColor ?? "",
                "com.facebook.sharedSticker.appID": appId as Any,
            ]
            var backgroundImage: UIImage?;
            if(!(imagePath==nil)){
                backgroundImage =  UIImage.init(contentsOfFile: imagePath!)
                if (backgroundImage != nil) {
                     pasteboardItems["com.facebook.sharedSticker.backgroundImage"] = backgroundImage
                 }
            }
            var stickerImage: UIImage?;
            if(!(imagePathSticker==nil)){
                stickerImage =  UIImage.init(contentsOfFile: imagePathSticker!)
                if (stickerImage != nil) {
                    pasteboardItems["com.facebook.sharedSticker.stickerImage"] = stickerImage
                }
            }
            var backgroundVideoData:Any?;
            if(!(argVideoFile==nil)){
                let backgroundVideoUrl = URL(fileURLWithPath: argVideoFile!)
                backgroundVideoData = try? Data(contentsOf: backgroundVideoUrl)
                if (backgroundVideoData != nil) {
                    pasteboardItems["com.facebook.sharedSticker.backgroundVideo"] = backgroundVideoData
                }
            }


                if #available(iOS 10, *){
                    let pasteboardOptions = [
                        UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)
                    ]
                    UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
                    UIApplication.shared.open(facebookURL, options: [:])
                }
                result(self.SUCCESS)
                return
        } else {
            result(ERROR_APP_NOT_AVAILABLE)
        }
    }
    
    
    func shareToTwitter(args : [String: Any?],result: @escaping FlutterResult) {
        let title = args[self.argMessage] as? String
        let images = args[self.argImagePaths] as? [String]
        if(!canOpenUrl(appName: "twitter")){
            result(ERROR_APP_NOT_AVAILABLE)
            return
        }


        let composeCtl = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        if #unavailable(iOS 16) {
            composeCtl?.add(URL(string: title!))
        }
        if(!(images==nil)){
            for image in images! {
                composeCtl?.add(UIImage.init(contentsOfFile: image))
            }
        }
        composeCtl?.setInitialText(title!)
        UIApplication.topViewController()?.present(composeCtl!,animated:true,completion:nil);
        result(SUCCESS)
    }

    // Twitter share with pending result (result handled by lifecycle observer)
    func shareToTwitterWithPendingResult(args : [String: Any?]) {
        let title = args[self.argMessage] as? String
        let images = args[self.argImagePaths] as? [String]
        if(!canOpenUrl(appName: "twitter")){
            print("❌ Twitter not available")
            return
        }


        let composeCtl = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        if #unavailable(iOS 16) {
            composeCtl?.add(URL(string: title!))
        }
        if(!(images==nil)){
            for image in images! {
                composeCtl?.add(UIImage.init(contentsOfFile: image))
            }
        }
        composeCtl?.setInitialText(title!)
        UIApplication.topViewController()?.present(composeCtl!,animated:true,completion:nil);
        // Don't call result here - lifecycle observer will handle it
        print("📤 Twitter compose controller presented, waiting for app to become active...")
    }

    // Twitter share with completion handler for proper CANCELLED detection
    func shareToTwitterWithCompletion(args : [String: Any?], result: @escaping FlutterResult) {
        let title = args[self.argMessage] as? String
        let images = args[self.argImagePaths] as? [String]

        if(!canOpenUrl(appName: "twitter")){
            print("❌ Twitter not available")
            result(ERROR_APP_NOT_AVAILABLE)
            return
        }

        let composeCtl = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        if #unavailable(iOS 16) {
            composeCtl?.add(URL(string: title!))
        }
        if(!(images==nil)){
            for image in images! {
                composeCtl?.add(UIImage.init(contentsOfFile: image))
            }
        }
        composeCtl?.setInitialText(title!)

        // Set completion handler for proper result detection
        composeCtl?.completionHandler = { [weak self] (composeResult: SLComposeViewControllerResult) in
            DispatchQueue.main.async {
                switch composeResult {
                case .done:
                    print("========================================")
                    print("Twitter Share - Completed")
                    print("✅ SUCCESS_NO_POST_ID")
                    print("========================================")
                    result(self?.SUCCESS_NO_POST_ID ?? "SUCCESS_NO_POST_ID")
                case .cancelled:
                    print("========================================")
                    print("Twitter Share - Cancelled")
                    print("❌ CANCELLED")
                    print("========================================")
                    result(self?.CANCELLED ?? "CANCELLED")
                @unknown default:
                    print("========================================")
                    print("Twitter Share - Unknown result")
                    print("========================================")
                    result(self?.SUCCESS_NO_POST_ID ?? "SUCCESS_NO_POST_ID")
                }
            }
        }

        UIApplication.topViewController()?.present(composeCtl!, animated: true, completion: nil)
    }


    func shareToInstagramStory(args : [String: Any?],result: @escaping FlutterResult) {
        if #available(iOS 10.0, *){
            let appId = args[self.argAppId] as? String
            let imagePath = args[self.argbackgroundImage] as? String
            let argVideoFile = args[self.argVideoFile] as? String
            let imagePathSticker = args[self.argstickerImage] as? String
            let backgroundTopColor = args[self.argBackgroundTopColor] as? String
            let backgroundBottomColor =  args[self.argBackgroundBottomColor] as? String
            let attributionURL =  args[self.argAttributionURL] as? String

            
            guard let instagramURL = URL(string: "instagram-stories://share?source_application=\(appId!)") else {
                result(ERROR_APP_NOT_AVAILABLE)
                return
            }
            
     
            if (UIApplication.shared.canOpenURL(instagramURL)) {
                var backgroundImage: UIImage?;
                if(!(imagePath==nil)){
                    backgroundImage =  UIImage.init(contentsOfFile: imagePath!)
                }
                var stickerImage: UIImage?;
                if(!(imagePathSticker==nil)){
                    stickerImage =  UIImage.init(contentsOfFile: imagePathSticker!)
                }
                var backgroundVideoData:Any?;
                if(!(argVideoFile==nil)){
                    let backgroundVideoUrl = URL(fileURLWithPath: argVideoFile!)
                    backgroundVideoData = try? Data(contentsOf: backgroundVideoUrl)
                }
                let pasteboardItems = [
                    [
                        "com.instagram.sharedSticker.attributionURL": attributionURL ?? "",
                        "com.instagram.sharedSticker.stickerImage": stickerImage ?? "",
                        "com.instagram.sharedSticker.backgroundVideo": backgroundVideoData ?? "",
                        "com.instagram.sharedSticker.backgroundImage": backgroundImage ?? "",
                        "com.instagram.sharedSticker.backgroundTopColor": backgroundTopColor ?? "",
                        "com.instagram.sharedSticker.backgroundBottomColor": backgroundBottomColor ?? "",
                    ]
                ]
                let pasteboardOptions = [
                    UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)
                ]
                UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
                UIApplication.shared.open(instagramURL, options: [:])
                result(self.SUCCESS)
            } else {
                result(ERROR_APP_NOT_AVAILABLE)
            }
        }else{
            result(ERROR_FEATURE_NOT_AVAILABLE_FOR_THIS_VERSON)
        }
        
    }
    
    
    public func shareImageToWhatsApp(args : [String: Any?],result: @escaping FlutterResult, delegate: SharingDelegate) {
      let imagePath = args[self.argImagePath] as? String

      guard let url = URL(string: imagePath!) else {
        result(FlutterError(code: "INVALID_PATH", message: "The image path is invalid", details: nil))
        return
      }
      
      guard let image = UIImage(contentsOfFile: url.path) else {
        result(FlutterError(code: "IMAGE_ERROR", message: "Could not load image", details: nil))
        return
      }
    
    
        let urlWhats = "whatsapp://app"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed) {
            if let whatsappURL = URL(string: urlString) {

                if UIApplication.shared.canOpenURL(whatsappURL as URL) {

                        if let imageData = image.jpegData(compressionQuality: 1.0) {
                            let tempFile = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/whatsAppTmp.wai")
                            do {
                                try imageData.write(to: tempFile, options: .atomic)
                                let documentInteractionController = UIDocumentInteractionController(url: tempFile)
                                documentInteractionController.uti = "net.whatsapp.image"
                                documentInteractionController.presentOpenInMenu(from: CGRect.zero, in: UIApplication.topViewController()!.view, animated: true)
                                result(self.SUCCESS)
                            } catch {
                                print(error)
                                result(self.ERROR)
                            }
                        }
                    

                } else {
                   print("Cannot open whatsapp")
                }
            }
        }
    }

    // WhatsApp image share - result handled by UIDocumentInteractionController delegate
    public func shareImageToWhatsAppWithPendingResult(args : [String: Any?], delegate: SharingDelegate) {
        let imagePath = args[argImagePath] as? String

        guard let path = imagePath else {
            print("❌ No image path provided")
            return
        }

        let url = URL(fileURLWithPath: path)

        guard let image = UIImage(contentsOfFile: url.path) else {
            print("❌ Could not load image")
            return
        }

        let urlWhats = "whatsapp://app"
        if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed) {
            if let whatsappURL = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(whatsappURL as URL) {
                    if let imageData = image.jpegData(compressionQuality: 1.0) {
                        let tempFile = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/whatsAppTmp.wai")
                        do {
                            try imageData.write(to: tempFile, options: .atomic)
                            let documentInteractionController = UIDocumentInteractionController(url: tempFile)
                            documentInteractionController.uti = "net.whatsapp.image"
                            documentInteractionController.delegate = delegate as? UIDocumentInteractionControllerDelegate
                            documentInteractionController.presentPreview(animated: true)
                            print("📤 WhatsApp image share opened, waiting for delegate callbacks...")
                            // Result handled by delegate methods: didEndSendingToApplication + documentInteractionControllerDidEndPreview
                        } catch {
                            print("❌ Error writing temp file: \(error)")
                        }
                    }
                } else {
                    print("❌ Cannot open WhatsApp")
                }
            }
        }
    }

}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

class TransparentViewController: UIViewController {
    override func viewDidLoad() {
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
    }
}
