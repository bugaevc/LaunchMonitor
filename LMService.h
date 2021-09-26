//
//  LMService.h
//  LaunchMonitor
//
//  Created by Sergey on 5/28/19.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <servers/bootstrap.h>


@interface LMService : NSObject

@property (retain) NSString *name;
@property (retain) NSString *jobName;
@property bootstrap_status_t status;

// This is for the tree controller.
- (NSArray *) servicesAndChildren;

@end
