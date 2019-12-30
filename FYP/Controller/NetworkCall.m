//
//  NetworkCall.m
//  FYP
//
//  Created by Jason Wong on 27/12/2019.
//  Copyright © 2019 Jason Wong. All rights reserved.
//

#import "NetworkCall.h"

@implementation NetworkCall 

- (void) downloadJson {
    NSLog(@"Downloading data from Json");
    NSString *urlString =@"https://file.shunnokw.com/link.json";
    NSURL *url = [NSURL URLWithString:urlString];
    [[NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"Finished fetching");
        
        NSString *dummyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"DummyString: %@", dummyString);
        
    }] resume];
}

@end
