//
//  LibraryService.h
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/6/1.
//
//

#import <Foundation/Foundation.h>

@interface LibraryService : NSObject

+ (BOOL)getHotSearchWordsByIndex:(NSString *)index success:(void (^)(NSArray *))success;

@end
