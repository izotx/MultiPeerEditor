//
//  MPUser.m
//  MultiPeerTest
//
//  Created by Terry Lewis II on 7/23/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.
//

#import "MPUser.h"

@implementation MPUser
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.peerID forKey:@"peerID"];
    [aCoder encodeObject:self.userColor forKey:@"userColor"];
    [aCoder encodeObject:self.displayName forKey:@"displayName"];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self.peerID = [aDecoder decodeObjectForKey:@"peerID"];
    self.userColor = [aDecoder decodeObjectForKey:@"userColor"];
    self.displayName = [aDecoder decodeObjectForKey:@"displayName"];
    return self;
}
@end
