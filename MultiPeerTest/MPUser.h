//
//  MPUser.h
//  MultiPeerTest
//
//  Created by Terry Lewis II on 7/23/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MCPeerID;
@interface MPUser : NSObject <NSCoding>
@property(strong,nonatomic)MCPeerID *peerID;
@property(strong,nonatomic)UIColor *userColor;
@property(strong,nonatomic)NSString *displayName;
@end
