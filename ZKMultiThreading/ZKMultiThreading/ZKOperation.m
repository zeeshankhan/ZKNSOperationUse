//
//  ZKOperation.m
//  ZKMultiThreading
//
//  Created by Zeeshan Khan on 22/08/14.
//  Copyright (c) 2014 Zeeshan Khan. All rights reserved.
//

#import "ZKOperation.h"

@implementation ZKOperation

- (void)main {

    if ([self isCancelled] == NO) {
        NSLog(@"[main] Executing Subclass of NSOperation, Is Main thread: %@", [NSThread isMainThread] ? @"YES" : @"NO");
    }
}

// If you want to control the access of execution of Any Operation, override this method
//- (void)start {
//
//    if ([self isCancelled] == NO) {
//        NSLog(@"[start] Executing Subclass of NSOperation, Is Main thread: %@", [NSThread isMainThread] ? @"YES" : @"NO");
//    }
//
//}

@end
