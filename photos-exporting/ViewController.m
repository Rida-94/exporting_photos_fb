//
//  ViewController.m
//  photos-exporting
//
//  Created by Rida Toukrichte on 18/07/2017.
//  Copyright © 2017 . All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import "Firebase.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    loginButtonn = [[FBSDKLoginButton alloc] init];
    loginButtonn.center = self.view.center;
    loginButtonn.readPermissions = @[@"email", @"user_photos", @"public_profile"];
    loginButtonn.delegate = self;
    
    [self.view addSubview:loginButtonn];
    
    self.btnBack.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    
    loginButtonn.hidden = YES;
    if(error != nil){
        NSLog(@"Error : %@", error);
    }
    else{
        NSLog(@"Successfully logged in with facebook...");
        
        
        if([FBSDKAccessToken currentAccessToken]){
        // make the API call
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                      initWithGraphPath:@"/me"
                                      parameters:@{@"fields": @"id, name, email, albums"}
                                      HTTPMethod:@"GET"];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                              id result,
                                              NSError *error)
        {
           
            NSString *accessToken = [[FBSDKAccessToken currentAccessToken] tokenString];
    
            NSLog(@"the result is ======> %@", result);
            
            [self saveUserToFirebase:accessToken];
         
            j = 0;
            NSArray *data = [[NSArray alloc] init];
            data = [[result objectForKey:@"albums"] objectForKey:@"data"];
            
            //NSLog(@"array of data ===> %@", data);

            name = [data valueForKey:@"name"];
            name = [name sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            NSLog(@"sorted name array ====> %@", name);
            
            NSLog(@"array of name ===> %@", name);
            ids = [data valueForKey:@"id"];
            
            NSLog(@"count of ids is ====> %lu", (unsigned long)ids.count);
            
            if (ids.count == 0)
            {
                NSLog(@"#### ids is null");
            }
            else
            {
                arrUrl = [[NSMutableArray alloc] init];
                
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.delegate = self;
                hud.label.text = @"Loading";
                hud.bezelView.color = [UIColor blackColor];
                hud.contentColor = [UIColor whiteColor];
                [self.view addSubview:hud];
                
                [self getAlbumphotos:j];
                NSLog(@"Success !!");
                
            }
            
            //[self.Fbtableview reloadData];
            NSLog(@"OKKK 11 !!");

        
        }];
         }
        else{
            loginButtonn.hidden = NO;
        }
        
    }
}

- (void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    
    NSLog(@"### Log out !!");
    self.btnBack.hidden = YES;
}

-(void) saveUserToFirebase:(NSString*) accessToken{
    
    FIRAuthCredential *credentials = [FIRFacebookAuthProvider
     credentialWithAccessToken:accessToken];
     
    [[FIRAuth auth] signInWithCredential:credentials completion:^(FIRUser *user, NSError *error) {
     
        if (error) {
            NSLog(@"Error ==> %@", error);
            return;
        }
        // User successfully signed in. Get user data from the FIRUser object
        // ...
        NSLog(@"user successfully registred in Firebase ----> %@", user.uid);
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:user.uid forKey:@"user_uid"];
        [defaults synchronize];
         
     }];
    
}


- (void)getAlbumphotos:(int)index
{
    
    //coverid = [NSString stringWithFormat:@"/%@?fields=picture", [ids objectAtIndex:index]];
    if([FBSDKAccessToken currentAccessToken]){
    // make the API call
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:[NSString stringWithFormat:@"/%@", [ids objectAtIndex:index]]
                                  parameters:@{@"fields": @"picture"}
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error)
     {
         
         //NSLog(@"the result 2 is ====> %@", result);
         
         if (j != ids.count)
         {
             NSDictionary *pictureData = [[NSDictionary alloc] init];
             pictureData  = [[result objectForKey:@"picture"] objectForKey:@"data"];
             
             //NSDictionary *redata = [pictureData ];
             
             urlCover = [pictureData valueForKey:@"url"];
             
             [arrUrl addObject:urlCover];
             //NSLog(@"### the url cover data ===> %@", urlCover);
        
             j++;
             
             if (j != ids.count)
             {
                 [self getAlbumphotos:j];
             }
             
         }
         
         if (j == ids.count)
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             //[self.Fbtableview reloadData];
             NSLog(@"OKKK 22 !!");
             NSLog(@"#### array of url : %@", arrUrl);
             [self fbImagePicker];
             
         }
         
     }];
        
    }
    
}

