//
//  LoginManager.h
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/8/6.
//
//

#import <Foundation/Foundation.h>

@interface LoginManager : NSObject

@property(nonatomic, readonly) NSString *readerno;
@property(nonatomic, readonly) NSString *username;

+ (instancetype)sharedManager;

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                  success:(void (^)(NSString *))success
                  failure:(void (^)(NSString *))failure;

- (BOOL)isLogin;
- (void)logout;

@end
