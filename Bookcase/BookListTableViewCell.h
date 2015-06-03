//
//  BookListTableViewCell.h
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/6/3.
//
//

#import <UIKit/UIKit.h>

@interface BookListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *publisherLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
