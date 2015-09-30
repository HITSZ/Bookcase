//
//  BookDetailTableViewController.m
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/6/20.
//
//

#import "BookDetailTableViewController.h"
#import "LibraryService.h"
#import "BookStatusTableViewCell.h"

#import "SVProgressHUD.h"
#import "MyStarBooks.h"
#import "TSMessages/TSMessage.h"

static NSString* const kStarImageName = @"Star";
static NSString* const kStarFilledImageName = @"Star Filled";

@interface BookDetailTableViewController ()

@property(weak, nonatomic) IBOutlet UIBarButtonItem* starButton;

@property(nonatomic, strong) NSDictionary* bookDetail;
@property(nonatomic, assign) BOOL bFetchDataFailed;

@end

@implementation BookDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self.tableView
                                             selector:@selector(reloadData)
                                                 name:SVProgressHUDDidDisappearNotification
                                               object:nil];
    [self fetchBookDetail];
}

- (void)fetchBookDetail {
    self.tableView.backgroundView = nil;
    [SVProgressHUD showWithStatus:@"正在加载..." maskType:SVProgressHUDMaskTypeBlack];

    [LibraryService getBookDetailWithUrl:self.url
                                 success:^(NSDictionary* bookDetail) {
                                     _bookDetail = bookDetail;
                                     _bFetchDataFailed = NO;
                                     [SVProgressHUD dismiss];
                                     [self.navigationItem.rightBarButtonItem setEnabled:YES];
                                     [self updateStarButtonStatus];
                                 }
                                 failure:^{
                                     _bookDetail = [NSDictionary new];
                                     _bFetchDataFailed = YES;
                                     [SVProgressHUD showErrorWithStatus:@"网络异常:-P" maskType:SVProgressHUDMaskTypeBlack];
                                 }];
}

enum { BASIC_SECTION = 0,
    STATUS_SECTION };

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    return section == BASIC_SECTION ? 10 : UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == BASIC_SECTION) {
        NSString *item = _bookDetail[@"basic"][@"keys"][indexPath.row];
        NSString *itemContent = _bookDetail[@"basic"][item];
        CGFloat itemLabelWidth = [item sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0]}].width;

        // 36 = |15-textLabel-6-detailTextLabel-15|
        CGRect rect = [itemContent boundingRectWithSize:CGSizeMake(tableView.frame.size.width - (itemLabelWidth + 36), FLT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0]}
                                         context:nil];
        return rect.size.height + 20;
    }
    return tableView.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    if (_bFetchDataFailed) {
        UILabel* hintMsgLabel = [UILabel new];
        hintMsgLabel.text = @"点击屏幕重新加载";
        hintMsgLabel.textAlignment = NSTextAlignmentCenter;
        hintMsgLabel.font = [UIFont systemFontOfSize:26];
        hintMsgLabel.textColor = [UIColor grayColor];

        self.tableView.backgroundView = hintMsgLabel;

        hintMsgLabel.userInteractionEnabled = YES;
        [hintMsgLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(fetchBookDetail)]];
    }

    return [_bookDetail count];
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case STATUS_SECTION: {
            NSUInteger left = [_bookDetail[@"status"][@"in"] count];
            NSUInteger total = left + [_bookDetail[@"status"][@"out"] count];
            if (total) {
                return [NSString stringWithFormat:@"馆藏 [%lu/%lu]", (unsigned long)left, (unsigned long)total];
            }
            return nil;
        }
        default:
            return nil;
    }
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case BASIC_SECTION:
            return [_bookDetail[@"basic"][@"keys"] count];
        case STATUS_SECTION:
            return [_bookDetail[@"status"][@"in"] count] + [_bookDetail[@"status"][@"out"] count];
        default:
            return 0;
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    switch (indexPath.section) {
        case BASIC_SECTION: {
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"bookBasicDetailCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"bookBasicDetailCell"];
                [cell.detailTextLabel setNumberOfLines:0];
            }
            cell.textLabel.text = _bookDetail[@"basic"][@"keys"][indexPath.row];
            cell.detailTextLabel.text = _bookDetail[@"basic"][cell.textLabel.text];
            return cell;
        }
        case STATUS_SECTION: {
            BookStatusTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"bookStatusCell"];
            NSInteger inCount = [_bookDetail[@"status"][@"in"] count];
            if (indexPath.row < inCount) {
                cell.barcodeInfoLabel.text = _bookDetail[@"status"][@"in"][indexPath.row][0];
                cell.indexInfoLabel.text = _bookDetail[@"status"][@"in"][indexPath.row][1];
                cell.statusLabel.text = _bookDetail[@"status"][@"in"][indexPath.row][2];
                cell.otherInfoLabel.text = _bookDetail[@"status"][@"in"][indexPath.row][3];
                cell.otherLabel.text = @"流通类别";
            } else {
                cell.barcodeInfoLabel.text = _bookDetail[@"status"][@"out"][indexPath.row - inCount][0];
                cell.indexInfoLabel.text = _bookDetail[@"status"][@"out"][indexPath.row - inCount][1];
                cell.otherInfoLabel.text = _bookDetail[@"status"][@"out"][indexPath.row - inCount][2];
                cell.statusLabel.text = @"借出";
                cell.otherLabel.text = @"应还日期";
                cell.barcodeLabel.textColor = cell.statusLabel.textColor = cell.otherLabel.textColor = cell.indexLabel.textColor = [UIColor lightGrayColor];
            }
            return cell;
        }
        default:
            return nil;
    }
}

#pragma mark - IB Actions
- (IBAction)starButtonClicked:(id)sender {
    NSString* isbn = _bookDetail[@"basic"][@"ISBN"];
    if ([MyStarBooks hasBook:isbn]) {
        [MyStarBooks removeBook:isbn];
//        [SVProgressHUD showErrorWithStatus:@"取消收藏" maskType:SVProgressHUDMaskTypeBlack];
//        [JDStatusBarNotification showWithStatus:@"取消收藏" dismissAfter:1.5 styleName:JDStatusBarStyleWarning];
        [TSMessage showNotificationWithTitle:@"取消收藏" type:TSMessageNotificationTypeError];
    } else {
        [MyStarBooks addBookWithName:_bookDetail[@"basic"][@"书 名"] isbn:isbn url:_url];
//        [SVProgressHUD showSuccessWithStatus:@"收藏成功" maskType:SVProgressHUDMaskTypeBlack];
//        [JDStatusBarNotification showWithStatus:@"收藏成功" dismissAfter:1 styleName:JDStatusBarStyleSuccess];
        [TSMessage showNotificationWithTitle:@"收藏成功" type:TSMessageNotificationTypeSuccess];
    }
    [self updateStarButtonStatus];
}

- (void)updateStarButtonStatus {
    if ([MyStarBooks hasBook:_bookDetail[@"basic"][@"ISBN"]]) {
        self.starButton.image = [UIImage imageNamed:kStarFilledImageName];
    } else {
        self.starButton.image = [UIImage imageNamed:kStarImageName];
    }
}

@end
