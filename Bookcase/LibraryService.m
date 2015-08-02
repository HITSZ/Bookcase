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
#import "RecommendationTableViewController.h"

@implementation LibraryService

+ (void)getHotSearchWordsByIndex:(NSString*)index success:(void (^)(NSArray*))success {
    NSString* urlString = @"http://219.223.211.171/Search/gethotword.jsp";
    NSDictionary* parameters = @{ @"v_index" : index };
    [self requestByMethod:@"GET"
                  withURL:urlString
               parameters:parameters
                  timeout:0
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
                               failure:(void (^)(void))failure {
    __block NSArray* kCandidates = [NSArray new];
    key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([key length] == 0) {  // 搜索词为空时直接返回空数组
        success(kCandidates);
        return;
    }

    index = [index isEqualToString:@"all"] ? @"title" : index;  // index == 'all'时，转为'title'
    NSString* urlString = @"http://219.223.211.171/Search/searchshowAUTO.jsp";
    NSDictionary* parameters = @{ @"term" : key,
                                  @"v_index" : index,
                                  @"v_tablearray" : @"bibliosm",
                                  @"sortfield" : @"score",
                                  @"sorttype" : @"desc" };
    [self requestByMethod:@"POST"
                  withURL:urlString
               parameters:parameters
                  timeout:1
                  success:^(AFHTTPRequestOperation* operation, id responseObject) {
                      kCandidates = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:nil];
                      success([self deduplicateObjectsOfArray:kCandidates]);
                  }
                  failure:^(AFHTTPRequestOperation* operation, NSError* error) {
                      failure();
                  }];
}

+ (void)searchBookByIndex:(NSString*)index
                  withKey:(NSString*)key
                  success:(void (^)(NSArray*))success
                  failure:(void (^)(NSInteger))failure {
    NSMutableArray* searchResults = [NSMutableArray new];
    key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([key length] == 0) {
        success([searchResults copy]);
        return;
    }

    NSString* urlString = @"http://219.223.211.171/Search/searchshow.jsp";
    NSDictionary* parameters = @{ @"v_value" : key,
                                  @"v_index" : index,
                                  @"v_tablearray" : @"bibliosm",
                                  @"sortfield" : @"score",
                                  @"sorttype" : @"desc",
                                  @"library" : @"F44010" };
    [self requestByMethod:@"GET"
                  withURL:urlString
               parameters:parameters
                  timeout:10
                  success:^(AFHTTPRequestOperation* operation, id responseObject) {
                      IGHTMLDocument* html = [[IGHTMLDocument alloc] initWithHTMLData:responseObject encoding:@"utf8" error:nil];
                      [[html queryWithXPath:@"//ul[@class='booklist']/li"] enumerateNodesUsingBlock:^(IGXMLNode* node, NSUInteger idx, BOOL* stop) {
                          IGXMLNode* titleNode = [[node queryWithXPath:@"h3[@class='title']/a"] firstObject];

                          NSString* href = [titleNode attribute:@"href"];
                          href = [NSString stringWithFormat:@"http://219.223.211.171/Search/%@", href];
                          NSString* title = [titleNode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

                          NSString* author = [[[node queryWithXPath:@"div[@class='info']/span[@class='author']"] firstObject] text];
                          NSString* publisher = [[[node queryWithXPath:@"div[@class='info']/span[@class='publisher']"] firstObject] text];

                          [searchResults addObject:@{ @"title" : title, @"href" : href, @"author" : author, @"publisher" : publisher }];
                      }];
                      success([searchResults copy]);
                      // NSLog(@"%@", searchResults);
                  }
                  failure:^(AFHTTPRequestOperation* operation, NSError* error) {
                      failure(error.code);
                  }];
    [self sendSearchWordByIndex:index withKey:key];
}

+ (void)getBookDetailWithUrl:(NSString*)url
                     success:(void (^)(NSDictionary*))success
                     failure:(void (^)(void))failure {
    [self requestByMethod:@"GET"
                  withURL:url
               parameters:nil
                  timeout:10
                  success:^(AFHTTPRequestOperation* operation, id responseObject) {
                      NSMutableDictionary* bookDetail = [NSMutableDictionary new];
                      [bookDetail setObject:[NSMutableDictionary new] forKey:@"basic"];
                      [bookDetail setObject:[NSMutableDictionary new] forKey:@"status"];

                      NSMutableArray* keys = [NSMutableArray new];
                      IGHTMLDocument* html = [[IGHTMLDocument alloc] initWithHTMLData:responseObject encoding:@"utf8" error:nil];

                      // 基本信息
                      [[html queryWithXPath:@"//div[@class='booksinfo']"] enumerateNodesUsingBlock:^(IGXMLNode* node, NSUInteger idx, BOOL* stop) {
                          NSString* bookName = [[[[node queryWithXPath:@"h3[@class='title']"] firstObject] text] componentsSeparatedByString:@"/ "][0];
                          [[bookDetail objectForKey:@"basic"] setObject:bookName forKey:@"书 名"];
                          [keys addObject:@"书 名"];
                      }];
                      [[html queryWithXPath:@"//div[@class='righttop']/ul/li"] enumerateNodesUsingBlock:^(IGXMLNode* node, NSUInteger idx, BOOL* stop) {
                          NSString* liText = [[node text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                          NSArray* liSplitedText = [liText componentsSeparatedByString:@"："];
                          if ([liSplitedText[0] length] > 0 && [liSplitedText[1] length] > 0) {
                              [[bookDetail objectForKey:@"basic"] setObject:liSplitedText[1] forKey:liSplitedText[0]];
                              [keys addObject:liSplitedText[0]];
                              [[bookDetail objectForKey:@"basic"] setObject:[keys copy] forKey:@"keys"];
                          }
                      }];

                      // 馆藏情况
                      // 在馆
                      NSMutableArray* status = [NSMutableArray new];
                      /*
                       * github issue#19
                       */
                      __block NSUInteger index;
                      // 定位包含'深圳大学城图书馆'的'div.tab_4_title'，并遍历所有a子标签，确定utsz的idx
                      [[html queryWithXPath:@"//div[@class='tab_4_title' and a[contains(@title,'深圳大学城图书馆(深圳市科技图书馆)')]]/a"]
                       enumerateNodesUsingBlock:^(IGXMLNode* node, NSUInteger idx, BOOL* stop) {
                           if ([[node attribute:@"title"] hasPrefix:@"深圳大学城图书馆(" @"深圳市科技图书馆)"]) {
                               index = idx;
                           }
                       }];
                      // 选取'div.tab_4_show'的第index子标签'div.tab_4_text'
                      [[html queryWithXPath:@"//div[@class='tab_4_title' and a[contains(@title,'深圳大学城图书馆(深圳市科技图书馆)')]]/following-sibling::div[1]"]
                       enumerateNodesUsingBlock:^(IGXMLNode* node, NSUInteger idx, BOOL* stop) {
                           NSString* xpath = [NSString stringWithFormat:
                                              @"div[%lu]//span[@class='title_1' and contains(span,'可外借馆藏')]/following-sibling::table[1]//tr[position()>1]",
                                              (unsigned long)(index + 1)];
                           [[node queryWithXPath:xpath] enumerateNodesUsingBlock:^(IGXMLNode* node, NSUInteger idx, BOOL* stop) {
                               NSMutableArray* statusInfo = [NSMutableArray new]; // 三元组(条形码，馆藏状态，流通类别)
                               [[node queryWithXPath:@"td"] enumerateNodesUsingBlock:^(IGXMLNode* node, NSUInteger idx, BOOL* stop) {
                                   if (idx == 0 || idx == 3 || idx == 5) {
                                       [statusInfo addObject:[node text]];
                                   }
                               }];
                               [status addObject:statusInfo];
                           }];
                       }];
                      [[bookDetail objectForKey:@"status"] setObject:[status copy] forKey:@"in"];
                      // 已借
                      [status removeAllObjects];
                      [[html queryWithXPath:@"//div[@class='tab_4_show' and div[contains(span,'已借出馆藏')]]//tr[contains(.,'深圳大学城图书馆')]"]
                       enumerateNodesUsingBlock:^(IGXMLNode* node, NSUInteger idx, BOOL* stop) {
                           NSMutableArray* statusInfo = [NSMutableArray new]; // 二元组(条形码，借还日期)
                           [[node queryWithXPath:@"td"] enumerateNodesUsingBlock:^(IGXMLNode* node, NSUInteger idx, BOOL* stop) {
                               if (idx == 0 || idx == 5) {
                                   [statusInfo addObject:[node text]];
                               }
                           }];
                           [status addObject:statusInfo];
                       }];
                      [[bookDetail objectForKey:@"status"] setObject:[status copy] forKey:@"out"];
                      // NSLog(@"%@", bookDetail);
                      success([bookDetail copy]);
                  }
                  failure:^(AFHTTPRequestOperation* operation, NSError* error) {
                      failure();
                  }];
}

+ (void)sendSearchWordByIndex:(NSString*)index withKey:(NSString*)key {
    NSString* urlString = @"http://219.223.211.171/Search/hotword.jsp";
    NSDictionary* parameters = @{ @"v_index" : index,
                                  @"v_value" : key };
    [self requestByMethod:@"POST"
                  withURL:urlString
               parameters:parameters
                  timeout:0
                  success:^(AFHTTPRequestOperation* operation, id responseObject) {

                  }
                  failure:^(AFHTTPRequestOperation* operation, NSError* error){

                  }];
}

+ (void)recommendBookWithPayload:(NSArray*)payload
                         success:(void (^)(NSInteger code))success
                         failure:(void (^)(void))failure {
    NSDictionary* paras = @{ @"title" : payload[RecommendFormFieldTitle],
                             @"responsible" : payload[RecommendFormFieldResponsible],
                             @"feedbackContent" : payload[RecommendFormFieldFeedback],
                             @"isbnIssn" : payload[RecommendFormFieldISBN],
                             @"press" : payload[RecommendFormFieldPress],
                             @"publicationYear" : payload[RecommendFormFieldPubYear],
                             @"name" : payload[RecommendFormFieldName],
                             @"companyName" : payload[RecommendFormFieldWorkplace],
                             @"email" : payload[RecommendFormFieldEmail],
                             @"checkCode" : payload[RecommendFormFieldCaptcha],
                             @"phone" : @"",
                             @"submit" : @"提交" };
    static NSString* const url = @"http://lib.utsz.edu.cn/readersRecommendPurchase/readersRecommendPurchaseForm/save.html";

    [self requestByMethod:@"POST"
                  withURL:url
               parameters:paras
                  timeout:10
                  success:^(AFHTTPRequestOperation* operation, id responseObject) {
                      NSDictionary* code = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                           options:NSJSONReadingAllowFragments
                                                                             error:nil];
                      success([code[@"error"] integerValue]);
                  }
                  failure:^(AFHTTPRequestOperation* operation, NSError* error) {
                      failure();
                  }];
}

#pragma mark -
+ (void)requestByMethod:(NSString*)method
                withURL:(NSString*)url
             parameters:(NSDictionary*)parameters
                timeout:(int)seconds
                success:(void (^)(AFHTTPRequestOperation* operation, id responseObject))success
                failure:(void (^)(AFHTTPRequestOperation* operation, NSError* error))failure {
    if (parameters) {  // 过滤v_value中的关键词，根据网页中js代码得知
        NSMutableDictionary* paras = [parameters mutableCopy];
        NSString* v_value = [paras objectForKey:@"v_value"];
        if (v_value) {
            [paras setObject:[self filterString:v_value] forKey:@"v_value"];
        }
        parameters = [paras copy];
    }

    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.134 Safari/537.36"
                     forHTTPHeaderField:@"User-Agent"];
    if (seconds) {
        [[manager requestSerializer] setTimeoutInterval:seconds];
    }
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
    } else {
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

#pragma mark -
/**
 *  过滤检索词中的关键词，将出现的关键词替换为一个空格符。
 *
 *  @param origin 原始字符串
 *
 *  @return 过滤后的字符串
 */
+ (NSString*)filterString:(NSString*)origin {
    NSArray* filterWords = @[ @"'",
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
                              @"drop " ];
    for (NSString* word in filterWords) {
        origin = [origin stringByReplacingOccurrencesOfString:word withString:@" "];
    }
    return origin;
}

+ (NSArray*)deduplicateObjectsOfArray:(NSArray*)kCandidates {
    return [(NSSet*)[NSOrderedSet orderedSetWithArray:kCandidates] allObjects];
}

@end
