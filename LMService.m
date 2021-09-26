//
//  LMService.m
//  LaunchMonitor
//
//  Created by Sergey on 5/28/19.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import "LMService.h"

@implementation LMService

@synthesize name;
@synthesize jobName;
@synthesize status;

- (NSArray *) servicesAndChildren {
	return [NSArray array];
}

- (void) dealloc {
	[name release];
	[jobName release];
	[super dealloc];
}

@end
