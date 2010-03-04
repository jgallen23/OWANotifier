//
//  OWANotifierAppDelegate.m
//  OWANotifier
//
//  Created by Gregamel on 2/28/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "OWANotifierAppDelegate.h"
#import "PreferencesWindowController.h"

#define GROWL_NEW_MESSAGE @"New Message"

@implementation OWANotifierAppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[GrowlApplicationBridge setGrowlDelegate: self];
	
	NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
	statusItem = [[statusBar statusItemWithLength:NSVariableStatusItemLength] retain];
	mailIconOn = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_on" ofType:@"png"]];
	mailIconOff = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_off" ofType:@"png"]];
	
	[statusItem setImage:mailIconOff];
	[statusItem setHighlightMode:YES];
	[statusItem setToolTip:@"OWANotifier"];
	[statusItem setMenu:statusMenu];
	
	[self checkPrefs];
}

-(void)showPrefs:(id)sender {
	PreferencesWindowController *prefs = [[PreferencesWindowController alloc] initWithWindowNibName:@"Preferences"];
	[prefs showWindow:self];
}

- (void)checkPrefs {
	if (![[NSUserDefaults standardUserDefaults] stringForKey:@"url"]) {
		[self showPrefs:nil];
	} else {
		NSString *url = [[NSUserDefaults standardUserDefaults] stringForKey:@"url"];
		NSString *login = [[NSUserDefaults standardUserDefaults] stringForKey:@"login"];
		NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
		NSInteger refreshRate = [[NSUserDefaults standardUserDefaults] integerForKey:@"refreshRate"]*60;
		owa = [[[OWAParser alloc] initWithURL:url login:login password:password] retain];
		if (timer)
			[timer invalidate];
		timer = [NSTimer timerWithTimeInterval:refreshRate target:self selector:@selector(refresh:) userInfo:nil repeats:YES];
		[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
		[self refresh:nil];
	}
}

- (void)refresh:(id)sender {
	[NSThread detachNewThreadSelector:@selector(refreshThread) toTarget:self withObject:nil];
}

- (void)viewMailFromMenu:(id)sender {
	NSDictionary *msg = [sender representedObject];
	NSString *url = [owa getFullMessageUrlFromId:[msg objectForKey:@"id"]];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

- (void)refreshThread {

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	unreadCount = [owa getInboxUnreadCount];
	int menuIndex = 7;
	for (int i = menuIndex, c = [statusMenu numberOfItems]; i < c; i++) {
		[statusMenu removeItemAtIndex:menuIndex];
	}
	NSArray *messages = [owa getMessagesFrom:@"Inbox"];
	BOOL newMail = NO;
	for (NSDictionary *msg in messages) {
		
		if ([[msg objectForKey:@"unread"] intValue] == 1) {
			NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[msg objectForKey:@"subject"] action:@selector(viewMailFromMenu:) keyEquivalent:@""];
			[menuItem setTarget:self];
			[menuItem setRepresentedObject:msg];
			[statusMenu insertItem:menuItem atIndex:menuIndex];
			if ([lastChecked compare:[msg objectForKey:@"date"]] == NSOrderedAscending) {
				newMail = YES;
				[GrowlApplicationBridge notifyWithTitle:@"New Message" description:[NSString stringWithFormat:@"Subject: %@\nFrom: %@", [msg objectForKey:@"subject"], [msg objectForKey:@"from"]] notificationName:GROWL_NEW_MESSAGE iconData:nil priority:0 isSticky:NO clickContext:msg];
			}
			menuIndex++;
		}
	}
	
	if (newMail)
		[[NSSound soundNamed:@"Blow"] play];
	if ([messages count] != 0)
		lastChecked = [[messages objectAtIndex:0] objectForKey:@"date"];
	[pool release];
	[self performSelectorOnMainThread:@selector(updateStatus) withObject:nil waitUntilDone:NO];
}

-(void)updateStatus {
	[statusItem setTitle:[NSString stringWithFormat:@"%d", unreadCount]];
	if (unreadCount != 0) {
		[statusItem setImage:mailIconOn];
	} else {
		[statusItem setImage:mailIconOff];
	}
}

-(void)viewMail:(id)sender {
	NSString *baseUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"url"];
	NSString *url = [NSString stringWithFormat:@"https://%@", baseUrl];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

- (NSDictionary *) registrationDictionaryForGrowl {
	NSArray * notifications = [NSArray arrayWithObjects: GROWL_NEW_MESSAGE, nil];
    return [NSDictionary dictionaryWithObjectsAndKeys: notifications, GROWL_NOTIFICATIONS_ALL,
			notifications, GROWL_NOTIFICATIONS_DEFAULT, nil];
}

- (NSString *) applicationNameForGrowl {
	return @"OWANotifier";
}

- (void) growlIsReady {
	NSLog(@"Growl");
}

- (void) growlNotificationWasClicked:(id)clickContext {
	NSString *url = [owa getFullMessageUrlFromId:[clickContext objectForKey:@"id"]];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

@end
