//
//  FirstViewController.m
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/5/23.
//
//

#import "SearchViewController.h"

#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "RXMLElement.h"

@interface SearchViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property(weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property BOOL bLabelsInserted;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Indicate that whether those dynamic added labels are existed.
    _bLabelsInserted = false;

    // Change bgcolor of SearchBar's TextField.
    UITextField *sbTextField = [_searchBar valueForKey:@"_searchField"];
    sbTextField.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (_bLabelsInserted) {
        return;
    }

    // To get hot search words via http service.
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:@"http://219.223.211.171/Search/gethotword.jsp?v_index=all"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSString *wrappedResponse =
             [NSString stringWithFormat:@"<resp>%@</resp>",
              [[NSString alloc] initWithData:responseObject encoding:4]];
             RXMLElement *rootXML = [RXMLElement elementFromXMLString:wrappedResponse encoding:4];
             NSMutableArray *hotWords = [NSMutableArray new];
             [rootXML iterate:@"a"
                   usingBlock:^(RXMLElement *anchor) {
                       [hotWords
                        addObject:[anchor.text stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                   }];
             [self hotSearchWordsLabelDidInsert:[hotWords copy]];
             _bLabelsInserted = true;
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}

- (void)hotSearchWordsLabelDidInsert:(NSArray *)hotWords {
    //    NSArray *hotWords = @[
    //                       @"追风筝的人",
    //                       @"Python",
    //                       @"摩托车修理店的未来工作哲学",
    //                       @"左耳",
    //                       @"盗墓笔记",
    //                       @"平凡的世界",
    //                       @"乌合之众",
    //                       @"百年孤独",
    //                       @"深入理解C++",
    //                       @"面试宝典"
    //                       ];

    int word_displayed_num;
    if ([[UIScreen mainScreen] bounds].size.height >= 568) {
        // >= 4-inch screen (iPhone 5/5S, 6/6+)
        word_displayed_num = 10;
    } else {
        // 3.5-inch screen (iPhone 4S)
        word_displayed_num = 8;
    }

    UILabel *headerLabel = [UILabel new];
    headerLabel.text = @"热门搜索";
    headerLabel.font = [UIFont systemFontOfSize:22];
    [self.view addSubview:headerLabel];

    headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:headerLabel
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:headerLabel
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:30]];

    // hot word label's height, and gap between two adjacent labels
    float h = 21, gap = 13.5;

    for (int i = 0; i < [hotWords count] && i < word_displayed_num; i++) {
        UILabel *label = [UILabel new];
        label.text = hotWords[i];
        label.textColor = [UIColor colorWithRed:52.0 / 255 green:152.0 / 255 blue:240.0 / 255 alpha:1];
        // an simple animation
        label.alpha = 0.0;
        [self.view addSubview:label];
        [UIView animateWithDuration:0.1 * i
                         animations:^{
                             label.alpha = 1.0;
                         }];

        label.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:headerLabel
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:(i + 1) * h + i * gap + 24]];

        // Capture label tap event.
        label.userInteractionEnabled = true;
        [label addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                     initWithTarget:self
                                     action:@selector(hotSearchWordLabelDidTap:)]];
    }
}

- (void)hotSearchWordLabelDidTap:(UITapGestureRecognizer *)sender {
    UILabel *touchedLabel = (UILabel *)sender.view;
    _searchBar.text = [touchedLabel text];
    [_searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if ([[searchBar text] length] == 0) {
        [self.searchDisplayController setActive:false animated:true];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if ([[searchBar text] length]) {
        [SVProgressHUD showWithStatus:@"正在搜索..." maskType:SVProgressHUDMaskTypeBlack];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[UITableViewCell alloc] init];
}

@end
