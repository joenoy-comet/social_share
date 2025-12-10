import Flutter
import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import Photos



public class SwiftAppinioSocialSharePlugin: NSObject, FlutterPlugin, SharingDelegate, UIDocumentInteractionControllerDelegate {

    private let INSTAGRAM_DIRECT:String = "instagram_direct";
    private let INSTAGRAM_STORIES:String = "instagram_stories";
    private let INSTAGRAM_POST:String = "instagram_post";
    private let FACEBOOK:String = "facebook";
    private let FACEBOOK_STORIES = "facebook_stories";
    private let MESSENGER = "messenger";
    private let WHATSAPP:String = "whatsapp";
    private let WHATSAPP_IMG_IOS:String = "whatsapp_img_ios";
    private let TWITTER:String = "twitter";
    private let SMS:String = "sms";
    private let SYSTEM_SHARE:String = "system_share";
    private let COPY_TO_CLIPBOARD:String = "copy_to_clipboard";
    private let TELEGRAM:String = "telegram";
    private let INSTALLED_APPS:String = "installed_apps";


    var shareUtil = ShareUtil()
    var flutterResult: FlutterResult!

    // Pending results for tracking share completion
    private var pendingInstagramResult: FlutterResult?
    private var pendingTwitterResult: FlutterResult?
    private var pendingWhatsappResult: FlutterResult?


    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "appinio_social_share", binaryMessenger: registrar.messenger())
    let instance = SwiftAppinioSocialSharePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    // Add lifecycle observer to detect when app returns from share
    NotificationCenter.default.addObserver(
        instance,
        selector: #selector(appDidBecomeActive),
        name: UIApplication.didBecomeActiveNotification,
        object: nil
    )
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      do {
      flutterResult = result
      let args = call.arguments as? [String: Any?]

      switch (call.method) {
      case INSTALLED_APPS:
          shareUtil.getInstalledApps(result: result)
          break
      case INSTAGRAM_DIRECT:
          shareUtil.shareToInstagramDirect(args:args!,result: result)
          break
      case INSTAGRAM_POST:
          pendingInstagramResult = result
          shareUtil.shareToInstagramFeedWithPendingResult(args:args!)
          break
      case INSTAGRAM_STORIES:
          shareUtil.shareToInstagramStory(args:args!,result:result)
          break
      case FACEBOOK_STORIES:
          shareUtil.shareToFacebookStory(args:args!,result:result)
          break
      case WHATSAPP_IMG_IOS:
          shareUtil.shareImageToWhatsApp(args:args!, result:result,delegate: self)
          break
      case WHATSAPP:
          pendingWhatsappResult = result
          shareUtil.shareToWhatsAppWithPendingResult(args:args!)
          break
      case TWITTER:
          pendingTwitterResult = result
          shareUtil.shareToTwitterWithPendingResult(args:args!)
          break
      case SMS:
          shareUtil.shareToSms(args: args!, result: result)
          break
      case SYSTEM_SHARE:
          shareUtil.shareToSystem(args:args!,result: result)
          break
      case COPY_TO_CLIPBOARD:
          shareUtil.copyToClipboard(args: args!, result: result)
          break
      case FACEBOOK:
          shareUtil.shareToFacebookPost(args:args!, result: result,delegate: self)
          break
      case TELEGRAM:
          shareUtil.shareToTelegram(args:args!, result:result)
          break
      case MESSENGER:
          shareUtil.shareToMessenger(args: args!, result: result)
          break
      default:
          result(shareUtil.ERROR)
      }
      } catch {
          result(shareUtil.ERROR)
      }
  }

    // Handler for app returning to foreground after sharing
    @objc func appDidBecomeActive() {
        // Small delay to ensure share completed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }

            if let result = self.pendingInstagramResult {
                print("========================================")
                print("Instagram Share - App became active")
                print("Returning SUCCESS_NO_POST_ID")
                print("========================================")
                result(self.shareUtil.SUCCESS_NO_POST_ID)
                self.pendingInstagramResult = nil
            }
            if let result = self.pendingTwitterResult {
                print("========================================")
                print("Twitter Share - App became active")
                print("Returning SUCCESS_NO_POST_ID")
                print("========================================")
                result(self.shareUtil.SUCCESS_NO_POST_ID)
                self.pendingTwitterResult = nil
            }
            if let result = self.pendingWhatsappResult {
                print("========================================")
                print("WhatsApp Share - App became active")
                print("Returning SUCCESS_NO_POST_ID")
                print("========================================")
                result(self.shareUtil.SUCCESS_NO_POST_ID)
                self.pendingWhatsappResult = nil
            }
        }
    }

    // UIDocumentInteractionControllerDelegate - Required for presentPreview
    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return UIApplication.topViewController()!
    }

    public func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        // COMPREHENSIVE LOGGING to understand Facebook SDK behavior
        print("========================================")
        print("Facebook Share - didCompleteWithResults called")
        print("Timestamp: \(Date())")
        print("========================================")

        // Log ALL keys and values in results dictionary
        print("Results dictionary count: \(results.count)")
        print("Results dictionary: \(results)")

        // Log each key-value pair individually for clarity
        for (key, value) in results {
            print("  Key: '\(key)' → Value: '\(value)' (Type: \(type(of: value)))")
        }

        // Check for all possible known keys
        print("Checking known keys:")
        print("  - postId: \(results["postId"] ?? "nil")")
        print("  - completionGesture: \(results["completionGesture"] ?? "nil")")
        print("  - didComplete: \(results["didComplete"] ?? "nil")")
        print("  - error: \(results["error"] ?? "nil")")
        print("========================================")

        // Check if results contain postId (rare but indicates confirmed post)
        if let postId = results["postId"] as? String, !postId.isEmpty {
            print("✅ SUCCESS_WITH_POST_ID: PostId found!")
            flutterResult(shareUtil.SUCCESS_WITH_POST_ID)
        } else if results.isEmpty {
            // Empty results - Facebook SDK doesn't provide any information
            print("⚠️ SUCCESS_NO_POST_ID: Results dictionary is EMPTY")
            print("   This means Facebook SDK provides no completion information")
            print("   User may or may not have posted - SDK doesn't tell us")
            flutterResult(shareUtil.SUCCESS_NO_POST_ID)
        } else {
            // Results has some data but no postId
            print("⚠️ SUCCESS_NO_POST_ID: Results has data but no postId")
            print("   Checking completionGesture for hints...")

            if let gesture = results["completionGesture"] as? String {
                print("   CompletionGesture value: '\(gesture)'")
                // Maybe we can use this to detect successful posting?
            }

            flutterResult(shareUtil.SUCCESS_NO_POST_ID)
        }
        print("========================================")
     }

     public func sharer(_ sharer: Sharing, didFailWithError error: Error) {
         print("========================================")
         print("Facebook Share - didFailWithError")
         print("Timestamp: \(Date())")
         print("Error: \(error.localizedDescription)")
         print("========================================")
         flutterResult(shareUtil.ERROR)
     }

     public func sharerDidCancel(_ sharer: Sharing) {
         print("========================================")
         print("Facebook Share - sharerDidCancel")
         print("Timestamp: \(Date())")
         print("User explicitly cancelled or dismissed dialog")
         print("========================================")
         flutterResult(shareUtil.CANCELLED)
     }
    
    
     
}
