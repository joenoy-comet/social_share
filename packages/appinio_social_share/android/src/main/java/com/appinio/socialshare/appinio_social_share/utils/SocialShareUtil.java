package com.appinio.socialshare.appinio_social_share.utils;

import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.provider.Telephony;

import androidx.core.content.FileProvider;

import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.share.Sharer;
import com.facebook.share.model.ShareHashtag;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.model.SharePhoto;
import com.facebook.share.model.SharePhotoContent;
import com.facebook.share.widget.ShareDialog;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.Log;
import io.flutter.plugin.common.MethodChannel;

public class SocialShareUtil {
    public static final String ERROR_APP_NOT_AVAILABLE = "ERROR_APP_NOT_AVAILABLE";
    public static final String ERROR_CANCELLED = "error : cancelled";
    public static final String UNKNOWN_ERROR = "unknown error";
    public static final String SUCCESS = "SUCCESS";
    public static final String SUCCESS_WITH_POST_ID = "SUCCESS_WITH_POST_ID";
    public static final String SUCCESS_NO_POST_ID = "SUCCESS_NO_POST_ID";
    public static final String CANCELLED = "CANCELLED";

    //packages
    private final String INSTAGRAM_PACKAGE = "com.instagram.android";
    private final String TWITTER_PACKAGE = "com.twitter.android";
    private final String INSTAGRAM_STORY_PACKAGE = "com.instagram.share.ADD_TO_STORY";
    private final String INSTAGRAM_FEED_PACKAGE = "com.instagram.share.ADD_TO_FEED";
    private final String WHATSAPP_PACKAGE = "com.whatsapp";
    private final String TELEGRAM_PACKAGE = "org.telegram.messenger";
    private final String TIKTOK_PACKAGE = "com.zhiliaoapp.musically";
    private final String FACEBOOK_STORY_PACKAGE = "com.facebook.stories.ADD_TO_STORY";
    private final String FACEBOOK_PACKAGE = "com.facebook.katana";
    private final String FACEBOOK_LITE_PACKAGE = "com.facebook.lite";
    private final String FACEBOOK_MESSENGER_PACKAGE = "com.facebook.orca";
    private final String FACEBOOK_MESSENGER_LITE_PACKAGE = "com.facebook.mlite";
    private final String SMS_DEFAULT_APPLICATION = "sms_default_application";

    // Request codes for share activities
    public static final int FACEBOOK_SHARE_REQUEST_CODE = 64206;
    public static final int INSTAGRAM_SHARE_REQUEST_CODE = 64207;
    public static final int TWITTER_SHARE_REQUEST_CODE = 64208;

    private static CallbackManager callbackManager;
    private static MethodChannel.Result pendingFacebookResult;
    private static MethodChannel.Result pendingInstagramResult;
    private static MethodChannel.Result pendingTwitterResult;

    // Getter for CallbackManager to allow activity result forwarding
    public CallbackManager getCallbackManager() {
        return callbackManager;
    }

    // Handle activity result for Facebook share
    public static void handleFacebookShareResult(int resultCode) {
        if (pendingFacebookResult == null) {
            System.out.println("⚠️ No pending Facebook result to handle");
            return;
        }

        System.out.println("========================================");
        System.out.println("Facebook Share Activity Result");
        System.out.println("resultCode: " + resultCode);
        System.out.println("RESULT_OK = " + android.app.Activity.RESULT_OK);
        System.out.println("RESULT_CANCELED = " + android.app.Activity.RESULT_CANCELED);
        System.out.println("========================================");

        // Android activity results don't provide post ID, but we can detect completion
        if (resultCode == android.app.Activity.RESULT_OK) {
            // User returned from Facebook (may or may not have posted)
            System.out.println("✅ SUCCESS_NO_POST_ID: User returned from Facebook");
            pendingFacebookResult.success(SUCCESS_NO_POST_ID);
        } else if (resultCode == android.app.Activity.RESULT_CANCELED) {
            // User cancelled
            System.out.println("❌ CANCELLED: User cancelled or dismissed");
            pendingFacebookResult.success(CANCELLED);
        } else {
            // Unknown result
            System.out.println("⚠️ Unknown result code: " + resultCode);
            pendingFacebookResult.success(SUCCESS_NO_POST_ID);
        }

        pendingFacebookResult = null;
    }

