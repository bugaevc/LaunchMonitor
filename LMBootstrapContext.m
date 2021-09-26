//
//  LMBootstrapContext.m
//  LaunchMonitor
//
//  Created by Sergey on 5/31/19.
//  Copyright 2019 __MyCompanyName__. All rights reserved.
//

#import <mach/mach.h>
#import <servers/bootstrap.h>
#import "LMBootstrapContext.h"
#import "LMService.h"


extern kern_return_t bootstrap_info(mach_port_t boostrap,
									name_array_t *serviceNames, mach_msg_type_number_t *serviceNamesCnt,
									name_array_t *jobNames, mach_msg_type_number_t *jobsCnt,
									bootstrap_status_array_t *statuses, mach_msg_type_number_t *statusesCnt,
									uint64_t flags);

extern kern_return_t bootstrap_lookup_children(mach_port_t bootstrap,
									mach_port_array_t *child_ports,
									name_array_t *child_names,
									bootstrap_property_array_t *child_props,
									mach_msg_type_number_t *cnt);


@implementation LMBootstrapContext

+ (LMBootstrapContext *) contextWithPort: (mach_port_t) port
									name: (NSString *) name {
	LMBootstrapContext *context = [LMBootstrapContext new];
	context->port = port;
	context->name = [name copy];
	return [context autorelease];
}

+ (LMBootstrapContext *) rootContextLimitedToCurrentSubtree: (BOOL) limitToCurrentSubtree {
	mach_port_t port = bootstrap_port;
	LMBootstrapContext *context = nil;
	if (limitToCurrentSubtree) {
		context = [self currentContext];
		context->children = [NSArray new];
	}

	while (YES) {
		mach_port_t parent;
		kern_return_t kr = bootstrap_parent(port, &parent);
		if (kr != KERN_SUCCESS) {
			NSLog(@"Failed to get bootstrap root: %s", mach_error_string(kr));
			return nil;
		}
		if (parent == port) {
			// We've reached the root context.
			// FIXME: do we have to dealloc parent here?
			break;
		}
		if (limitToCurrentSubtree) {
			LMBootstrapContext *parentContext = [self contextWithPort: parent name: @"<Context>"];
			parentContext->children = [[NSArray arrayWithObject: context] retain];
			context = parentContext;
		} else if (port != bootstrap_port) {
			mach_port_deallocate(mach_task_self(), port);
		}
		port = parent;
	}

	if (limitToCurrentSubtree) {
		return context;
	} else {
		return [self contextWithPort: port name: @"<Root>"];
	}
}

+ (LMBootstrapContext *) currentContext {
	mach_port_mod_refs(mach_task_self(), bootstrap_port, MACH_PORT_RIGHT_SEND, +1);
	return [self contextWithPort: bootstrap_port name: @"<Current>"];
}

- (void) dealloc {
	[name release];
	mach_port_deallocate(mach_task_self(), port);
	[children release];
	[services release];
	[super dealloc];
}

- (NSString *) name {
	return name;
}

- (NSArray *) children {
	if (children == nil) {
		mach_port_array_t child_ports = NULL;
		name_array_t child_names = NULL;
		bootstrap_property_array_t child_props = NULL;
		mach_msg_type_number_t cnt;

		kern_return_t kr = bootstrap_lookup_children(port, &child_ports, &child_names, &child_props, &cnt);
		if (kr != KERN_SUCCESS) {
			// TODO
			return nil;
		}

		children = [[NSMutableArray alloc] initWithCapacity: cnt];
		for (mach_msg_type_number_t i = 0; i < cnt; i++) {
			LMBootstrapContext *child = [LMBootstrapContext new];
			child->port = child_ports[i];
			child->name = [[NSString alloc] initWithUTF8String: child_names[i]];
			child->props = child_props[i];
			[(NSMutableArray *) children addObject: child];
			[child release];
		}
	}
	return children;
}

- (NSArray *) services {
	if (services == nil) {
		name_array_t names, jobNames;
		bootstrap_status_array_t statuses;
		mach_msg_type_number_t cnt;

		kern_return_t kr = bootstrap_info(port, &names, &cnt, &jobNames, &cnt, &statuses, &cnt, 0);
		if (kr != KERN_SUCCESS) {
			// TODO
			return nil;
		}

		services = [[NSMutableArray alloc] initWithCapacity: cnt];

		for (mach_msg_type_number_t i = 0; i < cnt; i++) {
			LMService *service = [LMService new];
			service.name = [NSString stringWithUTF8String: names[i]];
			service.jobName = [NSString stringWithUTF8String: jobNames[i]];
			service.status = statuses[i];
			[(NSMutableArray *) services addObject: service];
			[service release];
		}
	}
	return services;
}

- (NSArray *) servicesAndChildren {
	return [[self services] arrayByAddingObjectsFromArray: [self children]];
}

- (NSString *) jobName {
	return nil;
}

- (bootstrap_status_t) status {
	return ~ (bootstrap_status_t) props;
}

@end
