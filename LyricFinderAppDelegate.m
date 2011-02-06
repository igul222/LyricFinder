//
//  LyricalAppDelegate.m
//  Lyrical
//
//  Created by Ishaan Gulrajani on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LyricFinderAppDelegate.h"
#import "Controller.h"
#import "NSString+LyricFinder.h"
#import "ASIHTTPRequest.h"

@interface LyricFinderAppDelegate ()
-(void)updateProgressMessage;
@end


@implementation LyricFinderAppDelegate
@synthesize window, controller, progressIndicator, progressMessage, infoMessage, button, lowerInfoMessage;

-(void)dealloc {
	[controller release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[window center];
    
    [ASIHTTPRequest setDefaultTimeOutSeconds:5];
	
	controller = [[Controller alloc] init];
	controller.delegate = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        NSURL *url = [NSURL URLWithString:@"http://lyricfinderapp.com/status.html"];
        NSString *contents = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        contents = [contents stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        DLog(@"contents: '%@'",contents);
        if(![contents isEqualToString:@"OK"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSWorkspace sharedWorkspace] openURL:url];
            });
        }
    });
}

-(IBAction)buttonPressed:(id)sender {
	[progressIndicator startAnimation:self];
	[progressMessage setStringValue:@"Scanning library for songs without lyrics..."];
	
	[button setHidden:YES];
	[infoMessage setHidden:YES];
	[progressIndicator setHidden:NO];
	[progressMessage setHidden:NO];
	
	[controller beginWorking];
}

-(void)libraryScanFinished {
	[progressIndicator setIndeterminate:NO];
	[progressIndicator setMaxValue:1.0];
	[self updateProgressMessage];
}

-(void)lyricRequestFinished {
	[progressIndicator setDoubleValue:((double)controller.progressFinished / controller.progressTotal)];
	[self updateProgressMessage];
}

-(void)updateProgressMessage {
	[progressMessage setStringValue:[NSString stringWithFormat:@"Finding and adding lyrics... finished %i of %i",controller.progressFinished,controller.progressTotal]];
	if(controller.progressFinished == controller.progressTotal) {
		[progressMessage setHidden:YES];
		[progressIndicator setHidden:YES];
		
		[infoMessage setStringValue:@"Done!"];
		[infoMessage setFont:[NSFont boldSystemFontOfSize:13.0]];
		[infoMessage setHidden:NO];

		int success = controller.successfulRequests;
		int total = controller.progressTotal;
		[lowerInfoMessage setStringValue:[NSString stringWithFormat:@"Found lyrics for %i of %i songs (%.0f%%).",success,total,((double)success*100)/(total==0 ? 1 : total)]];
		[lowerInfoMessage setHidden:NO];
	}
}

@end