    // Handle activity result for Instagram share
    public static void handleInstagramShareResult(int resultCode) {
        if (pendingInstagramResult == null) {
            System.out.println("⚠️ No pending Instagram result to handle");
            return;
        }

        System.out.println("========================================");
        System.out.println("Instagram Share Activity Result");
        System.out.println("resultCode: " + resultCode);
        System.out.println("========================================");

        if (resultCode == android.app.Activity.RESULT_OK) {
            System.out.println("✅ SUCCESS_NO_POST_ID: User returned from Instagram");
            pendingInstagramResult.success(SUCCESS_NO_POST_ID);
        } else if (resultCode == android.app.Activity.RESULT_CANCELED) {
            System.out.println("❌ CANCELLED: User cancelled or dismissed");
            pendingInstagramResult.success(CANCELLED);
        } else {
            System.out.println("⚠️ Unknown result code: " + resultCode);
            pendingInstagramResult.success(SUCCESS_NO_POST_ID);
        }

        pendingInstagramResult = null;
    }

    // Handle activity result for Twitter share
    public static void handleTwitterShareResult(int resultCode) {
        if (pendingTwitterResult == null) {
            System.out.println("⚠️ No pending Twitter result to handle");
            return;
        }

        System.out.println("========================================");
        System.out.println("Twitter Share Activity Result");
        System.out.println("resultCode: " + resultCode);
        System.out.println("========================================");

        if (resultCode == android.app.Activity.RESULT_OK) {
            System.out.println("✅ SUCCESS_NO_POST_ID: User returned from Twitter");
            pendingTwitterResult.success(SUCCESS_NO_POST_ID);
        } else if (resultCode == android.app.Activity.RESULT_CANCELED) {
            System.out.println("❌ CANCELLED: User cancelled or dismissed");
            pendingTwitterResult.success(CANCELLED);
        } else {
            System.out.println("⚠️ Unknown result code: " + resultCode);
            pendingTwitterResult.success(SUCCESS_NO_POST_ID);
        }

        pendingTwitterResult = null;
    }

    public String shareToWhatsApp(String imagePath, String msg, Context context) {
        return shareFileAndTextToPackage(imagePath, msg, context, WHATSAPP_PACKAGE);
    }

    public String shareToWhatsAppFiles(ArrayList<String> imagePaths, Context context) {
        return shareFilesToPackage(imagePaths, context, WHATSAPP_PACKAGE);
    }


    public String shareToInstagramDirect(String text, Context activity) {
        return shareTextToPackage(text, activity, INSTAGRAM_PACKAGE);
    }

