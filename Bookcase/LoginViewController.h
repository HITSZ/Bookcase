//
//  LoginViewController.h
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/8/5.
//
//

#import <UIKit/UIKit.h>

@protocol LoginViewControllerDelegate;

@interface LoginViewController : UIViewController

@property(weak, nonatomic) id<LoginViewControllerDelegate> delegate;

@end

@protocol LoginViewControllerDelegate <NSObject>

- (void)loginViewDismissed;

@end
