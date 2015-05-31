//
//  FirstViewController.m
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/5/23.
//
//

#import "SearchViewController.h"

@interface SearchViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
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

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    if (!_bLabelsInserted) {
        [self hotSearchWordsLabelDidInsert];
        _bLabelsInserted = true;
    }
}

- (void)hotSearchWordsLabelDidInsert {
    NSArray *words = @[@"追风筝的人", @"Python", @"摩托车修理店的未来工作哲学", @"左耳", @"盗墓笔记",
                       @"平凡的世界", @"乌合之众", @"百年孤独", @"深入理解C++", @"面试宝典"];

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
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem:headerLabel
                              attribute:NSLayoutAttributeCenterX
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.view
                              attribute:NSLayoutAttributeCenterX
                              multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint
                             constraintWithItem:headerLabel
                             attribute:NSLayoutAttributeTop
                             relatedBy:NSLayoutRelationEqual
                             toItem:self.topLayoutGuide
                             attribute:NSLayoutAttributeBottom
                             multiplier:1.0
                              constant:30]];

    // hot word label's height, and gap between two adjacent labels
    float h = 21, gap = 13.5;

    for (int i = 0; i < [words count] && i < word_displayed_num; i++) {
        UILabel *label = [UILabel new];
        label.text = words[i];
        label.textColor = [UIColor colorWithRed:52.0/255 green:152.0/255 blue:240.0/255 alpha:1];
        [self.view addSubview:label];

        label.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraint:[NSLayoutConstraint
                                      constraintWithItem:label
                                      attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:self.view
                                      attribute:NSLayoutAttributeCenterX
                                      multiplier:1.0
                                      constant:0]];
        [self.view addConstraint:[NSLayoutConstraint
                                      constraintWithItem:label
                                      attribute:NSLayoutAttributeBottom
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:headerLabel
                                      attribute:NSLayoutAttributeBottom
                                      multiplier:1.0
                                      constant:(i + 1) * h + i * gap + 24]];

        // Capture label tap event.
        label.userInteractionEnabled = true;
        [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hotSearchWordLabelDidTap:)]];
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
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if ([[searchBar text] length] == 0) {
        [self.searchDisplayController setActive:false animated:true];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UITableViewCell alloc] init];
}

@end