    public void shareToInstagramFeed(String imagePath, String message, Activity activity, String text, MethodChannel.Result result) {
        try {
            Intent shareIntent = new Intent(Intent.ACTION_SEND);
            if (imagePath != null) {
                Uri fileUri = FileProvider.getUriForFile(activity, activity.getApplicationContext().getPackageName() + ".provider", new File(imagePath));
                shareIntent.putExtra(Intent.EXTRA_STREAM, fileUri);
                shareIntent.setType(getMimeTypeOfFile(imagePath));
            } else {
                shareIntent.setType("text/plain");
            }
            shareIntent.putExtra(Intent.EXTRA_TEXT, text);
            shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            shareIntent.setPackage(INSTAGRAM_PACKAGE);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                shareIntent.setComponent(ComponentName.createRelative(INSTAGRAM_PACKAGE, "com.instagram.share.handleractivity.ShareHandlerActivity"));
            }

            System.out.println("🚀 Launching Instagram share with result tracking...");
            pendingInstagramResult = result;
            activity.startActivityForResult(shareIntent, INSTAGRAM_SHARE_REQUEST_CODE);
            System.out.println("⏳ Waiting for Instagram activity result...");
        } catch (Exception e) {
            e.printStackTrace();
            result.success("ERROR: " + e.getLocalizedMessage());
        }
    }

    public String shareToInstagramFeedFiles(ArrayList<String> imagePaths, Context activity, String text) {
        return shareFilesToPackage(imagePaths, activity, INSTAGRAM_PACKAGE);
    }

    public String shareToTikTok(ArrayList<String> imagePaths, Context activity) {
        return shareFilesToPackage(imagePaths, activity, TIKTOK_PACKAGE);
    }

    public void shareToTwitter(String imagePath, Activity activity, String text, MethodChannel.Result result) {
        try {
            Intent shareIntent = new Intent(Intent.ACTION_SEND);
            if (imagePath != null) {
                Uri fileUri = FileProvider.getUriForFile(activity, activity.getApplicationContext().getPackageName() + ".provider", new File(imagePath));
                shareIntent.putExtra(Intent.EXTRA_STREAM, fileUri);
                shareIntent.setType(getMimeTypeOfFile(imagePath));
            } else {
                shareIntent.setType("text/plain");
            }
            shareIntent.putExtra(Intent.EXTRA_TEXT, text);
            shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            shareIntent.setPackage(TWITTER_PACKAGE);

            System.out.println("🚀 Launching Twitter share with result tracking...");
            pendingTwitterResult = result;
            activity.startActivityForResult(shareIntent, TWITTER_SHARE_REQUEST_CODE);
            System.out.println("⏳ Waiting for Twitter activity result...");
        } catch (Exception e) {
            e.printStackTrace();
            result.success("ERROR: " + e.getLocalizedMessage());
        }
    }

    public String shareToTwitterFiles(ArrayList<String> imagePaths, Context activity) {
        return shareFilesToPackage(imagePaths, activity, TWITTER_PACKAGE);
    }

    public String shareToTelegram(String imagePath, Context activity, String text) {
        return shareFileAndTextToPackage(imagePath, text, activity, TELEGRAM_PACKAGE);
    }

    public String shareToTelegramFiles(ArrayList<String> imagePaths, Context activity) {
        return shareFilesToPackage(imagePaths, activity, TELEGRAM_PACKAGE);
    }


    public String shareToMessenger(String text, Context activity) {
        Map<String, Boolean> apps = getInstalledApps(activity);
        String packageName;
        if (apps.get("messenger")) {
            packageName = FACEBOOK_MESSENGER_PACKAGE;
        } else if (apps.get("messenger-lite")) {
            packageName = FACEBOOK_MESSENGER_LITE_PACKAGE;
        } else {
            return ERROR_APP_NOT_AVAILABLE;
        }
        return shareTextToPackage(text, activity, packageName);
    }


    public String copyToClipBoard(String content, Context activity) {
        try {
            ClipboardManager clipboard = (ClipboardManager) activity.getSystemService(Context.CLIPBOARD_SERVICE);
            ClipData clip = ClipData.newPlainText("", content);
            clipboard.setPrimaryClip(clip);
            return SUCCESS;
        } catch (Exception e) {
            return e.getLocalizedMessage();
        }
    }

    public String shareToSMS(String content, Context activity, String imagePath) {
        String defaultApplication;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
            defaultApplication = Telephony.Sms.getDefaultSmsPackage(activity);
        } else {
            defaultApplication = Settings.Secure.getString(activity.getContentResolver(), SMS_DEFAULT_APPLICATION);
        }
        return shareFileAndTextToPackage(imagePath, content, activity, defaultApplication);
    }
    public String shareToSMSFiles( Context activity, ArrayList<String> imagePaths) {
        String defaultApplication;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.KITKAT) {
            defaultApplication = Telephony.Sms.getDefaultSmsPackage(activity);
        } else {
            defaultApplication = Settings.Secure.getString(activity.getContentResolver(), SMS_DEFAULT_APPLICATION);
        }
        return shareFilesToPackage(imagePaths, activity, defaultApplication);
    }


    public String shareToSystemFiles(String title, ArrayList<String> filePaths, String chooserTitle, Context activity) {
        try {
            if (filePaths == null || filePaths.isEmpty()) return "No files to share";
            Intent intent = new Intent();
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.setAction(Intent.ACTION_SEND_MULTIPLE);
            ArrayList<Uri> files = new ArrayList<Uri>();
            for (int i = 0; i < filePaths.size(); i++) {
                Uri fileUri = FileProvider.getUriForFile(activity, activity.getApplicationContext().getPackageName() + ".provider", new File(filePaths.get(i)));
                files.add(fileUri);
            }
            intent.setType(getMimeTypeOfFile(filePaths.get(0)));
            intent.putParcelableArrayListExtra(Intent.EXTRA_STREAM, files);
            intent.putExtra(Intent.EXTRA_SUBJECT, title);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            Intent chooserIntent = Intent.createChooser(intent, chooserTitle);
            chooserIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            chooserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            activity.startActivity(chooserIntent);
            return SUCCESS;
        } catch (Exception e) {
            return e.getLocalizedMessage();
        }
    }


    public String shareToSystem(String title, String message, String filePath, String chooserTitle, Context activity) {
        try {
            Intent intent = new Intent();
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.setAction(Intent.ACTION_SEND);
            if (filePath != null) {
                Uri fileUri = FileProvider.getUriForFile(activity, activity.getApplicationContext().getPackageName() + ".provider", new File(filePath));
                intent.setType(getMimeTypeOfFile(filePath));
                intent.putExtra(Intent.EXTRA_STREAM, fileUri);
            } else {
                intent.setType("text/plain");
            }

            intent.putExtra(Intent.EXTRA_TEXT, message);
            intent.putExtra(Intent.EXTRA_SUBJECT, title);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            Intent chooserIntent = Intent.createChooser(intent, chooserTitle);
            chooserIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            chooserIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            activity.startActivity(chooserIntent);
            return SUCCESS;
        } catch (Exception e) {
            return e.getLocalizedMessage();
        }
    }


    public String shareToInstagramStory(String appId, String stickerImage, String backgroundImage, String backgroundTopColor, String backgroundBottomColor, String attributionURL, Context activity) {

        try {

            Intent shareIntent = new Intent(INSTAGRAM_STORY_PACKAGE);
            shareIntent.setType("image/*");
            shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            shareIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            if (stickerImage != null) {
                File file = new File(stickerImage);
                Uri stickerImageUri = FileProvider.getUriForFile(activity, activity.getApplicationContext().getPackageName() + ".provider", file);
                shareIntent.putExtra("interactive_asset_uri", stickerImageUri);
                activity.grantUriPermission("com.instagram.android", stickerImageUri, Intent.FLAG_GRANT_READ_URI_PERMISSION);
            }
            if (backgroundImage != null) {
                File file1 = new File(backgroundImage);
                Uri backgroundImageUri = FileProvider.getUriForFile(activity, activity.getApplicationContext().getPackageName() + ".provider", file1);
                shareIntent.setDataAndType(backgroundImageUri, getMimeTypeOfFile(backgroundImage));
                activity.grantUriPermission("com.instagram.android", backgroundImageUri, Intent.FLAG_GRANT_READ_URI_PERMISSION);
            }
            shareIntent.putExtra("source_application", appId);
            shareIntent.putExtra("content_url", attributionURL);
            shareIntent.putExtra("top_background_color", backgroundTopColor);
            shareIntent.putExtra("bottom_background_color", backgroundBottomColor);
            activity.startActivity(shareIntent);
            return SUCCESS;
        } catch (Exception e) {
            return e.getLocalizedMessage();
        }

    }


    public void shareToFacebook(List<String> filePaths, String text, Activity activity, MethodChannel.Result result) {
        FacebookSdk.fullyInitialize();
        FacebookSdk.setApplicationId(getFacebookAppId(activity));
        callbackManager = callbackManager == null ? CallbackManager.Factory.create() : callbackManager;

        ShareDialog shareDialog = new ShareDialog(activity);
        shareDialog.registerCallback(callbackManager, new FacebookCallback<Sharer.Result>() {
            @Override
            public void onSuccess(Sharer.Result result1) {
                // COMPREHENSIVE LOGGING to understand Facebook SDK behavior
                System.out.println("========================================");
                System.out.println("Facebook Share - onSuccess called");
                System.out.println("Timestamp: " + new java.util.Date());
                System.out.println("========================================");

                // Log ALL available information from Sharer.Result
                System.out.println("Sharer.Result information:");
                System.out.println("  - Result object: " + result1);
                System.out.println("  - Result class: " + result1.getClass().getName());

                // Check for postId
                String postId = result1.getPostId();
                System.out.println("  - getPostId(): " + (postId != null ? "'" + postId + "'" : "null"));

                // Try to access any other available methods/properties
                System.out.println("========================================");

                if (postId != null && !postId.isEmpty()) {
                    // PostId found - post confirmed!
                    System.out.println("✅ SUCCESS_WITH_POST_ID: PostId found!");
                    result.success(SUCCESS_WITH_POST_ID);
                } else {
                    // No postId - dialog was shown but completion uncertain
                    System.out.println("⚠️ SUCCESS_NO_POST_ID: No postId provided");
                    System.out.println("   This means Facebook SDK provides no completion information");
                    System.out.println("   User may or may not have posted - SDK doesn't tell us");
                    result.success(SUCCESS_NO_POST_ID);
                }
                System.out.println("========================================");
            }

            @Override
            public void onCancel() {
                System.out.println("========================================");
                System.out.println("Facebook Share - onCancel");
                System.out.println("Timestamp: " + new java.util.Date());
                System.out.println("User explicitly cancelled or dismissed dialog");
                System.out.println("========================================");
                result.success(CANCELLED);
            }

            @Override
            public void onError(FacebookException error) {
                System.out.println("========================================");
                System.out.println("Facebook Share - onError");
                System.out.println("Timestamp: " + new java.util.Date());
                System.out.println("Error message: " + error.getLocalizedMessage());
                System.out.println("Error class: " + error.getClass().getName());
                System.out.println("========================================");
                result.success("ERROR: " + error.getLocalizedMessage());
            }
        });

        // Decide which share mode to use based on whether we have photos
        boolean hasPhotos = filePaths != null && !filePaths.isEmpty();

        if (hasPhotos) {
            // MODE 1: Share with photos via Android Intent
            System.out.println("📸 Facebook share mode: PHOTO with caption via Android Intent");
            System.out.println("📝 Using Intent.ACTION_SEND for better reliability");

            // Facebook ShareDialog has reliability issues, use standard Android intent instead
            // This works better and is more reliable across different devices/Facebook versions

            try {
                Intent shareIntent = new Intent();

                if (filePaths.size() == 1) {
                    // Single photo
                    shareIntent.setAction(Intent.ACTION_SEND);
                    Uri fileUri = FileProvider.getUriForFile(activity, activity.getPackageName() + ".provider", new File(filePaths.get(0)));
                    shareIntent.putExtra(Intent.EXTRA_STREAM, fileUri);
                    shareIntent.setType("image/*");
                    System.out.println("📸 Sharing single photo: " + filePaths.get(0));
                } else {
                    // Multiple photos
                    shareIntent.setAction(Intent.ACTION_SEND_MULTIPLE);
                    ArrayList<Uri> imageUris = new ArrayList<>();
                    for (String filePath : filePaths) {
                        Uri fileUri = FileProvider.getUriForFile(activity, activity.getPackageName() + ".provider", new File(filePath));
                        imageUris.add(fileUri);
                    }
                    shareIntent.putParcelableArrayListExtra(Intent.EXTRA_STREAM, imageUris);
                    shareIntent.setType("image/*");
                    System.out.println("📸 Sharing " + filePaths.size() + " photos");
                }

                // Add caption/text if provided
                if (text != null && !text.isEmpty()) {
                    shareIntent.putExtra(Intent.EXTRA_TEXT, text);
                    System.out.println("📝 Including caption: " + (text.length() > 100 ? text.substring(0, 100) + "..." : text));
                }

                // Target Facebook app specifically
                shareIntent.setPackage(FACEBOOK_PACKAGE);
                shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                // Note: Don't use FLAG_ACTIVITY_NEW_TASK - it breaks startActivityForResult

                System.out.println("🚀 Launching Facebook share intent with result tracking...");

                // Store pending result for activity callback
                pendingFacebookResult = result;

                // Use startActivityForResult to track when user returns from Facebook
                // This allows us to return SUCCESS_NO_POST_ID when they complete (like iOS)
                activity.startActivityForResult(shareIntent, FACEBOOK_SHARE_REQUEST_CODE);

                // Don't call result.success() here - it will be called in handleFacebookShareResult
                System.out.println("⏳ Waiting for activity result...");
            } catch (Exception e) {
                System.out.println("❌ Error sharing photo: " + e.getMessage());
                e.printStackTrace();
                result.success("ERROR: " + e.getLocalizedMessage());
            }
        } else {
            // MODE 2: Share link/text only (use generic Android Intent)
            System.out.println("🔗 Facebook share mode: TEXT/LINK via Android Intent");
            System.out.println("📝 Reason: Facebook ShareDialog is unreliable with long URLs");

            // Facebook's native ShareDialog has issues with:
            // - Long URLs with query parameters
            // - AppsFlyer/OneLink URLs
            // - Quote text containing URLs
            //
            // Solution: Use standard Android share intent which is more reliable

            if (text == null || text.isEmpty()) {
                result.success("ERROR: No text to share");
                return;
            }

            System.out.println("📤 Sharing text: " + (text.length() > 100 ? text.substring(0, 100) + "..." : text));

            // Use generic Android Intent to share to Facebook
            Intent shareIntent = new Intent(Intent.ACTION_SEND);
            shareIntent.setType("text/plain");
            shareIntent.putExtra(Intent.EXTRA_TEXT, text);
            shareIntent.setPackage(FACEBOOK_PACKAGE);
            // Note: Don't use FLAG_ACTIVITY_NEW_TASK - it breaks startActivityForResult

            try {
                System.out.println("🚀 Launching Facebook share via Intent.ACTION_SEND with result tracking...");

                // Store pending result for activity callback
                pendingFacebookResult = result;

                // Use startActivityForResult to track when user returns from Facebook
                // This allows us to return SUCCESS_NO_POST_ID when they complete (like iOS)
                activity.startActivityForResult(shareIntent, FACEBOOK_SHARE_REQUEST_CODE);

                // Don't call result.success() here - it will be called in handleFacebookShareResult
                System.out.println("⏳ Waiting for activity result...");
            } catch (Exception e) {
                System.out.println("❌ Error launching share intent: " + e.getMessage());
                result.success("ERROR: " + e.getLocalizedMessage());
            }
        }
    }

    public String shareToFaceBookStory(String appId, String stickerImage, String backgroundImage, String backgroundTopColor, String backgroundBottomColor, String attributionURL, Context activity) {
        try {
            Map<String, Boolean> apps = getInstalledApps(activity);
            String packageName;
            if (apps.get("facebook")) {
                packageName = FACEBOOK_PACKAGE;
            } else if (apps.get("facebook-lite")) {
                packageName = FACEBOOK_LITE_PACKAGE;
            } else {
                return ERROR_APP_NOT_AVAILABLE;
            }

            Intent intent = new Intent(FACEBOOK_STORY_PACKAGE);


            intent.setType("image/*");
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra("com.facebook.platform.extra.APPLICATION_ID", appId);
            if (stickerImage != null) {
                File file = new File(stickerImage);
                Uri stickerImageFile = FileProvider.getUriForFile(activity, activity.getPackageName() + ".provider", file);
                intent.putExtra("interactive_asset_uri", stickerImageFile);
                activity.grantUriPermission(packageName, stickerImageFile, Intent.FLAG_GRANT_READ_URI_PERMISSION);
            }
            intent.putExtra("content_url", attributionURL);
            intent.putExtra("top_background_color", backgroundTopColor);
            intent.putExtra("bottom_background_color", backgroundBottomColor);
            if (backgroundImage != null) {
                File file1 = new File(backgroundImage);
                Uri backgroundImageUri = FileProvider.getUriForFile(activity, activity.getPackageName() + ".provider", file1);
                intent.setDataAndType(backgroundImageUri, getMimeTypeOfFile(backgroundImage));
                activity.grantUriPermission(packageName, backgroundImageUri, Intent.FLAG_GRANT_READ_URI_PERMISSION);
            }
            activity.startActivity(intent);
            return SUCCESS;
        } catch (Exception e) {
            return e.getLocalizedMessage();
        }
    }

    private String shareTextToPackage(
            String text,
            Context context,
            String packageName
    ) {
        try {
            Intent intent = new Intent(Intent.ACTION_SEND);
            intent.setType("text/plain");
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra(Intent.EXTRA_TEXT, text);
            intent.putExtra("content_url", text);
            intent.putExtra("source_application", context.getPackageName());
            intent.putExtra(Intent.EXTRA_TITLE, text);
            intent.putExtra("com.facebook.platform.extra.APPLICATION_ID", getFacebookAppId(context));
            intent.setPackage(packageName);
            context.startActivity(intent);
            return SUCCESS;
        } catch (Exception e) {
            return e.getLocalizedMessage();
        }
    }


    private String shareFilesToPackage(List<String> imagePaths, Context activity, String packageName) {
        if (imagePaths == null || imagePaths.isEmpty()) return "No files to share";
        Intent shareIntent = new Intent(Intent.ACTION_SEND_MULTIPLE);
        ArrayList<Uri> files = new ArrayList<Uri>();
        for (int i = 0; i < imagePaths.size(); i++) {
            Uri fileUri = FileProvider.getUriForFile(activity, activity.getApplicationContext().getPackageName() + ".provider", new File(imagePaths.get(i)));
            files.add(fileUri);
        }
        shareIntent.putParcelableArrayListExtra(Intent.EXTRA_STREAM, files);
        shareIntent.setType(getMimeTypeOfFile(imagePaths.get(0)));
        shareIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        shareIntent.setPackage(packageName);
//        if (packageName.equals(INSTAGRAM_PACKAGE) && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//            shareIntent.setComponent(ComponentName.createRelative(packageName, "com.instagram.share.handleractivity.ShareHandlerActivity")); //open instagram feed
//        }
        try {
            activity.startActivity(shareIntent);
            return SUCCESS;
        } catch (Exception e) {
            e.printStackTrace();
            return e.getLocalizedMessage();
        }
    }

    private String shareFileAndTextToPackage(String imagePath, String message, Context activity, String packageName) {
        Intent shareIntent = new Intent(Intent.ACTION_SEND);
        if (imagePath != null) {
            Uri fileUri = FileProvider.getUriForFile(activity, activity.getApplicationContext().getPackageName() + ".provider", new File(imagePath));
            shareIntent.putExtra(Intent.EXTRA_STREAM, fileUri);
            shareIntent.setType(getMimeTypeOfFile(imagePath));
        } else {
            shareIntent.setType("text/plain");
        }
        shareIntent.putExtra(Intent.EXTRA_TEXT, message);
        shareIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        shareIntent.setPackage(packageName);
        if (packageName.equals(INSTAGRAM_PACKAGE) && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            shareIntent.setComponent(ComponentName.createRelative(packageName, "com.instagram.share.handleractivity.ShareHandlerActivity")); //open instagram feed
        }
        try {
            activity.startActivity(shareIntent);
            return SUCCESS;
        } catch (Exception e) {
            e.printStackTrace();
            return e.getLocalizedMessage();
        }
    }

    public Map<String, Boolean> getInstalledApps(Context context) {
        Map<String, String> appsMap = new HashMap();
        appsMap.put("instagram", INSTAGRAM_PACKAGE);
        appsMap.put("facebook_stories", FACEBOOK_PACKAGE);
        appsMap.put("whatsapp", WHATSAPP_PACKAGE);
        appsMap.put("telegram", TELEGRAM_PACKAGE);
        appsMap.put("messenger", FACEBOOK_MESSENGER_PACKAGE);
        appsMap.put("messenger-lite", FACEBOOK_MESSENGER_LITE_PACKAGE);
        appsMap.put("facebook", FACEBOOK_PACKAGE);
        appsMap.put("facebook-lite", FACEBOOK_LITE_PACKAGE);
        appsMap.put("instagram_stories", INSTAGRAM_PACKAGE);
        appsMap.put("twitter", TWITTER_PACKAGE);
        appsMap.put("tiktok", TIKTOK_PACKAGE);

        Map<String, Boolean> apps = new HashMap<String, Boolean>();

        PackageManager pm = context.getPackageManager();

        Intent intent = new Intent(Intent.ACTION_SENDTO).addCategory(Intent.CATEGORY_DEFAULT);
        intent.setType("vnd.android-dir/mms-sms");
        intent.setData(Uri.parse("sms:"));
        List<ResolveInfo> resolvedActivities = pm.queryIntentActivities(intent, 0);
        apps.put("message", !resolvedActivities.isEmpty());
        String[] appNames = {"instagram", "facebook_stories", "whatsapp", "telegram", "messenger", "facebook", "facebook-lite", "messenger-lite", "instagram_stories", "twitter", "tiktok"};

        for (int i = 0; i < appNames.length; i++) {
            try {
                pm.getPackageInfo(appsMap.get(appNames[i]), PackageManager.GET_META_DATA);
                apps.put(appNames[i], true);
            } catch (Exception e) {
                apps.put(appNames[i], false);
            }
        }
        return apps;
    }

    private static String getMimeTypeOfFile(String pathName) {
        try {
            Path path;
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                path = new File(pathName).toPath();
                String mimeType = Files.probeContentType(path);
                return mimeType;
            }
            return "*/*";
        } catch (Exception e) {
            return "";
        }
    }


    String getFacebookAppId(Context activity) {
        String appId = "";
        try {
            ApplicationInfo appInfo = activity.getPackageManager().getApplicationInfo(
                    activity.getPackageName(), PackageManager.GET_META_DATA);

            Bundle metaData = appInfo.metaData;
            if (metaData != null) {
                appId = metaData.getString("com.facebook.sdk.ApplicationId");
                Log.d("FB_APP_ID", appId != null ? appId : "Facebook App ID not found in AndroidManifest.xml");
            }
        } catch (PackageManager.NameNotFoundException e) {
            // Handle the exception if needed
        }

        return appId;
    }

}
