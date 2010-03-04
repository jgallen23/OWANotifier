//
//  PreferencesWindowController.h
//  OWANotifier
//
//  Created by Greg Allen on 3/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OWAParser.h";

@interface PreferencesWindowController : NSWindowController {
	IBOutlet NSTextField *urlTextField;
	IBOutlet NSTextField *loginTextField;
	IBOutlet NSTextField *passwordTextField;
	IBOutlet NSPopUpButton *refreshRatePopUp;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSTextField *statusLabel;
}

-(IBAction)okPressed:(id)sender;
-(IBAction)cancelPressed:(id)sender;

@end
