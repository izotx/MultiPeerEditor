//
//  MCNearbyHelper.h
//  MultiPeerTest
//
//  Created by sadmin on 7/5/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MCNearbyServiceAdvertiser;
@import MultipeerConnectivity;
typedef void (^MCNearbyAdvertiser)(MCNearbyServiceAdvertiser * advertiser);
typedef void (^MCNearbyBrowser)(MCNearbyServiceBrowser * browser);

@interface MCNearbyHelper : NSObject
@property MCPeerID * peerId;
-(instancetype)initWithName:(NSString *)name;

@property (nonatomic, strong) MCNearbyServiceAdvertiser * advertiser;
@property (nonatomic, strong) MCNearbyServiceBrowser  * browser;
@property(nonatomic,strong) MCSession * session;



@end
