//
//  FirstViewController.m
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/5/23.
//
//

#import "SearchViewController.h"
#import "LibraryService.h"
#import "BookListTableViewCell.h"

#import "SVProgressHUD.h"

@interface SearchViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate,
UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView* hotSearchView;
@property (weak, nonatomic) IBOutlet UITableView* searchResultsTableView;
@property (weak, nonatomic) IBOutlet UISearchBar* searchBar;

@property (weak, nonatomic) UITableView* searchWordCandidatesTableView;
@property NSArray* kCandidates;
@property NSMutableArray* searchResults;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _kCandidates = [NSArray new];
    _searchResults = [NSMutableArray new];
    _searchWordCandidatesTableView = self.searchDisplayController.searchResultsTableView;

    UITextField* sbTextField = [_searchBar valueForKey:@"_searchField"];
    sbTextField.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0]; // 改变搜索文本框的背景色

    [LibraryService getHotSearchWordsByIndex:@"all"
                                     success:^(NSArray* hotWords) {
                                         [self hotSearchWordsLabelDidInsert:hotWords];
                                     }];
    [self setHotSearchViewHidden:NO];
}

- (void)setHotSearchViewHidden:(BOOL)hidden
{
    [_hotSearchView setHidden:hidden];
    [_searchResultsTableView setHidden:!hidden];
}

