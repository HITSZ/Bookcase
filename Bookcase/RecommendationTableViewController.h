//
//  RecommendationTableViewController.h
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/7/29.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RecommendFormField) {
    RecommendFormFieldTitle,
    RecommendFormFieldResponsible,
    RecommendFormFieldFeedback,
    RecommendFormFieldISBN,
    RecommendFormFieldPress,
    RecommendFormFieldPubYear,
    RecommendFormFieldName,
    RecommendFormFieldWorkplace,
    RecommendFormFieldEmail,
    RecommendFormFieldCaptcha
};

@interface RecommendationTableViewController : UITableViewController

@end
