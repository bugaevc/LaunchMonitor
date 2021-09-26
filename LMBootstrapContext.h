//
//  LMBootstrapContext.h
//  LaunchMonitor
//
//  Created by Sergey on 5/31/19.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <servers/bootstrap.h>

@interface LMBootstrapContext : NSObject {
	mach_port_t port;
	NSString *name;
	bootstrap_property_t props;
	NSArray *children;
	NSArray *services;
}

+ (LMBootstrapContext *) contextWithPort: (mach_port_t) port
									name: (NSString *) name;

+ (LMBootstrapContext *) rootContextLimitedToCurrentSubtree: (BOOL) limitToCurrentSubtree;
+ (LMBootstrapContext *) currentContext;

- (NSString *) name;
- (NSArray *) children;
- (NSArray *) services;

// For the tree controller.
- (NSArray *) servicesAndChildren;
- (NSString *) jobName;
- (bootstrap_status_t) status;

@end