#pragma mark - HotWordsAcquire
- (void)hotSearchWordsLabelDidInsert:(NSArray*)hotWords
{
    int word_displayed_num;
    if ([[UIScreen mainScreen] bounds].size.height >= 568) {
        // >= 4-inch screen (iPhone 5/5S, 6/6+)
        word_displayed_num = 10;
    }
    else {
        // 3.5-inch screen (iPhone 4S)
        word_displayed_num = 8;
    }

    UILabel* headerLabel = [UILabel new];
    headerLabel.text = @"热门搜索";
    headerLabel.font = [UIFont systemFontOfSize:22];
    [_hotSearchView addSubview:headerLabel];

    headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_hotSearchView addConstraint:[NSLayoutConstraint constraintWithItem:headerLabel
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_hotSearchView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0]];
    [_hotSearchView addConstraint:[NSLayoutConstraint constraintWithItem:headerLabel
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:_hotSearchView
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0
                                                                constant:30]];

    // hot word label's height, and gap between two adjacent labels
    float h = 21, gap = 13.5;

    for (int i = 0; i < [hotWords count] && i < word_displayed_num; i++) {
        UILabel* label = [UILabel new];
        label.text = hotWords[i];
        label.textColor = [UIColor colorWithRed:52.0 / 255 green:152.0 / 255 blue:240.0 / 255 alpha:1];
        // an simple animation
        label.alpha = 0.0;
        [_hotSearchView addSubview:label];
        [UIView animateWithDuration:0.1 * i
                         animations:^{
                             label.alpha = 1.0;
                         }];

        label.translatesAutoresizingMaskIntoConstraints = NO;
        [_hotSearchView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:_hotSearchView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.0
                                                                    constant:0]];
        [_hotSearchView addConstraint:[NSLayoutConstraint constraintWithItem:label
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

- (void)hotSearchWordLabelDidTap:(UITapGestureRecognizer*)sender
{
    UILabel* touchedLabel = (UILabel*)sender.view;
    _searchBar.text = [touchedLabel text];
    [_searchBar becomeFirstResponder];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidEndEditing:(UISearchBar*)searchBar
{
    if ([[searchBar text] length] == 0) { // 完成输入后,searchDisplayController状态设置为inactive
        [self.searchDisplayController setActive:false animated:true];
    }
}

- (void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)searchText
{
    if ([searchText length] == 0) {
        [self setHotSearchViewHidden:NO];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController*)controller
shouldReloadTableForSearchString:(NSString*)searchString
{
    NSLog(@"%s%@", __func__, searchString);
    _kCandidates = @[ searchString ]; // 搜索建议列表初始化为搜索词，再利用网络获取搜索建议列表进行更新
    [LibraryService getSearchWordCandidatesByIndex:@"all"
                                           withKey:searchString
                                           success:^(NSArray* kCandidates) {
                                               _kCandidates = [kCandidates count] ? kCandidates : _kCandidates;
                                               [_searchWordCandidatesTableView reloadData];
                                           }
                                           failure:^{
                                               [_searchWordCandidatesTableView reloadData];
                                           }];
    return NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar { [self doSearchWithKey:searchBar.text]; }

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _searchWordCandidatesTableView) {
        return [_kCandidates count];
    }
    else {
        return [_searchResults count];
    }
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (tableView == _searchWordCandidatesTableView) {
        UITableViewCell* cell =
        [_searchWordCandidatesTableView dequeueReusableCellWithIdentifier:@"kCandidateListCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"kCandidateListCell"];
        }
        cell.textLabel.text = [_kCandidates objectAtIndex:indexPath.row];
        return cell;
    }
    else {
        BookListTableViewCell* cell = (BookListTableViewCell*)
        [_searchResultsTableView dequeueReusableCellWithIdentifier:@"bookListCell"];
        NSDictionary* item = [_searchResults objectAtIndex:indexPath.row];
        cell.titleLabel.text = [item objectForKey:@"title"];
        cell.authorLabel.text = [item objectForKey:@"author"];
        cell.publisherLabel.text = [item objectForKey:@"publisher"];
        return cell;
    }
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (tableView == _searchWordCandidatesTableView) {
        [self doSearchWithKey:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == _searchWordCandidatesTableView) {
        UIView* headerView = [UIView new];
        UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 0, 0)];
        headerLabel.text = @"搜索建议";
        headerLabel.textColor = [UIColor lightGrayColor];
        headerLabel.font = [UIFont systemFontOfSize:12];
        [headerLabel sizeToFit];
        [headerView addSubview:headerLabel];
        return headerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == _searchWordCandidatesTableView) {
        return 14.5;
    }
    return 0;
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    if (scrollView == (UIScrollView*)_searchWordCandidatesTableView) {
        CGFloat sectionHeaderHeight =
        [self tableView:_searchWordCandidatesTableView heightForHeaderInSection:0];
        if (scrollView.contentOffset.y >= -64 && scrollView.contentOffset.y <= -64 + sectionHeaderHeight) {
            scrollView.contentInset
            = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, scrollView.contentInset.bottom, 0);
        }
        else if (scrollView.contentOffset.y > -64 + sectionHeaderHeight) {
            scrollView.contentInset
            = UIEdgeInsetsMake(64 - sectionHeaderHeight, 0, scrollView.contentInset.bottom, 0);
        }
    }
}

#pragma mark -
- (void)doSearchWithKey:(NSString*)key
{
    [_searchResults removeAllObjects]; // 搜索前清空结果列表
    if ([key length]) {
        [SVProgressHUD showWithStatus:@"正在搜索..." maskType:SVProgressHUDMaskTypeBlack];
        [_searchBar resignFirstResponder];
        [LibraryService searchBookByIndex:@"all"
                                  withKey:key
                                  success:^(NSArray* results) {
                                      [_searchResults addObjectsFromArray:results];
                                      [_searchResultsTableView reloadData];
                                      [self.searchDisplayController setActive:NO];
                                      [self setHotSearchViewHidden:YES];
                                      if ([_searchResults count] == 0) {
                                          [SVProgressHUD showInfoWithStatus:@"换一个姿势试试#_#"
                                                                   maskType:SVProgressHUDMaskTypeBlack];
                                      }
                                      else {
                                          [SVProgressHUD dismiss];
                                      }
                                      [_searchBar setText:key];
                                  }
                                  failure:^(NSInteger statusCode) {
                                      if (statusCode == -1001) { // timeout
                                          [SVProgressHUD showInfoWithStatus:@"网络慢如蜗牛喔-_-!"
                                                                   maskType:SVProgressHUDMaskTypeBlack];
                                      }
                                      else {
                                          [SVProgressHUD showErrorWithStatus:@"网络出错啦~" maskType:SVProgressHUDMaskTypeBlack];
                                      }
                                  }];
    }
}

@end
