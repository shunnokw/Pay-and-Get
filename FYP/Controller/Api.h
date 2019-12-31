//
//  Api.h
//  FYP
//
//  Created by Jason Wong on 1/1/2020.
//  Copyright © 2020 Jason Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Api : NSObject

@property (strong, nonatomic) NSString *appTitle;
@property (strong, nonatomic) NSString *baseURL;
@property (strong, nonatomic) NSString *restApiURL;
@property (strong, nonatomic) NSString *firstTitle;
@property (strong, nonatomic) NSString *firstTitleUrl;
@property (strong, nonatomic) NSString *firstSubtitle1;
@property (strong, nonatomic) NSString *firstSubtitle2;
@property (strong, nonatomic) NSString *specialTitle;
@property (assign, nonatomic) NSInteger catNumber;
@property (strong, nonatomic) NSString *specialTitleURL;
@property (strong, nonatomic) NSString *specialSubtitle1;
@property (strong, nonatomic) NSString *specialSubtitle2;
@property (strong, nonatomic) NSString *contentURL;
@property (strong, nonatomic) NSString *searchURL;
@end

NS_ASSUME_NONNULL_END
