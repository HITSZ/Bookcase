//
//  RecommendationTableViewController.m
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/7/29.
//
//

#import "RecommendationTableViewController.h"
#import "SVProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "TSMessages/TSMessage.h"

#import "LibraryService.h"

static NSString* const kCaptchaImageRequestUrl = @"http://lib.utsz.edu.cn/kaptcha.do";
static NSTimeInterval const kRefreshCaptchaTimeoutInterval = 5.0;

typedef NS_ENUM(NSUInteger, TableViewSection) {
    TableViewSectionRecommended,
    TableViewSectionRecommender,
    TableViewSectionCaptcha
};

typedef NS_ENUM(NSInteger, RecommendedSubmissionStatus) {
    RecommendedSubmissionStatusSuccess = 0,
    RecommendedSubmissionStatusEmptyTitle,
    RecommendedSubmissionStatusInvalidTitle,
    RecommendedSubmissionStatusEmptyResponsible,
    RecommendedSubmissionStatusInvalidResponsible,
    RecommendedSubmissionStatusEmptyEmail = 16,
    RecommendedSubmissionStatusInvalidEmail,
    RecommendedSubmissionStatusEmptyCaptcha = 50,
    RecommendedSubmissionStatusInvalidCaptcha,
    RecommendedSubmissionStatusFail = -1
};

@interface RecommendationTableViewController () <UITextFieldDelegate>

@property(strong, nonatomic) IBOutletCollection(UITextField) NSArray* textFields;
@property(weak, nonatomic) IBOutlet UIImageView* captchaImageView;
@property(weak, nonatomic) IBOutlet UIActivityIndicatorView* captchaImageIndicator;

@end

@implementation RecommendationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_captchaImageIndicator setHidesWhenStopped:YES];

    _captchaImageView.userInteractionEnabled = YES;
    [_captchaImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshCaptcha)]];
    [self refreshCaptcha];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_captchaImageView cancelImageRequestOperation];
    NSLog(@"%s", __func__);
}

#pragma mark -
- (void)refreshCaptcha {
    [_textFields[RecommendFormFieldCaptcha] setText:@""];  // clear captcha field text
    [_captchaImageView setHidden:YES];
    [_captchaImageIndicator startAnimating];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];

    __weak __typeof(self) weakSelf = self;
    [_captchaImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kCaptchaImageRequestUrl]
                                                               cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                           timeoutInterval:kRefreshCaptchaTimeoutInterval]
                             placeholderImage:[UIImage imageNamed:@"RefreshCaptcha"]
                                      success:^(NSURLRequest* request, NSHTTPURLResponse* response, UIImage* image) {
                                          __strong __typeof(weakSelf) strongSelf = weakSelf;
                                          [strongSelf.captchaImageIndicator stopAnimating];
                                          [strongSelf.captchaImageView setHidden:NO];
                                          [strongSelf.captchaImageView setImage:image];
                                          [strongSelf.navigationItem.rightBarButtonItem setEnabled:YES];
                                      }
                                      failure:^(NSURLRequest* request, NSHTTPURLResponse* response, NSError* error) {
                                          __strong __typeof(weakSelf) strongSelf = weakSelf;
                                          [strongSelf.captchaImageIndicator stopAnimating];
                                          [strongSelf.captchaImageView setHidden:NO];
                                      }];
}

#pragma mark - Delegate

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    if (textField.tag == _textFields.count - 1) {
        [textField resignFirstResponder];
    } else {
        [_textFields[textField.tag + 1] becomeFirstResponder];
    }
    return YES;
}

#pragma mark - IBAction

- (IBAction)submit:(id)sender {
    if ([self canSubmit]) {
        [SVProgressHUD showWithStatus:@"正在提交..." maskType:SVProgressHUDMaskTypeBlack];
        [self.view endEditing:YES];
        NSMutableArray* payload = [NSMutableArray arrayWithCapacity:[_textFields count]];
        for (int i = 0; i < [_textFields count]; i++) {
            payload[i] = [_textFields[i] text];
        }
        [LibraryService recommendBookWithPayload:[payload copy] success:^(RecommendedSubmissionStatus code) {
            if (code == RecommendedSubmissionStatusSuccess) {
                [self submissionSuccessful];
            } else {
                [self submissionFailed:code];
            }
            [SVProgressHUD dismiss];
        } failure:^{
            [self submissionFailed:RecommendedSubmissionStatusFail];
            [SVProgressHUD dismiss];
        }];
    }
}

