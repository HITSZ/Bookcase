//
//  BorrowedBookTableViewCell.m
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/8/15.
//
//

#import "BorrowedBookTableViewCell.h"

@implementation BorrowedBookTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -
- (NSArray *)borrowedBookStringKeys {
    return @[@"title", @"barcode", @"loandate", @"returndate"];
}

- (UILabel *)labelForModelKey:(NSString*)key {
    return [self valueForKey:[key stringByAppendingString:@"Label"]];
}

- (void)updateLabelsWithBook:(NSDictionary *)book {
    for (NSString *key in self.borrowedBookStringKeys) {
        [self labelForModelKey:key].text = [book valueForKey:key];
    }
}

@end
