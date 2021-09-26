//
//  LMRemoteBootstrapContext.m
//  LaunchMonitor
//
//  Created by Sergey on 5/31/19.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import "LMPrivilegedBootstrapContextFactory.h"

static NSString * const REGISTER_NAME = @"io.github.bugaevc.LaunchMonitor.Privileged";

@implementation LMPrivilegedBootstrapContextFactory

+ (BOOL) spawnChild {
	const char *path = [[[NSBundle mainBundle] executablePath] fileSystemRepresentation];

	AuthorizationRef auth = NULL;
	OSStatus err = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &auth);
	if (err != errAuthorizationSuccess) {
		NSLog(@"AuthorizationCreate: %d", err);
		goto out;
	}

	AuthorizationItem items[] = {{ kAuthorizationRightExecute, strlen(path), &path, 0 }};
	AuthorizationRights rights = { 1, items };
	AuthorizationFlags flags = kAuthorizationFlagDefaults | kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights;
	err = AuthorizationCopyRights(auth, &rights, kAuthorizationEmptyEnvironment, flags, NULL);
	if (err != errAuthorizationSuccess) {
		NSLog(@"AuthorizationCopyRights: %d", err);
		goto out;
	}

	char *args[] = { (char *) "--privileged-server", NULL };
	err = AuthorizationExecuteWithPrivileges(auth, path, kAuthorizationFlagDefaults, args, NULL);
	if (err != errAuthorizationSuccess) {
		NSLog(@"AuthorizationExecuteWithPrivileges: %d", err);
	}

out:
	if (auth != NULL) {
		AuthorizationFree(auth, kAuthorizationFlagDefaults);
	}
	return err == errAuthorizationSuccess;
}

- (id) initParent {
	isChild = NO;
	connection = [[NSConnection connectionWithRegisteredName: REGISTER_NAME host: nil] retain];
	if (connection == nil) {
		NSLog(@"Spawning a child");
		BOOL ok = [[self class] spawnChild];
		if (!ok) {
			[self release];
			return nil;
		}
		connection = [[NSConnection connectionWithRegisteredName: REGISTER_NAME host: nil] retain];
	}
	if (connection == nil) {
		[self release];
		return nil;
	}
	remote = [[connection rootProxy] retain];

	return self;
}

- (id) initChild {
	isChild = YES;
	connection = [[NSConnection serviceConnectionWithName: REGISTER_NAME rootObject: self] retain];
	[connection setRootObject: self];

	return self;
}

- (void) dealloc {
	[connection release];
	[remote release];
	[super dealloc];
}


- (LMBootstrapContext *) rootContext {
	if (isChild) {
		return [LMBootstrapContext rootContextLimitedToCurrentSubtree: NO];
	} else {
		return [remote rootContext];
	}
}

- (LMBootstrapContext *) currentContext {
	if (isChild) {
		return [LMBootstrapContext currentContext];
	} else {
		return [remote currentContext];
	}
}

@end
