//
//  LaunchMonitorAppDelegate.m
//  LaunchMonitor
//
//  Created by Sergey on 5/28/19.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import "LaunchMonitorAppDelegate.h"

@implementation LaunchMonitorAppDelegate

@synthesize context;

- (void) ensureContextFactory {
	if (contextFactory == nil) {
		contextFactory = [[LMPrivilegedBootstrapContextFactory alloc] initParent];
	}
}

- (void) refetchData {
	dispatch_async(queue, ^{
		LMBootstrapContext *newContext = nil;
		if (showAllNestedContexts) {
			[self ensureContextFactory];
			if (!contextFactory) {
				return;
			}
			newContext = [contextFactory rootContext];
		} else {
			newContext = [LMBootstrapContext rootContextLimitedToCurrentSubtree: YES];
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			self.context = newContext;
		});
	});
}

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification {
	queue = dispatch_queue_create("io.github.bugaevc.LaunchMonitor.ContextCreationQueue", 0);
	[self refetchData];
}

- (IBAction) showNestedContexts: (id) sender {
	showAllNestedContexts = [sender intValue];
	[self refetchData];
}

- (IBAction) refresh: (id) sender {
	[self refetchData];
}

@end
