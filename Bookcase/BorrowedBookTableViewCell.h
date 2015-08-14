//
//  BorrowedBookTableViewCell.h
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/8/15.
//
//

#import <UIKit/UIKit.h>

@interface BorrowedBookTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *barcodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *loandateLabel;
@property (weak, nonatomic) IBOutlet UILabel *returndateLabel;

- (void)updateLabelsWithBook:(NSDictionary *)book;

@end
