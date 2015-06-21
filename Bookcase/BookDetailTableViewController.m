//
//  BookDetailTableViewController.m
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/6/20.
//
//

#import "BookDetailTableViewController.h"
#import "LibraryService.h"

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

enum { BASIC_SECTION = 0, STATUS_SECTION };

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    switch (section) {
//        case STATUS_SECTION:
//            return @"馆藏";
//        default:
//            return nil;
//    }
//}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case BASIC_SECTION:
            return [[[_bookDetail objectForKey:@"basic"] objectForKey:@"keys"] count];
        case STATUS_SECTION:
            return [[_bookDetail objectForKey:@"status"] count];
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
            NSDictionary* bookBasicDetail = [_bookDetail objectForKey:@"basic"];
            cell.textLabel.text = [[bookBasicDetail objectForKey:@"keys"] objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [bookBasicDetail objectForKey:cell.textLabel.text];
            return cell;
        } break;
        case STATUS_SECTION:
            break;
        default:
            break;
    }
    return nil;
}

@end
