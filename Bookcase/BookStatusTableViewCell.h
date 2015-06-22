//
//  BookStatusTableViewCell.h
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/6/22.
//
//

#import <UIKit/UIKit.h>

@interface BookStatusTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *barcodeInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherLabel;
@property (weak, nonatomic) IBOutlet UILabel *barcodeLabel;

@end
