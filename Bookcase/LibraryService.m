//
//  LibraryService.m
//  Bookcase
//
//  Created by Ching-Hua Hung on 15/6/1.
//
//

#import "LibraryService.h"

#import "AFNetworking.h"
#import "IGHTMLQuery.h"

@implementation LibraryService

+ (void)getHotSearchWordsByIndex:(NSString*)index success:(void (^)(NSArray*))success
{
    NSString* urlString = @"http://219.223.211.171/Search/gethotword.jsp";
    NSDictionary* parameters = @{ @"v_index" : index };
    [self requestByMethod:@"GET"
                  withURL:urlString
               parameters:parameters
                  success:^(AFHTTPRequestOperation* operation, id responseObject) {
                      NSMutableArray* hotWords = [NSMutableArray new];
                      IGHTMLDocument* html = [[IGHTMLDocument alloc] initWithHTMLData:responseObject encoding:@"utf8" error:nil];
                      [[html queryWithXPath:@"//a"] enumerateNodesUsingBlock:^(IGXMLNode* content, NSUInteger idx, BOOL* stop) {
                          [hotWords addObject:content.text];
                      }];
                      success([hotWords copy]);
                  }
                  failure:^(AFHTTPRequestOperation* operation, NSError* error){

                  }];
}

+ (void)getSearchWordCandidatesByIndex:(NSString*)index
                               withKey:(NSString*)key
                               success:(void (^)(NSArray*))success
                               failure:(void (^)(void))failure
{
    __block NSArray* kCandidates = [NSArray new];
    key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([key length] == 0) { // 搜索词为空时直接返回空数组
        success(kCandidates);
        return;
    }

    index = [index isEqualToString:@"all"] ? @"title" : index; // index == 'all'时，转为'title'
    NSString* urlString = @"http://219.223.211.171/Search/searchshowAUTO.jsp";
    NSDictionary* parameters = @{
                                 @"term" : key,
                                 @"v_index" : index,
                                 @"v_tablearray" : @"bibliosm",
                                 @"sortfield" : @"score",
                                 @"sorttype" : @"desc"
                                 };
    [self requestByMethod:@"POST"
                  withURL:urlString
               parameters:parameters
                  success:^(AFHTTPRequestOperation* operation, id responseObject) {
                      kCandidates = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:nil];
                      success(kCandidates);
                  }
                  failure:^(AFHTTPRequestOperation* operation, NSError* error){

                  }];
}

