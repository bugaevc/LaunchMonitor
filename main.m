//
//  main.m
//  LaunchMonitor
//
//  Created by Sergey on 5/28/19.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LMPrivilegedBootstrapContextFactory.h"

int main(int argc, char *argv[])
{
	if (argc >= 2 && !strcmp(argv[1], "--privileged-server")) {
		[NSAutoreleasePool new];
		[[LMPrivilegedBootstrapContextFactory alloc] initChild];
		[[NSRunLoop currentRunLoop] run];
		return 0;
	}
	return NSApplicationMain(argc,  (const char **) argv);
}
