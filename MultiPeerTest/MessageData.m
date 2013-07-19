//
//  MessageData.m
//  MultiPeerTest
//
//  Created by sadmin on 7/18/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.
//

#import "MessageData.h"

@implementation MessageData
- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    NSValue * val = [NSValue valueWithRange:self.range];
    [encoder encodeObject:val forKey:@"range"];
    [encoder encodeObject:self.messageText forKey:@"messageText"];

}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.messageText = [decoder decodeObjectForKey:@"messageText"];
        self.range = [(NSValue *)[decoder decodeObjectForKey:@"range"]rangeValue];
    }
    return self;
}
@end
