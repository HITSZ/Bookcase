//
//  BorrowedBooksViewController.m
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/8/4.
//
//

#import "BorrowedBooksViewController.h"
#import "LoginViewController.h"
#import "LoginManager.h"
#import "TSMessage.h"
#import "LibraryService.h"
#import "BorrowedBookTableViewCell.h"
#import "SVProgressHUD.h"

@interface BorrowedBooksViewController () <UITableViewDelegate, UITableViewDataSource, LoginViewControllerDelegate>

@property(weak, nonatomic) IBOutlet UITableView *tableView;
@property(copy, nonatomic) NSArray *borrowedBooks;

@property(assign, nonatomic) LoginStatusCode loginStatus;  // TODO:think about it?

@end

@implementation BorrowedBooksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.editButtonItem.title = @"续借";

    self.loginStatus = LoginStatusNone;
    [TSMessage dismissActiveNotification];
    NSLog(@"%@", self);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%@", self);
    if ([[LoginManager sharedManager] isLogin]) {
        [self reloadData];
    }
    else if (_loginStatus == LoginStatusNone) {
        [self setupLoginViewController];
    }
}

- (void)dealloc {
//    [[LoginManager sharedManager] logout];
    NSLog(@"%@", self);
}

#pragma mark -

- (void)setupLoginViewController {
    LoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"loginVC"];
    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    loginVC.delegate = self;
    [self.navigationController presentViewController:loginNav
                                            animated:YES
                                          completion:^{

                                          }];
}

#pragma mark -

- (void)reloadData {
    if ([[LoginManager sharedManager] isLogin]) {
        [SVProgressHUD showWithStatus:@"正在加载..." maskType:SVProgressHUDMaskTypeBlack];
        [LibraryService getMyBorrowedBooksWithReaderno:[LoginManager sharedManager].readerno
                                               success:^(NSArray *borrowedBooks) {
                                                   self.borrowedBooks = borrowedBooks;
                                                   if (_borrowedBooks.count > 0) {
                                                       self.navigationItem.rightBarButtonItem = self.editButtonItem;
                                                   }
                                                   [_tableView reloadData];
                                                   [SVProgressHUD dismiss];
                                               }
                                               failure:^{
                                                   [SVProgressHUD dismiss];
                                                   [TSMessage showNotificationWithTitle:@"借阅记录加载失败" type:TSMessageNotificationTypeError];
                                               }];
    }
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_borrowedBooks[indexPath.row][@"renew"] isEqualToString:@"0"]) {
        return YES;
    }
    return NO;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (!editing) {
        self.editButtonItem.title = @"续借";
        if (self.tableView.indexPathsForSelectedRows) {
            NSMutableArray *bookBarcodes = [NSMutableArray new];
            for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
                NSLog(@"%ld", (long)indexPath.row);
                [bookBarcodes addObject:_borrowedBooks[indexPath.row][@"barcode"]];
            }
            [SVProgressHUD showWithStatus:@"续借中..." maskType:SVProgressHUDMaskTypeBlack];
            [LibraryService renewMyBorrowedBooksInBarcodes:bookBarcodes success:^(NSString *message) {
                [SVProgressHUD dismiss];
                if ([message hasPrefix:@"0本"]) {
                    [TSMessage showNotificationWithTitle:message type:TSMessageNotificationTypeWarning];
                } else {
                    [TSMessage showNotificationWithTitle:message type:TSMessageNotificationTypeSuccess];
                    [self reloadData];
                }
            } failure:^(LibraryServiceStatusCode code) {
                [SVProgressHUD dismiss];
                if (code == LibraryServiceStatusNotLogin) {
                    [self setupLoginViewController];
                } else {
                    [TSMessage showNotificationWithTitle:@"网络出现错误，请重试" type:TSMessageNotificationTypeError];
                }
            }];
        }
    }
    [self.tableView setEditing:editing animated:animated];
}

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _borrowedBooks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BorrowedBookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BorrowedBookCell"];
    [cell updateLabelsWithBook:_borrowedBooks[indexPath.row]];
    return cell;
}

#pragma mark - Login view delegate

- (void)loginViewDidDismissWithStatus:(LoginStatusCode)status {
    Log();
    self.loginStatus = status;
    [self.navigationController dismissViewControllerAnimated:NO completion:^{
        if (status == LoginStatusDismiss) {
            [self.navigationController popViewControllerAnimated:NO];
            [TSMessage showNotificationWithTitle:@"未登录用户无法查看借阅记录" type:TSMessageNotificationTypeError];
        }
    }]; // dimiss loginVC
}

@end
