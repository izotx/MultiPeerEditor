//
//  MCNearbyHelper.m
//  MultiPeerTest
//
//  Created by sadmin on 7/5/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.
//


#import "MCNearbyHelper.h"
@interface MCNearbyHelper()
{
    MCSession *newSession;
    
}
@end

@implementation MCNearbyHelper

-(instancetype)init{
    self = [super init];
    if(self)
    {
    
    }
    return self;
}

-(instancetype)initWithName:(NSString *)name{
    self = [super init];
    if(self)
    {
        [self createPeerWithDisplayName:name];
        //[self createAdvertiserObject];
        //[self createBrowser];
        
    }
    return self;
}


-(void)createPeerWithDisplayName:(NSString *)displayName{
    MCPeerID * peerId;
    peerId = [[MCPeerID alloc]initWithDisplayName:displayName];
    _peerId= peerId;
}


#pragma mark browsing
//-(void)createBrowser{
//MCNearbyServiceBrowser * browser =[[MCNearbyServiceBrowser alloc]initWithPeer:self.peerId serviceType:SERVICE];
//    
//    browser.delegate = self;
//    self.browser = browser;
//
//}

-(void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error{
     NSLog(@"Browsing Start Error %@",[error debugDescription]);
}

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info{
     NSLog(@"Browsing Found Peer %@", peerID);
}
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID{
     NSLog(@"Browsing Lost Peer %@", peerID);
}

#pragma mark advertising

//-(void)createAdvertiserObject{
//    MCNearbyServiceAdvertiser *advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerId discoveryInfo:nil serviceType:SERVICE];
//    advertiser.delegate = self;
//    self.advertiser =advertiser;
//}

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error{
    NSLog(@"Advertising Start Error %@",[error debugDescription]);
}

-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void (^)(BOOL isTrue, MCSession * _session))invitationHandler{
    NSLog(@"Did receive invitation");
    invitationHandler(YES, _session);
    
}
@end
