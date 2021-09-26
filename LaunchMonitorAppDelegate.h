//
//  LaunchMonitorAppDelegate.h
//  LaunchMonitor
//
//  Created by Sergey on 5/28/19.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import <dispatch/dispatch.h>
#import <Cocoa/Cocoa.h>
#import "LMBootstrapContext.h"
#include "LMPrivilegedBootstrapContextFactory.h"

@interface LaunchMonitorAppDelegate : NSObject <NSApplicationDelegate> {
	LMPrivilegedBootstrapContextFactory *contextFactory;
	BOOL showAllNestedContexts;
	dispatch_queue_t queue;
}

@property (retain) LMBootstrapContext *context;

- (IBAction) showNestedContexts: (id) sender;
- (IBAction) refresh: (id) sender;

@end
