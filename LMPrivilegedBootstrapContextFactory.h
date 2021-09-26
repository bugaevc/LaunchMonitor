//
//  LMRemoteBootstrapContext.h
//  LaunchMonitor
//
//  Created by Sergey on 5/31/19.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LMBootstrapContext.h"


@interface LMPrivilegedBootstrapContextFactory : NSObject {
	BOOL isChild;
	NSConnection *connection;
	LMPrivilegedBootstrapContextFactory *remote;
}

- (id) initParent;
- (id) initChild;

- (LMBootstrapContext *) rootContext;
- (LMBootstrapContext *) currentContext;

@end
