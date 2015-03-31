//
// Created by sbuglakov on 6/7/14.
// Copyright (c) 2014 redetection. All rights reserved.
//

#import "RTKExpense.h"

@implementation RTKExpense

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@(%@); %@; %@>", NSStringFromClass(self.class), self.identifier, self.amount, self.date];
}

@end
