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
#import "Podcast.h"

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
                             NSArray *podcasts = [self parseDict:dict];
                             [subject sendNext:podcasts];
                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                             [subject sendError:error];
                         }];
    return subject;
}

//- (RACSignal *)getTopPodcasts {
//    RACSubject *subject = [RACSubject subject];
//    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"SampleResponse" ofType:@"txt"];
//    NSString *string = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    NSDictionary *dict = [XMLReader dictionaryForXMLString:string error:nil];
//    NSArray *podcasts = [self parseDict:dict];
//    
//    dispatch_after(0, dispatch_get_main_queue(), ^{
//        [subject sendNext:podcasts];
//    });
//    
//    return subject;
//}

// TODO: Extract strings to a constants file
- (NSArray *)parseDict:(NSDictionary *)dict {
    NSArray *podcastDicts = dict[@"feed"][@"entry"];
    NSMutableArray *podcasts = [NSMutableArray new];
    for (NSDictionary *podcastDict in podcastDicts) {
        Podcast *podcast = [Podcast new];
        [podcasts addObject:podcast];
        
        podcast.imagePath = [self cleanString:podcastDict[@"im:image"][2][@"text"]];
        podcast.itunesPath = [self cleanString:podcastDict[@"id"][@"text"]];
        podcast.summary = [self cleanString:podcastDict[@"summary"][@"text"]];
        
        NSString *fullTitle = [self cleanString:podcastDict[@"title"][@"text"]];
        NSArray *components = [fullTitle componentsSeparatedByString:@" - "];
        podcast.title = components[0];
        podcast.author = components[1];
    }
    
    return podcasts;
}

- (NSString *)cleanString:(NSString *)string {
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
