- (IBAction)goBack:(id)sender {
    
    self.selected = nil;
    [self fbImagePicker];
}


-(void) fbImagePicker{
    OLFacebookImagePickerController *picker = [[OLFacebookImagePickerController alloc] init];
    picker.selected = self.selected;
    picker.delegate = self;
    picker.shouldDisplayLogoutButton = NO;
    [self presentViewController:picker animated:YES completion:nil];
}


#pragma mark - OLFacebookImagePickerControllerDelegate methods

- (void)facebookImagePicker:(OLFacebookImagePickerController *)imagePicker didFailWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:^() {
        [[[UIAlertView alloc] initWithTitle:@"Oops" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }];
}


- (void)facebookImagePickerDidCancelPickingImages:(OLFacebookImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Cancel picking image !!");
    
}

- (void)facebookImagePicker:(OLFacebookImagePickerController *)imagePicker didFinishPickingImages:(NSArray/*<OLFacebookImage *>*/ *)images {
    [self dismissViewControllerAnimated:YES completion:nil];
    loginButtonn.hidden = YES;
    self.btnBack.hidden = YES;
    self.selected = images;
    //NSLog(@"### array of images ===> %@", images);
    NSLog(@"### User did pick %lu images", (unsigned long) images.count);
    if(images.count > 0){
    // UIImage *img;
    hud1 = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud1.delegate = self;
    hud1.label.text = @"Uploading...";
    //hud1.mode = MBProgressHUDModeDeterminate;
    hud1.bezelView.color = [UIColor blackColor];
    hud1.contentColor = [UIColor whiteColor];
    [self.view addSubview:hud1];
    
    for (int i=0; i < images.count; i++) {
        NSURL *url = [[images objectAtIndex:i] fullURL];
        
        NSLog(@"### url is ====> %@", url);
        // ########## send selected images to firebase storage ###########
        FIRStorage *storage = [FIRStorage storage];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *userID = [defaults stringForKey:@"user_uid"];
        
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"ddMMyyyy_HHmmss"];
        // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
        //NSLog(@"%@",[dateFormatter stringFromDate:[NSDate date]]);
        NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
        
        NSString *path = [NSString stringWithFormat:@"users_images_fb/%@/img%d_%@.jpg", userID, i+1, currentDate];
        FIRStorageReference *storageRef = [[storage reference] child:path];
        
        //NSData *uploadData = UIImageJPEGRepresentation([UIImage imageNamed:@""], 0.5);
        NSData *uploadData = [[NSData alloc] initWithContentsOfURL:url];
        [storageRef putData:uploadData metadata:nil completion:^(FIRStorageMetadata * metadata, NSError * error) {
            
            if(error != nil){
                NSLog(@"Error :%@", error);
            }
            else{
                if (i == images.count - 1) {
                    
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Succès"
                                                                   message: @"Vos images ont été bien enregistrées dans la base de donnée de Firebase !!"
                                                                  delegate:self
                                                         cancelButtonTitle:nil
                                                         otherButtonTitles:@"Ok", nil];
                    alert.tag = 11;
                    [alert show];
                 
                }
                else{
                    NSLog(@"metadata is ===> %@", metadata);
                }
            
            }
            
        }];

    }// End of loop For
    }
    else{
        NSLog(@"User not pick any image !!");
        [self dismissViewControllerAnimated:YES completion:nil];
        loginButtonn.hidden = NO;
        _btnBack.hidden = NO;
    }
    // ###############################################################
    
}

- (BOOL)facebookImagePicker:(OLFacebookImagePickerController *)imagePicker shouldSelectImage:(OLFacebookImage *)image{
    
    
    return (imagePicker.selected.count < 10);
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 11)
    {
        
        loginButtonn.hidden = NO;
        _btnBack.hidden = NO;
        loginButtonn.titleLabel.hidden = NO;
       
    }
}


@end
