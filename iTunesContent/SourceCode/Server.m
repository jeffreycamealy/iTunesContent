//
//  Server.m
//  iTunesContent
//
//  Created by Jeffrey Camealy on 4/23/14.
//  Copyright (c) 2014 bearMountain. All rights reserved.
//

#import "Server.h"
#import <AFNetworking.h>
#import <ReactiveCocoa.h>
#import "ServerConstants.h"
#import "XMLReader.h"

@interface Server () {
    AFHTTPRequestOperationManager *requestOperationManager;
    NSMutableString *bufferString;
}
@end


@implementation Server

#pragma mark - Init Method

- (id)init {
    if (self = [super init]) {
        requestOperationManager = [AFHTTPRequestOperationManager manager];
        AFXMLParserResponseSerializer *responseSerializer = [AFXMLParserResponseSerializer new];
        responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/atom+xml", nil];
        requestOperationManager.responseSerializer = responseSerializer;
    }
    return self;
}


#pragma mark - Public API

- (RACSignal *)getTopPodcasts {
    RACSubject *subject = [RACSubject subject];
    [requestOperationManager GET:topTechPodcastsURL
                      parameters:nil
                         success:^(AFHTTPRequestOperation *operation, NSXMLParser *xmlParser) {
                             NSDictionary *dict = [XMLReader dictionaryForXMLString:operation.responseString error:nil];
                             dict = nil;
                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                             [subject sendError:error];
                         }];
    return subject;
}

@end

































