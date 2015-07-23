//
//  MyStarBooks.m
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/7/16.
//
//

#import "MyStarBooks.h"

NSString* const MyStarBooksDidUpdateNotification = @"MyStarBooksDidUpdateNotification";

static NSString *const kMyStarBooksKey = @"MyStarBooks";

@implementation MyStarBooks

#pragma mark - MyStarBooks Manage
+ (void)addBookWithName:(NSString *)name isbn:(NSString *)isbn url:(NSString *)url {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *starBooks = [[defaults objectForKey:kMyStarBooksKey] mutableCopy];
    if (!starBooks) {
        starBooks = [NSMutableDictionary new];
    }
    starBooks[isbn] = @{ @"name" : name,
                         @"url" : url,
                         @"isbn" : isbn,
                         @"update_time" : [NSDate date] };
    [defaults setObject:[starBooks copy] forKey:kMyStarBooksKey];
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:MyStarBooksDidUpdateNotification object:self];
}

+ (void)removeBook:(NSString *)isbn {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *starBooks = [[defaults objectForKey:kMyStarBooksKey] mutableCopy];
    [starBooks removeObjectForKey:isbn];
    [defaults setObject:[starBooks copy] forKey:kMyStarBooksKey];
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:MyStarBooksDidUpdateNotification object:self];
}

+ (BOOL)hasBook:(NSString *)isbn {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *starBooks = [defaults objectForKey:kMyStarBooksKey];
    if (starBooks && starBooks[isbn]) {
        return YES;
    }
    return NO;
}

+ (NSArray *)all {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *starBooks = [defaults objectForKey:kMyStarBooksKey];
    NSArray *sortedKeys = [starBooks keysSortedByValueUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        return [obj1[@"update_time"] compare:obj2[@"update_time"]];
    }];
    NSMutableArray *allBooks = [NSMutableArray arrayWithCapacity:sortedKeys.count];
    for (NSString *key in sortedKeys) {
        [allBooks addObject:starBooks[key]];
    }
    return [allBooks copy];
}

@end
