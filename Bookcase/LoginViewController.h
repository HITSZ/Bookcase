//
//  LoginViewController.h
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/8/5.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LoginStatusCode) {
    LoginStatusNone,
    LoginStatusSuccess,
    LoginStatusFail,
    LoginStatusDismiss
};

@protocol LoginViewControllerDelegate;

@interface LoginViewController : UIViewController

@property(weak, nonatomic) id<LoginViewControllerDelegate> delegate;

@end

@protocol LoginViewControllerDelegate <NSObject>

- (void)loginViewDidDismissWithStatus:(LoginStatusCode)status;

@end
