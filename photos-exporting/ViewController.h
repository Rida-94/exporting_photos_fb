//
//  ViewController.h
//  photos-exporting
//
//  Created by Rida Toukrichte on 18/07/2017.
//  Copyright © 2017 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "OLFacebookAlbumRequest.h"
#import "OLFacebookPhotosForAlbumRequest.h"
#import "OLFacebookAlbum.h"
#import "OLFacebookImage.h"
#import "OLFacebookImagePickerController.h"
#import "MBProgressHUD.h"

@interface ViewController : UIViewController <UINavigationControllerDelegate, FBSDKLoginButtonDelegate, OLFacebookImagePickerControllerDelegate, MBProgressHUDDelegate, UIAlertViewDelegate>
{
    FBSDKLoginButton *loginButtonn;
    MBProgressHUD *hud;
    MBProgressHUD *hud1;
    NSArray *name;
    NSArray *ids;
    NSMutableArray *arrUrl;
    NSString *urlCover;
   
    int j;
    
}

@property (nonatomic, strong) OLFacebookAlbumRequest *albumRequest;
@property (nonatomic, strong) NSArray *selected;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;

- (void)getAlbumphotos:(int)index;
- (IBAction)goBack:(id)sender;

@end

