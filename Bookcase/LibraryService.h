//
//  LibraryService.h
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/6/1.
//
//

#import <Foundation/Foundation.h>

@interface LibraryService : NSObject

+ (void)getHotSearchWordsByIndex:(NSString*)index success:(void (^)(NSArray*))success;
+ (void)searchBookByIndex:(NSString*)index
                  withKey:(NSString*)key
                  success:(void (^)(NSArray*))success
                  failure:(void (^)(NSInteger))failure;

+ (void)getSearchWordCandidatesByIndex:(NSString*)index
                               withKey:(NSString*)key
                               success:(void (^)(NSArray*))success
                               failure:(void (^)(void))failure;

+ (void)getBookDetailWithUrl:(NSString*)url success:(void (^)(NSDictionary*))success failure:(void (^)(void))failure;

@end
