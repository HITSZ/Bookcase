//
//  LibraryService.m
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/6/1.
//
//

#import "LibraryService.h"

#import "AFNetworking.h"
#import "RXMLElement.h"

@implementation LibraryService

/**
 *  Obtain current hot search words list by index type.
 *
 *  @param index   Type of words, [all|author]
 *  @param success Callback after success
 *
 *  @return Boolean value to indicate whether success or not.
 */
+ (BOOL)getHotSearchWordsByIndex:(NSString *)index success:(void (^)(NSArray *))success {
    __block BOOL ret = true;
    NSString *url =
    [NSString stringWithFormat:@"http://219.223.211.171/Search/gethotword.jsp?v_index=%@", index];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:url
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSString *wrappedResponse =
             [NSString stringWithFormat:@"<resp>%@</resp>",
              [[NSString alloc] initWithData:responseObject encoding:4]];
             RXMLElement *rootXML = [RXMLElement elementFromXMLString:wrappedResponse encoding:4];
             NSMutableArray *hotWords = [NSMutableArray new];
             [rootXML iterate:@"a"
                   usingBlock:^(RXMLElement *anchor) {
                       [hotWords
                        addObject:[anchor.text stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                   }];
             success([hotWords copy]);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             ret = false;
         }];
    return ret;
}

@end
