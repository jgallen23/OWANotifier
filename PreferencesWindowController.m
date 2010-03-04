//
//  PreferencesWindowController.m
//  OWANotifier
//
//  Created by Greg Allen on 3/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PreferencesWindowController.h"


@implementation PreferencesWindowController

-(void)awakeFromNib {
	[self.window setLevel:NSFloatingWindowLevel];
	[self.window orderFrontRegardless];
	if ([[NSUserDefaults standardUserDefaults] stringForKey:@"url"])
		[urlTextField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"url"]];
	if ([[NSUserDefaults standardUserDefaults] stringForKey:@"login"])
		[loginTextField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"login"]];
	if ([[NSUserDefaults standardUserDefaults] stringForKey:@"password"])
		[passwordTextField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"password"]];
	if ([[NSUserDefaults standardUserDefaults] stringForKey:@"refreshRate"])
		[refreshRatePopUp selectItemWithTitle:[[NSUserDefaults standardUserDefaults] stringForKey:@"refreshRate"]];
}

-(void)okPressed:(id)sender {
	[statusLabel setStringValue:@"Authorizing"];
	[NSThread detachNewThreadSelector:@selector(checkAuth) toTarget:self withObject:nil];
}

-(void)checkAuth {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[progressIndicator startAnimation:self];
	
	NSString *url = [urlTextField stringValue];
	NSString *login = [loginTextField stringValue];
	NSString *password = [passwordTextField stringValue];
	OWAParser *owa = [[OWAParser alloc] initWithURL:url login:login password:password];
	if ([owa isAuthenticated]) {
		[self performSelectorOnMainThread:@selector(authSuccess) withObject:nil waitUntilDone:NO];
	} else {
		[self performSelectorOnMainThread:@selector(authFailed) withObject:nil waitUntilDone:NO];
		
	}

	[progressIndicator stopAnimation:self];
	[pool release];
}

-(void)authSuccess {
	NSLog(@"Success");
	[statusLabel setStringValue:@""];
	[[NSUserDefaults standardUserDefaults] setObject:[urlTextField stringValue] forKey:@"url"];
	[[NSUserDefaults standardUserDefaults] setObject:[loginTextField stringValue] forKey:@"login"];
	[[NSUserDefaults standardUserDefaults] setObject:[passwordTextField stringValue] forKey:@"password"];
	[[NSUserDefaults standardUserDefaults] setObject:[refreshRatePopUp titleOfSelectedItem] forKey:@"refreshRate"];
	[[NSApp delegate] checkPrefs];
	[self.window close];
}

-(void)authFailed {
	NSLog(@"Failed");
	[statusLabel setStringValue:@"Invalid Login"];
}

-(void)cancelPressed:(id)sender {
	[self.window close];
}

@end
