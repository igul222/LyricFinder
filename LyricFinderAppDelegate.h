//
//  LyricalAppDelegate.h
//  Lyrical
//
//  Created by Ishaan Gulrajani on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Controller;
@interface LyricFinderAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	Controller *controller;
	NSProgressIndicator *progressIndicator;
	NSTextField *progressMessage;
	NSTextField *infoMessage;
	NSButton *button;
	NSTextField *lowerInfoMessage;
}
@property(assign) IBOutlet NSWindow *window;
@property(retain) Controller *controller;
@property(assign) IBOutlet NSProgressIndicator *progressIndicator;
@property(assign) IBOutlet NSTextField *progressMessage;
@property(assign) IBOutlet NSTextField *infoMessage;
@property(assign) IBOutlet NSButton *button;
@property(assign) IBOutlet NSTextField *lowerInfoMessage;

-(void)libraryScanFinished;
-(void)lyricRequestFinished;
-(IBAction)buttonPressed:(id)sender;

@end
