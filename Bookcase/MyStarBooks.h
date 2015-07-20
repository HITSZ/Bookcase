//
//  MyStarBooks.h
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/7/16.
//
//

#import <Foundation/Foundation.h>

@interface MyStarBooks : NSObject

+ (void)addBookWithName:(NSString*)name isbn:(NSString*)isbn url:(NSString*)url;
+ (void)removeBook:(NSString*)isbn;
+ (BOOL)hasBook:(NSString*)isbn;
+ (NSArray*)all;

@end
