//
//  SettingsTableViewController.m
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/8/15.
//
//

#import "SettingsTableViewController.h"
#import "LoginManager.h"
#import "TSMessage.h"
#import <MessageUI/MessageUI.h>

@interface SettingsTableViewController () <UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"确认注销？"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
        [alert show];
    } else if (indexPath.section == 0 && indexPath.row == 0) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailCompose = [MFMailComposeViewController new];
            mailCompose.mailComposeDelegate = self;
            [mailCompose setSubject:@"大学城图书馆iOS客户端反馈"];
            [mailCompose setToRecipients:@[ @"xohozu@gmail.com" ]];
            [self presentViewController:mailCompose animated:YES completion:nil];
        }
    }
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%@", alertView);
    if (buttonIndex == 1) {
        [[LoginManager sharedManager] logout];
        [TSMessage showNotificationWithTitle:@"注销成功" type:TSMessageNotificationTypeWarning];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:^{
        switch (result) {
            case MFMailComposeResultSent:
                [TSMessage showNotificationWithTitle:@"您的反馈我们会尽快查看^_^!" type:TSMessageNotificationTypeSuccess];
                break;
            default:
                [TSMessage showNotificationWithTitle:@"我们非常愿意聆听您的声音~" type:TSMessageNotificationTypeWarning];
                break;
        }
    }];
}

@end