+ (void)searchBookByIndex:(NSString*)index
                  withKey:(NSString*)key
                  success:(void (^)(NSArray*))success
                  failure:(void (^)(void))failure
{
    NSMutableArray* searchResults = [NSMutableArray new];
    key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([key length] == 0) {
        success([searchResults copy]);
        return;
    }

    NSString* urlString = @"http://219.223.211.171/Search/searchshow.jsp";
    NSDictionary* parameters = @{
                                 @"v_value" : key,
                                 @"v_index" : index,
                                 @"v_tablearray" : @"bibliosm",
                                 @"sortfield" : @"score",
                                 @"sorttype" : @"desc",
                                 @"library" : @"F44010"
                                 };
    [self requestByMethod:@"GET"
                  withURL:urlString
               parameters:parameters
                  success:^(AFHTTPRequestOperation* operation, id responseObject) {
                      IGHTMLDocument* html = [[IGHTMLDocument alloc] initWithHTMLData:responseObject encoding:@"utf8" error:nil];
                      [[html queryWithXPath:@"//ul[@class='booklist']/li"]
                       enumerateNodesUsingBlock:^(IGXMLNode* node, NSUInteger idx, BOOL* stop) {
                           IGXMLNode* titleNode = [[node queryWithXPath:@"h3[@class='title']/a"] firstObject];

                           NSString* href = [titleNode attribute:@"href"];
                           href = [NSString stringWithFormat:@"http://219.223.211.171/Search/%@", href];
                           NSString* title = [titleNode.text
                                              stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

                           NSString* author =
                           [[[node queryWithXPath:@"div[@class='info']/span[@class='author']"] firstObject] text];
                           NSString* publisher =
                           [[[node queryWithXPath:@"div[@class='info']/span[@class='publisher']"] firstObject] text];

                           [searchResults addObject:@{
                                                      @"title" : title,
                                                      @"href" : href,
                                                      @"author" : author,
                                                      @"publisher" : publisher
                                                      }];
                       }];
                      success([searchResults copy]);
//                      NSLog(@"%@", searchResults);
                  }
                  failure:^(AFHTTPRequestOperation* operation, NSError* error){
                      failure();
                  }];
    [self sendSearchWordByIndex:index withKey:key];
}

+ (void)getBookDetailWithUrl:(NSString*)url success:(void (^)(NSString*))success
{
//    AFHTTPRequestSerializer* requestSerializer = [AFHTTPRequestSerializer serializer];
//    AFHTTPRequestOperation* requestOperation = [[AFHTTPRequestOperation alloc]
//                                                initWithRequest:[requestSerializer requestWithMethod:@"GET" URLString:url parameters:nil error:nil]];
//    AFHTTPResponseSerializer* responseSerializer = [AFHTTPResponseSerializer serializer];
//    [requestOperation setResponseSerializer:responseSerializer];
//
//    // 同步请求，小心！！！
//    [requestOperation start];
//    [requestOperation waitUntilFinished];
//
//    IGHTMLDocument* detailHtml =
//    [[IGHTMLDocument alloc] initWithHTMLData:[requestOperation responseObject] encoding:@"utf8" error:nil];
    //    NSString* bookName = [[[detailHtml queryWithXPath:@"//div[@class='booksinfo']/h3"] firstObject] text];
    //    success(bookName);
}

+ (void)sendSearchWordByIndex:(NSString*)index withKey:(NSString*)key
{
    NSString* urlString = @"http://219.223.211.171/Search/hotword.jsp";
    NSDictionary* parameters = @{ @"v_index" : index, @"v_value" : key };
    [self requestByMethod:@"POST"
                  withURL:urlString
               parameters:parameters
                  success:^(AFHTTPRequestOperation* operation, id responseObject) {

                  }
                  failure:^(AFHTTPRequestOperation* operation, NSError* error){

                  }];
}

+ (void)requestByMethod:(NSString*)method
                withURL:(NSString*)url
             parameters:(NSDictionary*)parameters
                success:(void (^)(AFHTTPRequestOperation* operation, id responseObject))success
                failure:(void (^)(AFHTTPRequestOperation* operation, NSError* error))failure
{
    // 过滤v_value中的关键词，根据网页中js代码得知
    NSMutableDictionary* paras = [parameters mutableCopy];
    NSString* v_value = [paras objectForKey:@"v_value"];
    if (v_value) {
        [paras setObject:[self filterString:v_value] forKey:@"v_value"];
    }
    parameters = [paras copy];

    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    method = [method lowercaseString];
    if ([method isEqualToString:@"post"]) {
        [manager POST:url
           parameters:parameters
              success:^(AFHTTPRequestOperation* operation, id responseObject) {
                  success(operation, responseObject);
              }
              failure:^(AFHTTPRequestOperation* operation, NSError* error) {
                  failure(operation, error);
                  NSLog(@"\n----POST----\n%s\n%@\n%@\n------------", __func__, parameters, error);
              }];
    }
    else {
        [manager GET:url
          parameters:parameters
             success:^(AFHTTPRequestOperation* operation, id responseObject) {
                 success(operation, responseObject);
             }
             failure:^(AFHTTPRequestOperation* operation, NSError* error) {
                 failure(operation, error);
                 NSLog(@"\n----GET----\n%s\n%@\n%@\n-----------", __func__, parameters, error);
             }];
    }
}

+ (NSString*)filterString:(NSString*)origin
{
    NSArray* filterWords = @[
                             @"'",
                             @"\"",
                             @"\\\'",
                             @"\\\"",
                             @"\\)",
                             @"\\*",
                             @";",
                             @"<",
                             @">",
                             @"%",
                             @"\\(",
                             @"\\|",
                             @"&",
                             @"\\+",
                             @"$",
                             @"@",
                             @"\r",
                             @"\n",
                             @",",
                             @"select ",
                             @" and ",
                             @" in ",
                             @" or ",
                             @"insert ",
                             @"delete ",
                             @"update ",
                             @"drop "
                             ];
    for (NSString* word in filterWords) {
        origin = [origin stringByReplacingOccurrencesOfString:word withString:@" "];
    }
    return origin;
}

@end
