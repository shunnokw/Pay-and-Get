//
//  NetworkCall.m
//  FYP
//
//  Created by Jason Wong on 27/12/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

#import "NetworkCall.h"
#import "Api.h"

/// Getting data from network Json and parse them into api object

@implementation NetworkCall 

- (void) downloadJson {
    NSLog(@"Downloading data from Json");
    NSString *urlString = @"https://file.shunnokw.com/link.json";
    NSURL *url = [NSURL URLWithString:urlString];
    [[NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"Finished fetching");
        
        NSString *dummyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Result: %@", dummyString);
        
        NSError *err;
        NSData *returnedData = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingAllowFragments error: &err];
        if (err) {
            NSLog(@"Failed parsing: ", err);
            return;
        }

        if ([returnedData isKindOfClass: [NSDictionary class]]) {
            NSDictionary *apiDict = (NSDictionary *)returnedData;
            NSLog(apiDict[@"appTitle"]);
        }
    }] resume];
}

@end
