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

@interface BookDetailTableViewController ()

@property (nonatomic, strong) NSDictionary* bookDetail;
@property BOOL bFetchDataFailed;

@end

@implementation BookDetailTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    //     self.clearsSelectionOnViewWillAppear = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:SVProgressHUDDidDisappearNotification
                                               object:nil];
    [self fetchBookDetail];
}

- (void)fetchBookDetail
{
    self.tableView.backgroundView = nil;
    [SVProgressHUD showWithStatus:@"正在加载..." maskType:SVProgressHUDMaskTypeBlack];
    [LibraryService getBookDetailWithUrl:self.url
                                 success:^(NSDictionary* bookDetail) {
                                     _bookDetail = bookDetail;
                                     _bFetchDataFailed = NO;
                                     [SVProgressHUD dismiss];
                                 }
                                 failure:^{
                                     _bookDetail = [NSDictionary new];
                                     _bFetchDataFailed = YES;
                                     [SVProgressHUD showErrorWithStatus:@"网络异常:-P" maskType:SVProgressHUDMaskTypeBlack];
                                 }];
}

- (void)reloadData { [self.tableView reloadData]; }

enum { BASIC_SECTION = 0, STATUS_SECTION };

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == BASIC_SECTION ? 10 : UITableViewAutomaticDimension;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    if (_bFetchDataFailed) {
        UILabel* hintMsgLabel = [[UILabel alloc]
                                 initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        hintMsgLabel.text = @"点击屏幕重新加载";
        hintMsgLabel.textAlignment = NSTextAlignmentCenter;
        hintMsgLabel.font = [UIFont systemFontOfSize:26];
        hintMsgLabel.textColor = [UIColor grayColor];

        self.tableView.backgroundView = hintMsgLabel;

        hintMsgLabel.userInteractionEnabled = YES;
        [hintMsgLabel
         addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                      action:@selector(fetchBookDetail)]];
    }

    return [_bookDetail count];
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case STATUS_SECTION:
            if ([_bookDetail[@"status"][@"in"] count] + [_bookDetail[@"status"][@"out"] count]) {
                return @"馆藏";
            }
            return nil;
        default:
            return nil;
    }
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case BASIC_SECTION:
            return [_bookDetail[@"basic"][@"keys"] count];
        case STATUS_SECTION:
            return [_bookDetail[@"status"][@"in"] count] + [_bookDetail[@"status"][@"out"] count];
        default:
            return 0;
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    switch (indexPath.section) {
        case BASIC_SECTION: {
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"bookBasicDetailCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                              reuseIdentifier:@"bookBasicDetailCell"];
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
                cell.statusLabel.text = _bookDetail[@"status"][@"in"][indexPath.row][1];
                cell.otherInfoLabel.text = _bookDetail[@"status"][@"in"][indexPath.row][2];
                cell.otherLabel.text = @"流通类别";
            }
            else {
                cell.barcodeInfoLabel.text = _bookDetail[@"status"][@"out"][indexPath.row - inCount][0];
                cell.otherInfoLabel.text = _bookDetail[@"status"][@"out"][indexPath.row - inCount][1];
                cell.statusLabel.text = @"借出";
                cell.otherLabel.text = @"应还日期";
                cell.barcodeLabel.textColor = cell.statusLabel.textColor = cell.otherLabel.textColor =
                [UIColor lightGrayColor];
            }
            return cell;
        }
        default:
            return nil;
    }
}

@end
