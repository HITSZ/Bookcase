//
//  LibraryService.h
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/6/1.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LibraryServiceStatusCode) {
    LibraryServiceStatusNotLogin,
    LibraryServiceStatusError
};

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

+ (void)getBookDetailWithUrl:(NSString*)url
                     success:(void (^)(NSDictionary*))success
                     failure:(void (^)(void))failure;


+ (void)recommendBookWithPayload:(NSArray*)payload
                         success:(void (^)(NSInteger code))success
                         failure:(void (^)(void))failure;

+ (void)getMyBorrowedBooksWithReaderno:(NSString *)readerno
                               success:(void (^)(NSArray *))success
                               failure:(void (^)(void))failure;

+ (void)renewMyBorrowedBooksInBarcodes:(NSArray *)barcodes
                               success:(void (^)(NSString *))success
                               failure:(void (^)(LibraryServiceStatusCode code))failure;

+ (void)loginWithUsername:(NSString*)username
                 password:(NSString*)password
                  success:(void (^)(NSString*))success
                  failure:(void (^)(void))failure;

@end
