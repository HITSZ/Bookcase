//
//  LoginManager.m
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/8/6.
//
//

#import "LoginManager.h"
#import "LibraryService.h"

static NSString *const kUsername = @"Username";
static NSString *const kPassword = @"Password";
static NSString *const kReaderno = @"Readerno";

@interface LoginManager ()

@property(nonatomic, readwrite, setter=setReaderno:) NSString *readerno;
@property(nonatomic, readwrite, setter=setUsername:) NSString *username;
@property(nonatomic, setter=setPassword:) NSString *password;

@end

@implementation LoginManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _readerno = [[NSUserDefaults standardUserDefaults] objectForKey:kReaderno];
        _username = [[NSUserDefaults standardUserDefaults] objectForKey:kUsername];
    }
    return self;
}

+ (instancetype)sharedManager {
    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                  success:(void (^)(NSString *))success
                  failure:(void (^)(NSString *))failure {
    [LibraryService loginWithUsername:username
                             password:password
                              success:^(NSString *msg) {
                                  if ([msg isEqualToString:@"OK"]) {
                                      self.username = username;
                                      self.password = password;
                                      NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
                                      for (NSHTTPCookie *cookie in cookies) {
                                          if ([cookie.name isEqualToString:@"recordno"]) {
                                              self.readerno = cookie.value;
                                          }
                                      }
                                      success(@"登录成功!");
                                  } else {
                                      failure(msg);
                                  }
                              }
                              failure:^{
                                  failure(@"网络错误!");
                              }];
}

- (BOOL)isLogin {
    return self.readerno ? YES : NO;
}

- (void)logout {
    self.username = nil;
    self.password = nil;
    self.readerno = nil;
}

#pragma mark -

- (void)setUsername:(NSString *)username {
    if (![_username isEqualToString:username]) {
        _username = username;
        [[NSUserDefaults standardUserDefaults] setObject:username forKey:kUsername];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)setPassword:(NSString *)password {
    if (![_password isEqualToString:password]) {
        _password = password;
        [[NSUserDefaults standardUserDefaults] setObject:password forKey:kPassword];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)setReaderno:(NSString *)readerno {
    if (![_readerno isEqualToString:readerno]) {
        _readerno = readerno;
        [[NSUserDefaults standardUserDefaults] setObject:readerno forKey:kReaderno];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
