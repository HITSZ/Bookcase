//
//  LoginViewController.m
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/8/5.
//
//

#import "LoginViewController.h"
#import "LoginManager.h"
#import "TSMessage.h"

@interface LoginViewController () <UITextFieldDelegate>

@property(weak, nonatomic) IBOutlet UITextField *username;
@property(weak, nonatomic) IBOutlet UITextField *password;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", self);
    _username.text = [LoginManager sharedManager].username;
}

- (void)dealloc {
    NSLog(@"%@", self);
}

#pragma mark - Text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _username) {
        [_username resignFirstResponder];
        [_password becomeFirstResponder];
    } else {
        [_password resignFirstResponder];
    }
    return YES;
}

#pragma mark - IBAction

- (IBAction)cancleLogin:(id)sender {
    NSLog(@"%@", self);
    [TSMessage dismissActiveNotification];
    [self.delegate loginViewDidDismissWithStatus:LoginStatusDismiss];
}

- (IBAction)loginButtonClicked:(id)sender {
    [self doLogin];
}

#pragma mark -
- (void)doLogin {
    [[LoginManager sharedManager] loginWithUsername:_username.text
                                           password:_password.text
                                            success:^(NSString *message) {
                                                // [TSMessage showNotificationWithTitle:message type:TSMessageNotificationTypeSuccess];
                                                [self.delegate loginViewDidDismissWithStatus:LoginStatusSuccess];
                                            }
                                            failure:^(NSString *message) {
                                                [TSMessage showNotificationInViewController:self title:message subtitle:nil type:TSMessageNotificationTypeError];
      }];
}

@end
