//
//  MessageData.m
//  MultiPeerTest
//
//  Created by sadmin on 7/18/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.
//

#import "MessageData.h"
#import "MPUser.h"
@implementation MessageData
- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    NSValue * val = [NSValue valueWithRange:self.range];
    [encoder encodeObject:val forKey:@"range"];
    [encoder encodeObject:self.messageText forKey:@"messageText"];
    [encoder encodeObject:[NSNumber numberWithBool:self.selection] forKey:@"selection"];
    [encoder encodeObject:self.user forKey:@"user"];
    [encoder encodeObject:self.attributedString forKey:@"attributedString"];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.messageText = [decoder decodeObjectForKey:@"messageText"];
        self.range = [(NSValue *)[decoder decodeObjectForKey:@"range"]rangeValue];
        self.selection = [(NSNumber *)[decoder decodeObjectForKey:@"selection"]boolValue];
        self.user = [decoder decodeObjectForKey:@"user"];
        self.attributedString =[decoder decodeObjectForKey:@"attributedString"];
    }
    return self;
}
@end