#pragma mark -
- (void)submissionFailed:(RecommendedSubmissionStatus)code {
    NSString* msg = nil;
    TSMessageNotificationType type;
    switch (code) {
        case RecommendedSubmissionStatusInvalidCaptcha:
            msg = @"验证码错误";
            type = TSMessageNotificationTypeWarning;
            break;
        case RecommendedSubmissionStatusFail:
            msg = @"提交失败";
            type = TSMessageNotificationTypeMessage;
        default:
            msg = @"信息填写有误";
            type = TSMessageNotificationTypeError;
            break;
    }
    [TSMessage showNotificationWithTitle:msg type:type];
    [self refreshCaptcha];
}

- (void)submissionSuccessful {
    [TSMessage showNotificationWithTitle:@"图书推荐成功" type:TSMessageNotificationTypeSuccess];
    [self resetFormFields];
}

- (void)resetFormFields {
    for (UITextField* tf in _textFields) {
        tf.text = @"";
    }
    [self refreshCaptcha];
}

#pragma mark -

- (BOOL)canSubmit {
    static NSInteger const requiredFields[5] = {RecommendFormFieldTitle, RecommendFormFieldResponsible, RecommendFormFieldName, RecommendFormFieldEmail, RecommendFormFieldCaptcha};
    for (int i = 0; i < 5; i++) {
        if (![self validateRequiredFieldWithLabel:requiredFields[i]]) {
            return NO;
        }
    }
    if (![self validateEmailWithString:[_textFields[RecommendFormFieldEmail] text]]) {
        return NO;
    }
    return YES;
}

- (BOOL)validateRequiredFieldWithLabel:(RecommendFormField)field {
    if ([_textFields[field] text].length == 0) {
        NSString* errorMsg = [NSString new];
        switch (field) {
            case RecommendFormFieldTitle:
                errorMsg = @"书名不能为空";
                break;
            case RecommendFormFieldResponsible:
                errorMsg = @"作者不能为空";
                break;
            case RecommendFormFieldName:
                errorMsg = @"姓名不能为空";
                break;
            case RecommendFormFieldEmail:
                errorMsg = @"邮箱不能为空";
                break;
            case RecommendFormFieldCaptcha:
                errorMsg = @"验证码不能为空";
                break;
            default:
                break;
        }
        [TSMessage showNotificationWithTitle:errorMsg type:TSMessageNotificationTypeError];
        [self focusEditingOnField:field];
        return NO;
    }
    return YES;
}

- (BOOL)validateEmailWithString:(NSString*)candidate {
    NSString* emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if ([emailTest evaluateWithObject:candidate]) {
        return YES;
    } else {
        [TSMessage showNotificationWithTitle:@"邮箱格式错误" type:TSMessageNotificationTypeWarning];
        [self focusEditingOnField:RecommendFormFieldEmail];
        return NO;
    }
}

- (void)focusEditingOnField:(RecommendFormField)field {
    NSInteger row, section;
    switch (field) {
        case RecommendFormFieldTitle:
        case RecommendFormFieldResponsible:
            row = field;
            section = TableViewSectionRecommended;
            break;
        case RecommendFormFieldName:
        case RecommendFormFieldEmail:
            row = field - RecommendFormFieldName;
            section = TableViewSectionRecommender;
            break;
        case RecommendFormFieldCaptcha:
            row = field - RecommendFormFieldCaptcha;
            section = TableViewSectionCaptcha;
            break;
        default:
            row = RecommendFormFieldTitle;
            section = TableViewSectionRecommended;
            break;
    }
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
    [_textFields[field] becomeFirstResponder];
}

@end
