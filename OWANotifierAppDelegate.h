//
//  OWANotifierAppDelegate.h
//  OWANotifier
//
//  Created by Gregamel on 2/28/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OWAParser.h"
#import <Growl/Growl.h>

@interface OWANotifierAppDelegate : NSObject <GrowlApplicationBridgeDelegate>{
	NSStatusItem *statusItem;
	NSImage *mailIconOff;
	NSImage *mailIconOn;
	IBOutlet NSMenu *statusMenu;
	OWAParser *owa;
	NSInteger unreadCount;
	NSTimer *timer;
	NSDate *lastChecked;
}
-(void)checkPrefs;
-(IBAction)refresh:(id)sender;
-(IBAction)viewMail:(id)sender;
-(IBAction)showPrefs:(id)sender;

@end
