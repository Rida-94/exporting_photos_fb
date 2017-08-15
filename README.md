# Exporting Facebook Photos
The goal of this app is to let the user export his photos from Facebook to Firebase storage.

## Features
* Sign in the user using Facebook (ask users for permission to access their Facebook albums and photos).
* Once the user taps on any album, we load and display a grid of photos in the selected album and allows the user to choose one or many photos (check-mark on selected pictures). Albums and photos grid are paginated.
* After user confirmation, the selected pictures are downloaded and sent to Firebase to be stored in storage service. A progress bar is displayed while the upload is happening.
* Once all the photos are uploaded, the user see a message letting him know the upload was successful.

## Requirements
* Xcode 7 and iOS SDK 7
* iOS 7.0+ target deployment
* FBSDKCoreKit, FBSDKLoginKit and Bolts (>= 4.0)
* Firebase API (>= 4.0)
* MBProgressHUD ==> https://github.com/jdg/MBProgressHUD
