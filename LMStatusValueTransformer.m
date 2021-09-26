//
//  LMStatusValueTransformer.m
//  LaunchMonitor
//
//  Created by Sergey on 5/29/19.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import "LMStatusValueTransformer.h"
#import <servers/bootstrap.h>


@implementation LMStatusValueTransformer

+ (void) initialize {
	[NSValueTransformer setValueTransformer: [self new] forName: NSStringFromClass(self)];
}

+ (Class) transformedValueClass {
	return [NSString class];
}

+ (BOOL) allowsReverseTransformation {
	return NO;
}

- (id) transformedValue: (id) value {
	bootstrap_status_t status = [value intValue];
	switch (status) {
		case BOOTSTRAP_STATUS_ACTIVE:
			return @"Active";
		case BOOTSTRAP_STATUS_ON_DEMAND:
			return @"On Demand";
		case BOOTSTRAP_STATUS_INACTIVE:
			return @"Inactive";
		case ~0:
			return nil;
		case ~(1 << 0):
			return @"Subset";
		case ~(1 << 1):
			return @"Implicit subset";
		case ~(1 << 2):
			return @"Moved subset";
		case ~(1 << 3):
			return @"Per-user";
		case ~(1 << 4):
			return @"XPC domain";
		case ~(1 << 5):
			return @"Singleton XPC domain";
		default:
			NSLog(@"Unknown status value %d", status);
			return @"Unknown";
	}
}

@end
