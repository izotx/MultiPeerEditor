//
//  MessageData.h
//  MultiPeerTest
//
//  Created by sadmin on 7/18/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
@class MPUser;
@interface MessageData : NSObject <NSCoding>
@property NSRange range;
@property BOOL selection;
@property (nonatomic,strong)NSString * messageText;
@property (nonatomic,strong)NSAttributedString * attributedString;

@property(strong,nonatomic)MPUser *user;

//other properties will go here, for example selection and etc.



@end
