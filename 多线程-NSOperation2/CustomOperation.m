//
//  CustomOperation.m
//  多线程-NSOperation2
//
//  Created by Will on 2020/6/4.
//  Copyright © 2020 Will. All rights reserved.
//

#import "CustomOperation.h"

@implementation CustomOperation

- (void)main{
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2];
        NSLog(@"0------%@",[NSThread currentThread]);
    }
}


@end
