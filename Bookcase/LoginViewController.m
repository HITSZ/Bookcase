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

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"%@", self);
    _username.text = [LoginManager sharedManager].username;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)dismiss:(id)sender {
    [TSMessage dismissActiveNotification];
    [self.presentingViewController dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(loginViewDismissed)]) {
            // In fact this is gurannteed by definition of self.delegate, such as id<xxDelegate>.
            [self.delegate loginViewDismissed];
        }
    }];
}

- (IBAction)loginButtonClicked:(id)sender {
    [self doLogin];
}

#pragma mark -
- (void)doLogin {
    [[LoginManager sharedManager] loginWithUsername:_username.text
                                           password:_password.text
                                            success:^(NSString *message) {
                                                [TSMessage showNotificationInViewController:self title:message subtitle:nil type:TSMessageNotificationTypeSuccess];
                                                dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC);
                                                dispatch_after(delay, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                    [self dismiss:nil];
                                                });
                                            }
                                            failure:^(NSString *message) {
                                                [TSMessage showNotificationInViewController:self title:message subtitle:nil type:TSMessageNotificationTypeError];
                                            }];
}

@end
