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

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (copy, nonatomic) NSArray *borrowedBooks;

@end

@implementation BorrowedBooksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setTableFooterView:[UIView new]];

    [TSMessage dismissActiveNotification];
    if (![LoginManager sharedManager].isLogin) {
        [self performSegueWithIdentifier:@"Login" sender:self];
    } else {
        [self reloadData];
    }
    Log();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    Log();
}

#pragma mark -

- (void)reloadData {
    [SVProgressHUD showWithStatus:@"正在加载..." maskType:SVProgressHUDMaskTypeBlack];
    [LibraryService getMyBorrowedBooksWithReaderno:[LoginManager sharedManager].readerno
                                           success:^(NSArray *borrowedBooks) {
                                               self.borrowedBooks = borrowedBooks;
                                               [_tableView reloadData];
                                               [SVProgressHUD dismiss];
                                           }
                                           failure:^{
                                               [SVProgressHUD dismiss];
                                               [TSMessage showNotificationWithTitle:@"借阅记录加载失败" type:TSMessageNotificationTypeError];
                                           }];
}

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _borrowedBooks.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BorrowedBookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BorrowedBookCell"];
    [cell updateLabelsWithBook:_borrowedBooks[indexPath.row]];
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Login"]) {
        LoginViewController* loginViewController = (LoginViewController*)[[segue destinationViewController] topViewController];
        [loginViewController setDelegate:self];
        NSLog(@"%@", loginViewController);
    }
}

#pragma mark - Login view delegate

- (void)loginViewDismissed {
    NSLog(@"%s", __func__);
    if ([LoginManager sharedManager].isLogin) {
        [self reloadData];
    } else {
        [TSMessage showNotificationWithTitle:@"未登录用户无法查看借阅记录" type:TSMessageNotificationTypeError];
        [self.navigationController popViewControllerAnimated:NO];
    }
}

@end
